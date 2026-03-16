# MindScrolling — Feed Algorithm Specification v2

**Version:** Sprint 5 (Migrations 003 + 004)
**Owner:** Backend
**Related files:**
- `backend/src/routes/quotes.js` — hybrid feed endpoint
- `backend/src/services/embeddings.js` — Voyage AI embedding service
- `backend/src/services/insights.js` — Claude AI insight generation
- `backend/src/routes/insights.js` — `GET /insights/weekly`
- `backend/src/db/migrations/003_feed_algorithm.sql` — behavioural signal schema
- `backend/src/db/migrations/004_ai_feed.sql` — pgvector + AI insight cache
- `backend/src/db/scripts/embed_quotes.js` — one-time batch embedding

---

## Architecture Overview

The feed engine operates in two modes depending on the user's maturity:

| Mode | Condition | Primary signal |
|---|---|---|
| **Behavioural** | New user — no preference vector | Category affinity from likes/swipes/vault |
| **Hybrid (AI)** | Returning user — has preference vector | Semantic similarity + category affinity |

The system transitions silently from behavioural to hybrid after the first like, vault save, or 5-second dwell event — no user action required.

```
New user                               Returning user
────────                               ──────────────
Pure category affinity         →       Semantic vector search
Weights from likes/swipes              + category affinity
                                       + dwell pattern signals
                                       + exploration noise
```

---

## Signal Model

All signals are stored per `(device_id, category)` in `user_preferences`.
The semantic preference vector is stored separately in `user_preference_vectors`.

### Behavioural Signals

| Signal | Column | Affinity weight | Trigger |
|---|---|---|---|
| Like | `like_count` | ×3 | `POST /quotes/:id/like` |
| Vault save | `vault_count` | ×5 (strongest) | `POST /vault` |
| Swipe | `swipe_count` | ×1 | `POST /swipes` |
| Skip (dwell < 500 ms) | `skip_count` | −2 | `POST /swipes` |
| Dwell total | `total_dwell_ms` | see dwell signal | `POST /swipes` |

### Semantic Signal

| Signal | Storage | α (learning rate) | Trigger |
|---|---|---|---|
| Like | `user_preference_vectors.vector` | 0.20 | `POST /quotes/:id/like` |
| Vault save | `user_preference_vectors.vector` | 0.25 | `POST /vault` |
| Long dwell (≥ 5 s) | `user_preference_vectors.vector` | 0.10 | `POST /swipes` |

The semantic preference vector is updated **asynchronously** (fire-and-forget) so it never adds latency to the user-facing API.

---

## Preference Vector: Exponential Moving Average

The preference vector is a 512-dimensional dense vector representing the user's philosophical interests in semantic space.

**Update formula (applied in Postgres RPC `upsert_preference_vector`):**

```
v_new = L2_normalize( (1 − α) × v_current  +  α × v_quote )
```

Where:
- `v_quote` = embedding of the quote that triggered the signal (Voyage AI voyage-3-lite, 512 dims)
- `v_current` = current stored preference vector (zero vector if first signal)
- `α` = learning rate (0.25 vault, 0.20 like, 0.10 dwell)
- `L2_normalize()` keeps the vector on the unit sphere for stable cosine similarity

**Properties:**
- **Recency bias** — recent high-signal quotes have higher influence
- **Stability** — EMA prevents a single event from radically changing the vector
- **No catastrophic forgetting** — past interests decay gradually, not abruptly
- **Category diversity preserved** — if user likes philosophy AND stoicism quotes, both are reflected in the vector

---

## Affinity Weight Formula (Behavioural Layer)

For each category `c`, the raw affinity weight is:

```
weight(c) = like_count(c)  × 3
          + vault_count(c) × 5
          + swipe_count(c) × 1
          − skip_count(c)  × 2
          + BASE_WEIGHT        (= 5, prevents zero-weight categories)
```

**Onboarding boosts** (applied once from `user_profiles`, do not decay):

| Interest | Boost |
|---|---|
| `philosophy` | philosophy +10 |
| `stoicism` | stoicism +10 |
| `personal_growth` | discipline +10 |
| `mindfulness` | reflection +10 |
| `curiosity` | all +3 |

| Goal | Boost |
|---|---|
| `discipline` | discipline +8 |
| `calm_mind` | stoicism +8, reflection +8 |
| `mindfulness` | stoicism +8, reflection +8 |
| `meaning` | philosophy +8 |
| `emotional_clarity` | reflection +8 |

**Normalisation:**
```
normalised(c) = weight(c) / Σ weight(all 4 categories)
```

---

## Dwell Signal

Average dwell time per category, normalised to 0–1:

```
avg_dwell(c)    = total_dwell_ms(c) / max(swipe_count(c), 1)
dwell_signal(c) = clamp(avg_dwell(c) / 4000, 0, 1)
                 (4 s avg = maximum signal)
```

---

## Scoring Formulas

### Hybrid Score (returning user with preference vector)

