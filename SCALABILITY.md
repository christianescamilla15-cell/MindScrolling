# MindScrolling — Scalability & Architecture Stress Test

**Authored:** 2026-03-15
**Method:** Code-level review of actual backend implementation
**Files analyzed:** `backend/src/routes/quotes.js`, `backend/src/routes/swipes.js`, `backend/src/app.js`, `flutter_app/lib/data/repositories/feed_repository.dart`

---

## 1. Overall Health Assessment

The current architecture is **correct for 0–1k users** and has a solid clean foundation. However, three concrete code-level issues will create production failures before 10k DAU, and one of them is a functional bug that is already incorrect at any scale.

| Component | Current state | Risk level |
|---|---|---|
| Feed endpoint | 7 sequential DB queries per request | High |
| Swipe endpoint | 5 sequential DB queries per write | Medium |
| Cursor pagination | UUID `gt()` comparison — logically broken | Critical bug |
| NOT IN exclusion | Up to 500 UUIDs per query as URL string | High at scale |
| Caching | None | High at scale |
| Event table | Unbounded row growth, no partitioning | High at scale |
| Flutter client | 5s TTL cache, fire-and-forget writes | Good |
| Rate limiting | 60 req/min global IP-based | Insufficient at scale |

---

## 2. Scalability Rating by Stage

| Stage | DAU | Current rating | Bottleneck |
|---|---|---|---|
| Phase 1 | 1k | ✅ Handles comfortably | None blocking |
| Phase 2 | 10k | ⚠️ Degrading | Sequential queries + no cache |
| Phase 3 | 100k | ❌ Will fail | NOT IN explosion + swipe_events growth |
| Phase 4 | 1M | ❌ Not viable | Complete architectural changes needed |

---

## 3. Identified Bottlenecks (Code-Level)

### BN-01 — Feed endpoint: 7 sequential database round-trips

**File:** `backend/src/routes/quotes.js`, lines 25–164

Every `GET /quotes/feed` request fires 7 database calls **sequentially** (each one `await`ed before the next starts):

```
Request arrives
  │
  await supabase.from("user_profiles").select(...)          ← query 1
  await supabase.from("user_preferences").select(...)       ← query 2
  await supabase.from("seen_quotes").select(...).limit(500) ← query 3
  await supabase.from("users").select("is_premium")         ← query 4
  [all 4 above are INDEPENDENT but run one-by-one]
  │
  await supabase.from("quotes").select("*").not("id", ...) ← query 5
  await supabase.from("seen_quotes").select(...JOIN quotes) ← query 6
  await supabase.from("seen_quotes").upsert(...)            ← query 7
```

Assuming 10ms per query (Supabase in same region): **~70ms of pure DB wait per feed request**, not counting network or computation.

**At 10k DAU, 3 feed loads/day each:** 30k feed requests/day × 7 queries = **210k DB operations/day from feed alone**.

Queries 1–4 are completely independent and can be parallelized with `Promise.all()`.

---

### BN-02 — Cursor pagination uses UUID comparison (functional bug)

**File:** `backend/src/routes/quotes.js`, line 111

```js
if (cursor) {
  query = query.gt("id", cursor);
}
```

The `id` column is a `UUID` (v4 = random). UUIDs have no meaningful ordering relationship. `gt("id", cursor)` compares UUIDs lexicographically — the result is non-deterministic and will skip or repeat quotes unpredictably across requests.

This is a **functional bug at any scale**. It does not fail loudly — it silently returns wrong pages.

**Fix:** Use a `created_at` timestamp cursor, or a sequential integer offset, or sort by a deterministic field before applying the cursor.

---

### BN-03 — NOT IN exclusion with up to 500 UUIDs

**File:** `backend/src/routes/quotes.js`, lines 107–109

```js
if (excludeIds.length > 0) {
  query = query.not("id", "in", `(${excludeIds.join(",")})`)
}
```

This generates a Supabase/PostgREST URL parameter like:
```
?id=not.in.(uuid1,uuid2,...uuid500)
```

Two problems:

1. **URL length**: 500 UUIDs = ~18,000 characters in the URL. Nginx default max URL length is 8,192 bytes. This will cause `414 URI Too Long` errors once a user has 300+ seen quotes.

2. **Query performance**: PostgreSQL `NOT IN (500 values)` forces a sequential scan on the quotes table — it cannot use the `idx_quotes_category_lang` index effectively. At 5,500 quotes this is fast; at 100k quotes it will degrade significantly.

**Fix:** Move seen_quotes exclusion to a SQL `NOT EXISTS` subquery or a `LEFT JOIN ... WHERE seen.quote_id IS NULL`, which is index-friendly. Or cap seen_quotes at 200 and use a server-side exclusion approach.

---

### BN-04 — SELECT * on quotes table

**File:** `backend/src/routes/quotes.js`, line 99

```js
let query = supabase.from("quotes").select("*")
```

Fetches all columns (`id`, `text`, `author`, `category`, `lang`, `swipe_dir`, `pack_name`, `is_premium`, `created_at`) for `take * 5` rows (up to 100 rows) on every request, only to sort and return 10–20. The `text` field can be up to 500 characters.

Minor now, but at 100k+ quotes the query pool grows and the payload per request increases unnecessarily.

---

### BN-05 — Swipe endpoint: 5 sequential database round-trips

**File:** `backend/src/routes/swipes.js`, lines 27–124

Every `POST /swipes` fires 5 DB calls sequentially:

```
Request arrives
  await supabase.from("users").select(...)          ← query 1 (read user)
  await supabase.from("users").upsert(...)           ← query 2 (write user)
  await supabase.from("swipe_events").insert(...)    ← query 3 (write event)
  await supabase.from("user_preferences").select(..) ← query 4 (read prefs)
  await supabase.from("user_preferences").upsert(...)← query 5 (write prefs)
```

Queries 1 and 4 are independent reads — they can be parallelized.
Queries 3 is independent from 1/2 once device_id is validated.

**At 100k DAU × 30 swipes/day:** 3M swipe requests × 5 queries = **15M DB operations/day** from swipes alone.

---

### BN-06 — swipe_events table: unbounded growth, no partitioning

**File:** `backend/src/db/migrations/001_initial.sql`, lines 97–106

The `swipe_events` table has no row expiry, archival strategy, or partitioning:

| DAU | Swipes/day | Rows after 1 year |
|---|---|---|
| 1k | 30k | ~11M |
| 10k | 300k | ~110M |
| 100k | 3M | ~1B |

At 1B rows with a single `idx_swipe_events_device` index, queries that aggregate swipe history for the recommendation engine will degrade significantly. PostgreSQL VACUUM also struggles with tables that grow this fast without partitioning.

---

### BN-07 — seen_quotes join in author penalty query

**File:** `backend/src/routes/quotes.js`, lines 138–147

```js
const { data: recentSeen } = await supabase
  .from("seen_quotes")
  .select("quote_id, seen_at, quotes(author)")
  .eq("device_id", deviceId)
  .order("seen_at", { ascending: false })
  .limit(3);
```

This is a cross-table join (`seen_quotes` → `quotes`) executed on every single feed request. At low scale it's fast. At 10M `seen_quotes` rows it will require careful indexing.

---

### BN-08 — No caching layer

The same user requesting feed twice in 30 seconds (app restart, navigation back) triggers 7 full database queries both times. There is no in-memory cache, no Redis, and no response caching at the Fastify level.

**Flutter-side:** `FeedLocalDataSource` has a 5-minute TTL cache on the first page, which is good. But pages 2+ are never cached.

---

### BN-09 — Rate limiting is IP-based, not device-based

**File:** `backend/src/app.js`, line 24–27

```js
await app.register(rateLimit, {
  max: 60,
  timeWindow: "1 minute",
});
```

With 10k users behind shared mobile carrier NAT (very common), thousands of users can share a single IP. The current rate limiter will block legitimate users the moment any shared IP accumulates 60 requests/minute — which happens organically at scale.

---

### BN-10 — Single Fastify process, no clustering

`backend/src/app.js` starts a single Node.js process. Node.js is single-threaded. Under CPU-heavy feed scoring (sorting, scoring 100 quotes per request), this becomes a bottleneck before connection limits do.

---

## 4. Recommended Improvements by Phase

---

### Phase 1 (1k DAU) — No changes required

The current architecture handles this comfortably.

**Optional hardening:**
- Fix the UUID cursor bug (BN-02) — it's already wrong at 1k users
- Add `select()` column list to quotes query instead of `select("*")`

---

### Phase 2 (10k DAU) — Parallelize queries, fix cursor

**Priority: High. These changes are low-effort, high-impact.**

#### Fix 1 — Parallelize independent feed queries

```js
// Instead of 4 sequential awaits, run them concurrently:
const [profileRes, prefsRes, seenRes, userRes] = await Promise.all([
  supabase.from("user_profiles").select(...).eq("device_id", deviceId).maybeSingle(),
  supabase.from("user_preferences").select(...).eq("device_id", deviceId),
  supabase.from("seen_quotes").select("quote_id").eq("device_id", deviceId).limit(500),
  supabase.from("users").select("is_premium").eq("device_id", deviceId).maybeSingle(),
]);
// Reduces 4 sequential round-trips → 1 parallel round-trip
// Feed latency improves by ~30ms per request
```