```
score(q) = semantic_similarity(q)        × 0.45
         + normalised_affinity(q.cat)    × 0.30
         + dwell_signal(q.cat)           × 0.10
         + random()                      × 0.10
         + challenge_boost(q)            × 0.05
         − author_penalty(q)

where:
  semantic_similarity(q) = 1 − cosine_distance(q.embedding, v_user)
                         = computed inside match_quotes Postgres RPC

  challenge_boost(q)     = 1.0  if q.category = today's challenge category
                           0.0  otherwise

  author_penalty(q)      = 0.15 if q.author in last 3 seen authors
                           0.0  otherwise

// Weight sum: 0.45 + 0.30 + 0.10 + 0.10 + 0.05 = 1.00
// Penalty applied outside the weight sum.
```

### Behavioural Score (new user, no preference vector)

```
score(q) = normalised_affinity(q.cat) × 0.50
         + dwell_signal(q.cat)        × 0.20
         + random()                   × 0.15
         + challenge_boost(q)         × 0.10
         − author_penalty(q)

// Weight sum: 0.50 + 0.20 + 0.15 + 0.10 = 0.95 (noise + challenge)
// Penalty applied outside the weight sum.
```

---

## Feed Generation Pipeline

```
Client: GET /quotes/feed?lang=en&limit=20
                         │
                         ▼
        ┌─────────────────────────────────────────┐
        │  Parallel fetch (Promise.all)            │
        │   - user_profiles      (interest, goal)  │
        │   - user_preferences   (signals per cat) │
        │   - users              (is_premium)      │
        │   - daily_challenges   (today's cat)     │
        │   - user_preference_vectors (or null)    │
        └──────────────┬──────────────────────────┘
                       │
                       ▼
        Has preference vector?
            /                 \
          YES                  NO
           │                   │
           ▼                   ▼
    match_quotes RPC      get_feed_candidates RPC
    (ANN vector search    (category filter +
     + NOT EXISTS)         NOT EXISTS)
    Returns similarity     Returns pool of
    scores                 unseen candidates
           │                   │
           └─────────┬─────────┘
                     │
                     ▼
             JS Scoring layer
             Score every candidate
             Sort by score DESC
                     │
                     ▼
             Diversity cap
             (≤ 60% per category)
                     │
                     ▼
             Shuffle final batch
             (prevents category clustering)
                     │
                     ▼
             Mark as seen (upsert seen_quotes)
                     │
                     ▼
        Response: { data, next_cursor, has_more, algorithm }
```

---

## Candidate Retrieval: match_quotes RPC (Semantic)

```sql
SELECT
  q.*,
  1 - (q.embedding <=> query_embedding) AS similarity
FROM quotes q
WHERE q.lang       = p_lang
  AND q.embedding IS NOT NULL
  AND (p_is_premium OR q.is_premium = false)
  AND NOT EXISTS (
    SELECT 1 FROM seen_quotes sq
    WHERE sq.device_id = p_device_id
      AND sq.quote_id  = q.id
  )
ORDER BY q.embedding <=> query_embedding
LIMIT p_pool_size;
```

**Index supporting this query:**

```sql
CREATE INDEX idx_quotes_embedding_hnsw
  ON quotes USING hnsw (embedding vector_cosine_ops)
  WITH (m = 16, ef_construction = 64)
  WHERE embedding IS NOT NULL;
```

HNSW (Hierarchical Navigable Small World) provides approximate nearest-neighbour search in O(log n) with ~95% recall. For 5,500 quotes it returns results in < 5 ms.

---

## Candidate Retrieval: get_feed_candidates RPC (Behavioural Fallback)

```sql
SELECT q.*
FROM quotes q
WHERE q.lang = p_lang
  AND (p_is_premium OR q.is_premium = false)
  AND NOT EXISTS (
    SELECT 1 FROM seen_quotes sq
    WHERE sq.device_id = p_device_id
      AND sq.quote_id  = q.id
  )
LIMIT p_pool_size;
```

Both RPCs use NOT EXISTS (index-backed) instead of NOT IN. This eliminates:
- The 414 URI Too Long error above ~300 seen quotes
- Full-table scan caused by large NOT IN clause disabling the index

---

## Feed Composition & Diversity

**Pool size:** `take × 8` (typically 160 candidates for a 20-quote batch)

**Diversity cap:** no single category may fill more than **60%** of the returned batch:

```
max_per_category = ceil(take × 0.60) = 12 for take=20
```

If the cap leaves the batch under-filled (e.g. 90% of unseen quotes are stoicism), overflow items are used to complete the batch — empty slots are never returned.

**Final shuffle:** the selected batch is shuffled before returning to prevent category runs on screen.

---

## Skip Detection

```
is_skip = dwell_time_ms < 500 ms
```

Skips increment `skip_count(category)` which subtracts 2× from that category's affinity weight. A device that consistently dismisses philosophy quotes will see fewer philosophy quotes — without any explicit preference setting from the user.

---

## AI Weekly Insight: GET /insights/weekly

**Model:** `claude-haiku-4-5-20251001` (fast, cost-efficient, cached 24 h)

**Context passed to Claude:**
- Device's dominant category this week (from `user_preferences`)
- Philosophy map scores 0–100
- Up to 3 recently liked quotes (text + author)
- Reading streak and total reflections