#### Fix 2 — Fix cursor pagination

Replace UUID `gt()` comparison with `created_at` cursor:

```js
// In the quotes query:
if (cursor) {
  query = query.lt("created_at", cursor);  // cursor = ISO timestamp of last item
}
// Return in response:
next_cursor: last?.created_at ?? null
```

Requires adding `created_at` to the select columns and a supporting index.

#### Fix 3 — Add Fastify in-memory cache for feed

```js
// Cache the scored result for each (device_id, lang, cursor) key for 2 minutes
// Simple approach: use a Map with TTL in the Fastify process
// Better: @fastify/caching with a short TTL
const cacheKey = `feed:${deviceId}:${lang}:${cursor ?? "first"}`;
const cached = feedCache.get(cacheKey);
if (cached) return reply.send(cached);
```

Eliminates repeated full DB cycles for the same user opening the app multiple times in a short window.

---

### Phase 3 (100k DAU) — Structural changes required

#### Fix 4 — Replace NOT IN with NOT EXISTS (BN-03)

The 500-UUID NOT IN clause must be replaced. Use Supabase's `seen_quotes` join approach:

```sql
-- Instead of NOT IN (500 UUIDs), use a subquery:
SELECT q.*
FROM quotes q
WHERE q.lang = $1
  AND q.is_premium = $2
  AND NOT EXISTS (
    SELECT 1 FROM seen_quotes s
    WHERE s.quote_id = q.id
      AND s.device_id = $3
  )
LIMIT 100;
```

This is index-friendly and eliminates the URL length problem. Expose it as a Supabase RPC (stored function) to avoid passing the query through PostgREST URL parameters.

#### Fix 5 — Move feed scoring to a precomputed table

At 100k DAU, generating a personalized scored feed synchronously on every request is expensive. Instead:

```
Background job (runs every 15 min per user who was active):
  1. Read user_preferences
  2. Score all unseen quotes for this user
  3. Write top 50 into a pre_computed_feed table:
     { device_id, quote_id, score, computed_at }

GET /quotes/feed:
  1. Read from pre_computed_feed WHERE device_id = $1 LIMIT 20
  2. Delete returned rows (or mark as delivered)
  3. If pre_computed_feed is empty → fallback to real-time scoring
```

This converts a 7-query synchronous operation into a 1-query read on the hot path.

#### Fix 6 — Partition swipe_events by month (BN-06)

```sql
-- Replace the current swipe_events table with a partitioned version:
CREATE TABLE swipe_events (
  id            UUID DEFAULT gen_random_uuid(),
  device_id     VARCHAR(100),
  quote_id      UUID,
  direction     VARCHAR(10),
  category      VARCHAR(50),
  dwell_time_ms INT DEFAULT 0,
  created_at    TIMESTAMPTZ DEFAULT now()
) PARTITION BY RANGE (created_at);

CREATE TABLE swipe_events_2026_03 PARTITION OF swipe_events
  FOR VALUES FROM ('2026-03-01') TO ('2026-04-01');
-- Add new partition each month via cron job
```

The recommendation engine only needs swipe data from the last 90 days. Older partitions can be archived or dropped.

#### Fix 7 — Rate limit by device_id, not IP

```js
await app.register(rateLimit, {
  max: 120,
  timeWindow: "1 minute",
  keyGenerator: (request) => request.headers["x-device-id"] || request.ip,
});
```

This prevents shared IP false positives while still blocking per-device abuse.

#### Fix 8 — Add Redis for preference and profile caching

```
User preference data changes infrequently (only on swipe/like).
Cache profile + preferences in Redis with a 5-minute TTL.

Cache key: pref:{device_id}
Invalidate on: POST /swipes, POST /quotes/:id/like

At 100k DAU: this eliminates 2 DB queries per feed request for 80%+ of requests
(assuming users request feed within 5 min of their last swipe)
```

#### Fix 9 — Add Node.js cluster or PM2 with worker threads

```js
// app.js with cluster:
import cluster from "node:cluster";
import os from "node:os";

if (cluster.isPrimary) {
  const workers = Math.min(os.cpus().length, 4);
  for (let i = 0; i < workers; i++) cluster.fork();
} else {
  // existing Fastify startup
}
```

4 worker processes handle CPU-bound feed scoring in parallel.

---

### Phase 4 (1M DAU) — Full infrastructure evolution

At this scale, the Fastify monolith needs to be decomposed and infrastructure becomes the primary investment:

#### Architecture changes

```
Current (monolith):
  Flutter → Fastify → Supabase

Target (1M DAU):
  Flutter
    │
    ├── CDN (CloudFront/Fastly) ← static assets, cached feed pages
    │
    ├── API Gateway (load balancer)
    │       │
    │       ├── Feed Service (horizontal pod scaling)
    │       ├── Swipe Service (event ingestion, write-optimized)
    │       ├── Profile Service
    │       └── Premium Service
    │
    ├── Redis Cluster ← feed cache, session data, rate limits
    │
    ├── PostgreSQL Primary ← writes only
    │       │
    │       └── Read Replica ×2 ← feed generation reads
    │
    └── Analytics Queue (Kafka/Redpanda)
            │
            └── Consumer → swipe_events (batch writes)
                        → preference model updates (async)
```

#### Swipe event ingestion at 1M DAU

At 1M DAU × 30 swipes = **30M swipe events/day = 347 writes/second sustained**.

The current synchronous `INSERT → swipe_events, UPSERT → users, UPSERT → user_preferences` pattern cannot sustain 347 writes/second per record without connection pooling and batching.

**Solution:** Accept swipe events into a Redis queue (fire-and-forget from client), drain queue in batches of 1,000 every 30 seconds via a background worker. The user_preferences model is updated in bulk from the batch, not row-by-row.

---

## 5. Query Complexity Summary (Current vs Recommended)

| Endpoint | Current queries | After Phase 2 fixes | After Phase 3 fixes |
|---|---|---|---|
| `GET /feed` | 7 sequential | 4 parallel + 3 sequential | 1 read (precomputed) |
| `POST /swipes` | 5 sequential | 3 parallel + 2 sequential | Queue → batch worker |
| `GET /map` | 1–2 queries | unchanged | 1 cache hit |

---

## 6. Database Table Growth Projections

| Table | 1k DAU/year | 10k DAU/year | 100k DAU/year |
|---|---|---|---|
| `swipe_events` | 11M rows | 110M rows | 1.1B rows |
| `seen_quotes` | 500k rows | 5M rows | 50M rows |
| `user_preferences` | 4k rows | 40k rows | 400k rows |
| `vault` | ~50k rows | ~500k rows | ~5M rows |
| `likes` | ~100k rows | ~1M rows | ~10M rows |
| `users` | 1k rows | 10k rows | 100k rows |

**Only `swipe_events` and `seen_quotes` require structural intervention before 100k DAU.** All others are manageable with standard indexing.

---

## 7. Mobile Client Assessment

The Flutter client is well-designed for scale:

| Pattern | Implementation | Assessment |
|---|---|---|
| Feed buffer | `FeedQueueManager` + `FeedPrefetchService` | ✅ Correct |
| Offline cache | `FeedLocalDataSource` with 5-min TTL | ✅ Good |
| Fire-and-forget writes | `recordSwipe`, `likeQuote` | ✅ Correct |
| Cursor pagination | Passes cursor to backend | ✅ Pattern correct (backend cursor is broken) |
| Error isolation | `ApiResult<T>` sealed type | ✅ Robust |

The client will not become a bottleneck. The prefetch trigger (when queue < 5) is appropriate. The 5-minute TTL cache prevents redundant requests on app restart.

**One improvement:** cache pages 2+ (subsequent cursor pages), not just the first page. This allows full offline browsing of a day's worth of content.

---

## 8. Feed Engine Execution Strategy

**Recommendation by scale:**

| Stage | Strategy |
|---|---|
| 0–1k | Synchronous in API (current) — acceptable |
| 1k–10k | Synchronous but parallelized (Fix 1) + in-process cache |
| 10k–100k | Precomputed feed table updated by background job every 15 min |
| 100k+ | Precomputed + Redis + event-driven preference updates |

The current synchronous approach is fine until 10k DAU. The jump to precomputation is the most impactful single architectural change for Phase 3.

---

## 9. Immediate Action Items (Before 10k Users)

These are **concrete code changes** ranked by impact:

| Priority | Fix | Effort | Impact |
|---|---|---|---|
| P0 | Fix UUID cursor bug (BN-02) | 30 min | Functional correctness |
| P0 | Parallelize feed queries 1–4 with Promise.all (BN-01) | 1h | ~30ms latency reduction |
| P1 | Replace NOT IN with NOT EXISTS RPC (BN-03) | 2h | Unblocks 100k scale |
| P1 | Add device_id-based rate limiting (BN-09) | 30 min | Correctness at scale |
| P1 | Add column list to `select("*")` (BN-04) | 15 min | Bandwidth reduction |
| P2 | Partition swipe_events by month (BN-06) | 2h | Required before 100k |
| P2 | In-process feed cache with 2-min TTL (BN-08) | 2h | DB load reduction |
| P3 | Node.js cluster / PM2 (BN-10) | 1h | CPU scaling |
| P3 | Precomputed feed table + background job | 1 day | Unblocks 1M scale |