**Output:** 2–3 sentences of personalised philosophical insight. Warm, direct, grounded. Not generic.

**Cache:** stored in `ai_insights` table. Re-generated only if cached entry is > 24 hours old.

**Example output:**
> "Your reading this week kept returning to the theme of inner control — the Stoic belief that how we respond is always within our power. You've logged a 7-day streak, which itself is a small act of discipline. Tonight, try this: before sleep, name one thing today that you could not control, and one thing you chose well."

**Cost estimate at 100k DAU:**
- 24-hour cache → max 100k generations/day
- Haiku: ~$0.80 per 1M input tokens, ~$4 per 1M output tokens
- ~300 input tokens + ~150 output tokens per request
- Cost per generation: ~$0.0009
- **Daily cost at 100k unique users: ~$90** (acceptable; less with cache hit rate)

---

## Embedding Model: Voyage AI voyage-3-lite

| Property | Value |
|---|---|
| Dimensions | 512 |
| Max input tokens | 512 |
| Pricing | ~$0.02 per 1M tokens |
| One-time seeding cost (5,500 quotes) | ~$0.002 |
| Per-user preference update | 1 embedding per high-signal event |
| Batch size | 128 inputs per API call |

**Input enrichment:** the embedding input is `"${quote.text} — ${author} [${category}]"` — adding author and category as context helps the model place quotes in the right semantic neighbourhood.

---

## Database Schema Additions

```sql
-- Migration 003
ALTER TABLE user_preferences ADD COLUMN vault_count    INT    DEFAULT 0;
ALTER TABLE user_preferences ADD COLUMN skip_count     INT    DEFAULT 0;
ALTER TABLE user_preferences ADD COLUMN total_dwell_ms BIGINT DEFAULT 0;

-- Migration 004
ALTER TABLE quotes ADD COLUMN embedding VECTOR(512);

CREATE TABLE user_preference_vectors (
  device_id    VARCHAR(100) PRIMARY KEY,
  vector       VECTOR(512) NOT NULL,
  signal_count INT DEFAULT 0,
  updated_at   TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE ai_insights (
  device_id    VARCHAR(100) PRIMARY KEY,
  insight      TEXT NOT NULL,
  generated_at TIMESTAMPTZ DEFAULT now()
);
```

---

## Key Indexes

| Index | Table | Purpose |
|---|---|---|
| `idx_quotes_embedding_hnsw` | `quotes(embedding)` HNSW | ANN similarity search |
| `idx_quotes_feed_free` | `quotes(lang, category, id) WHERE is_premium=false` | Free feed scan |
| `idx_seen_device_quote` | `seen_quotes(device_id, quote_id)` | NOT EXISTS lookup |
| `idx_prefs_device` | `user_preferences(device_id)` | Preference fetch |

---

## Performance Characteristics

### Phase 4 (current) — < 10k DAU

Current implementation works as-is. No additional infrastructure needed.

### Phase 6 — 100k DAU

| Bottleneck | Fix |
|---|---|
| Preference vector computation on every feed request | Pre-fetch from `user_preference_vectors` (already done) |
| `match_quotes` RPC latency | HNSW index handles this (< 5 ms) |
| Embedding updates on every swipe | Already fire-and-forget |
| Claude API cost | Cache 24 h (already implemented) |
| Swipe events table growth (1.1B rows/year) | Monthly partitioning via `PARTITION BY RANGE (created_at)` |

### Phase 7 — 1M+ DAU

| Strategy | Implementation |
|---|---|
| Pre-computed feeds | Background job computes top-50 candidates per device every 15 min; stores in Redis |
| Embedding pre-fetch | User vectors loaded into Redis on first session, TTL 30 min |
| Read replicas | Supabase Pro read replica for feed queries |
| Feed service extraction | Separate Node.js service for feed + embedding logic |

---

## Swipe Direction Canonical Reference

| Direction | Category | Feed influence |
|---|---|---|
| ↑ up | stoicism | Wisdom / inner resilience |
| → right | discipline | Growth / personal achievement |
| ← left | reflection | Life / emotion / meaning |
| ↓ down | philosophy | Existential / ideas / truth |

Defined in:
- `flutter_app/lib/core/constants/feed_constants.dart`
- `backend/src/db/seed.js` → `CAT_TO_DIR`
- `backend/src/db/migrations/002_fix_swipe_dir.sql`
- `ARCHITECTURE.md` Section 16

---

## Deployment Checklist

```
□ Run 003_feed_algorithm.sql in Supabase SQL Editor
□ Run 004_ai_feed.sql in Supabase SQL Editor
□ Add VOYAGE_API_KEY to .env
□ Add ANTHROPIC_API_KEY to .env
□ Run: npm run embed-quotes   (one-time — ~5 min for 5,500 quotes)
□ Deploy backend: npm install && npm start
□ Verify: GET /health returns { status: "ok" }
□ Verify: GET /quotes/feed?lang=en returns { algorithm: "behavioural" } for new device
□ Send 1 like event
□ Verify: GET /quotes/feed?lang=en returns { algorithm: "hybrid" } after vector is generated
```
