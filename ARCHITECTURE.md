# MindScrolling — Architecture

**Version:** Sprint 5 (Flutter migration)
**Last updated:** 2026-03-15

---

## 1. Overview

MindScrolling is a cross-platform mobile application built on a clean three-tier architecture:

```
┌─────────────────────────────────┐
│       Flutter Mobile Client     │  iOS + Android
│  Riverpod · GoRouter · Clean    │
└──────────────┬──────────────────┘
               │ REST / JSON
               │ X-Device-ID header
┌──────────────▼──────────────────┐
│       Fastify REST Backend      │  Node.js 20+
│  Rate limiting · Device auth    │
└──────────────┬──────────────────┘
               │ Supabase client
┌──────────────▼──────────────────┐
│    PostgreSQL via Supabase      │  Free tier → scalable
│  RLS · Functions · Indexes     │
└─────────────────────────────────┘
```

The system is intentionally thin — no user accounts, no auth tokens, no OAuth flows. Identity is established via a UUID v4 device ID generated on first launch and stored in secure device storage.

---

## 2. Product Architecture

```
User
 │
 ▼
Swipe Gesture (4 directions)
 │
 ├── UP    → Stoicism / Wisdom
 ├── RIGHT → Discipline / Growth
 ├── LEFT  → Reflection / Life
 └── DOWN  → Philosophy / Existential
 │
 ▼
Swipe Event Recorded
 │
 ├── Updates preference weights (local + remote)
 ├── Increments streak and reflections
 └── Feeds into adaptive algorithm on next load
 │
 ▼
Next Quote Delivered (scored and ranked)
```

---

## 3. Repository Structure

```
MindScrolling/
├── flutter_app/           Mobile client (primary product)
│   ├── lib/
│   │   ├── app/           Theme, router, localization
│   │   ├── core/          Constants, network, storage, utils, analytics
│   │   ├── data/          Models, remote/local datasources, repositories
│   │   ├── features/      bootstrap · onboarding · feed · swipe ·
│   │   │                  vault · philosophy_map · challenges ·
│   │   │                  premium · donations · profile · settings ·
│   │   │                  share_export
│   │   └── shared/        Reusable widgets, BuildContext extensions
│   ├── android/
│   ├── ios/
│   └── pubspec.yaml
│
├── backend/               REST API server
│   └── src/
│       ├── app.js         Fastify server bootstrap
│       ├── routes/        One file per domain
│       ├── plugins/       Shared middleware
│       └── db/
│           ├── migrations/ SQL schema
│           └── seed.js    Quote seeder (5,500 quotes)
│
├── frontend_legacy/       Original React/Vite app (reference only)
│
├── ARCHITECTURE.md        This document
├── CONTRIBUTING.md
├── ROADMAP.md
└── SCRUM.md               Sprint history
```

---

## 4. Backend Architecture

### Server

```
app.js
 ├── @fastify/cors          → ALLOWED_ORIGIN whitelist
 ├── @fastify/rate-limit    → 60 req/min per IP
 ├── plugins/deviceId.js   → Injects device_id from X-Device-ID header
 └── routes/
     ├── quotes.js          → GET /quotes/feed (adaptive algorithm)
     ├── likes.js           → POST /quotes/:id/like
     ├── vault.js           → GET/POST/DELETE /vault
     ├── stats.js           → GET /stats
     ├── profile.js         → GET/POST /profile
     ├── swipes.js          → POST /swipes
     ├── challenges.js      → GET /challenges/today · POST progress
     ├── map.js             → GET /map · POST /map/snapshot
     └── premium.js         → GET /premium/status · POST /unlock
```

### Request Flow

```
Flutter App
    │
    │  GET /quotes/feed?lang=en&cursor=<uuid>
    │  Headers: { X-Device-ID: <uuid> }
    │
    ▼
Fastify Server
    │
    ├── Rate limit check (60/min)
    ├── Extract device_id from header
    ├── Upsert user record (create if first visit)
    │
    ▼
Adaptive Feed Algorithm
    │
    ├── Load user_preferences (category weights)
    ├── Load user_profiles (onboarding: interest, goal)
    ├── Load seen_quotes (exclusion list)
    ├── Score and rank quotes
    ├── Apply premium gate
    ├── Paginate with cursor
    │
    ▼
Response: { data: [...quotes], next_cursor, has_more }
```

---

## 5. Flutter Mobile Architecture

The Flutter app follows a strict layered clean architecture:

```
lib/
 ├── app/          ← Composition root: theme, router, localization
 ├── core/         ← Pure infrastructure (no Flutter widgets)
 ├── data/         ← All I/O: network + local storage
 ├── features/     ← UI + business logic per screen
 └── shared/       ← Generic, reusable UI components
```

### Dependency Direction

```
features → data → core
shared   → core
app      → features, core
```

Features never import other features directly. Cross-feature navigation goes through GoRouter.

### State Management

Riverpod 2.x with `@riverpod` code generation:

```
UI Widget (ConsumerWidget)
    │
    ▼
StateNotifierProvider (e.g. feedControllerProvider)
    │
    ▼
StateNotifier<FeedState>
    │
    ▼
Repository (e.g. FeedRepository)
    │
    ├── RemoteDataSource  → HTTP calls via ApiClient
    └── LocalDataSource   → SharedPreferences / CacheStorage
```

---

## 6. Database Schema Summary

```
quotes              ← 5,500+ philosophical quotes (EN + ES)
users               ← Device-based user records + streak
likes               ← Quote likes per device
vault               ← Saved quotes per device
user_preferences    ← Category weights (like + swipe counts + scores)
seen_quotes         ← Feed exclusion list per device
user_profiles       ← Onboarding data (age, interest, goal, lang)
swipe_events        ← Raw swipe log with dwell time
user_preference_snapshots ← Weekly evolution snapshots
daily_challenges    ← One challenge per calendar date
challenge_progress  ← Per-device progress per challenge
purchases           ← Premium unlock records
```

### Key Indexes

```sql
idx_quotes_category_lang     ON quotes(category, lang)
idx_quotes_text_author       ON quotes(text, author)   -- UNIQUE
idx_likes_device             ON likes(device_id)
idx_seen_device              ON seen_quotes(device_id)
idx_swipe_events_device      ON swipe_events(device_id)
idx_snapshots_device         ON user_preference_snapshots(device_id)
idx_challenges_date          ON daily_challenges(active_date)
```

---

## 7. Core Domain Entities

```
QuoteModel
  id          UUID
  text        String
  author      String
  category    stoicism | philosophy | discipline | reflection
  lang        en | es
  swipe_dir   left | right | up | down
  pack_name   free | stoicism_pack | zen_pack | ...
  is_premium  Boolean

UserProfileModel
  device_id         String (UUID v4)
  age_range         18-24 | 25-34 | 35-44 | 45+
  interest          philosophy | stoicism | personal_growth | ...
  goal              calm_mind | discipline | meaning | emotional_clarity
  preferred_language en | es

PhilosophyMapModel
  wisdom_score      0–100
  discipline_score  0–100
  reflection_score  0–100
  philosophy_score  0–100
  snapshot          previous period scores (for delta display)
```

---

## 8. AI-Enhanced Philosophical Feed Engine

Full specification: [FEED_ALGORITHM.md](FEED_ALGORITHM.md)

The feed operates in two modes determined by the device's interaction history:

| Mode | Condition | Retrieval |
|---|---|---|
| **Behavioural** | New user — no preference vector | Category affinity → `get_feed_candidates` RPC |
| **Hybrid (AI)** | Returning user — preference vector built | Semantic ANN search → `match_quotes` RPC |

Transition from behavioural → hybrid is silent and automatic after the first like, vault save, or 5-second dwell.

### Dual Signal Model

```
Behavioural Layer                    Semantic Layer
─────────────────                    ──────────────
user_preferences table               user_preference_vectors table
  like_count    × 3                  512-dim EMA vector
  vault_count   × 5  (strongest)     Updated by: like (α=0.20)
  swipe_count   × 1                             vault (α=0.25)
  skip_count    × −2                            dwell ≥5s (α=0.10)
  total_dwell_ms                     Voyage AI voyage-3-lite embeddings
```

### EMA Preference Vector Update

```
v_new = L2_normalize( (1−α) × v_current  +  α × v_quote )

α:  vault save = 0.25  (strongest intent signal)
    like       = 0.20
    long dwell = 0.10  (≥ 5 seconds reading time)
```

All vector updates are **fire-and-forget** — never block the API response.

### Scoring Formulas

**Hybrid (returning user):**
```
score(q) = semantic_similarity(q)      × 0.45   // cosine sim via HNSW index
         + normalised_affinity(q.cat)  × 0.30   // behavioural category weight
         + dwell_signal(q.cat)         × 0.10   // avg_dwell / 4000ms, 0-1
         + random()                    × 0.10   // exploration noise
         + challenge_boost(q)          × 0.05   // 1 if category = today's challenge
         − author_penalty(q)                    // −0.15 for recent author repeat

// Weights sum to 1.0
```

**Behavioural (new user):**
```
score(q) = normalised_affinity(q.cat) × 0.50
         + dwell_signal(q.cat)        × 0.20
         + random()                   × 0.15
         + challenge_boost(q)         × 0.10
         − author_penalty(q)

// Weights sum to 0.95 + up to 0.10 challenge
```

### Algorithm Flow

```
Device Signals (swipes, likes, vault saves, dwell time)
                         │
                         │  fire-and-forget: updatePreferenceVector()
                         ├──────────────────────────────────────────►  user_preference_vectors
                         │
                         ▼
                  parallel Promise.all
        ┌──────────────────────────────────┐
        │  user_profiles  (onboarding)     │
        │  user_preferences (signals)      │
        │  users           (is_premium)    │
        │  daily_challenges (today cat)    │
        │  user_preference_vectors (vec?)  │
        └──────────────┬───────────────────┘
                       │
            has preference vector?
               /                \
             YES                 NO
              │                  │
    match_quotes RPC    get_feed_candidates RPC
    (ANN cosine sim +   (category filter +
     NOT EXISTS)         NOT EXISTS)
    returns similarity   returns pool
              │                  │
              └─────────┬────────┘
                        │
                   JS Scoring
                   Sort DESC
                   Diversity cap (≤ 60%/cat)
                   Shuffle
                        │
                   upsert seen_quotes
                        │
                   Response { data, algorithm }
```

### AI Weekly Insight: GET /insights/weekly

**Model:** `claude-haiku-4-5-20251001`
**Cache:** 24-hour TTL in `ai_insights` table

Input context: dominant category, philosophy map scores, 3 recently liked quotes, streak + total reflections.

Output: 2–3 sentences of personalised philosophical guidance generated by Claude. Cached per device for 24 hours. Gracefully absent if `ANTHROPIC_API_KEY` not configured.

### Feed Composition (per batch of 20)

```
≤ 12 quotes  → dominant categories (60% cap per category)
≥  3 quotes  → low-affinity categories (diversity floor via overflow)
   noise     → random() component ensures non-dominant quotes always surface
```

---

## 9. Swipe Event Flow

```
User drags card
      │
      ▼
SwipeGestureHandler detects direction
(threshold: 60px horizontal / 60px vertical)
      │
      ▼
FeedController.onSwipe(direction)
      │
      ├── Calculate dwell time (ms since card appeared)
      ├── Update streak + reflections count (local state)
      ├── Update swipeCounts map (local state)
      │
      ▼
SwipeEventModel created
{ quoteId, direction, category, dwellTimeMs }
      │
      ▼
FeedRepository.recordSwipe(event)  ← fire-and-forget
      │
      ▼
POST /swipes
      │
      ├── Insert into swipe_events
      ├── Upsert user_preferences (swipe_count++)
      ├── Increment wisdom/discipline/reflection/philosophy_score
      ├── Update streak (same-day / yesterday / reset logic)
      └── Update total_reflections
```

---

## 10. Philosophy Map Architecture

### Score Computation

```
For each category C in {stoicism, philosophy, discipline, reflection}:

  raw_score(C) = like_count(C) × 3
               + swipe_count(C) × 1
               + wisdom/discipline/reflection/philosophy_score(C)

  normalized_score(C) = (raw_score(C) / max_raw_score_across_all_C) × 100
```

### Evolution Snapshot Flow

```
User taps "Save Snapshot"
      │
      ▼
POST /map/snapshot
      │
      ▼
Read current user_preferences scores
      │
      ▼
INSERT into user_preference_snapshots
{ wisdom, discipline, reflection, philosophy, created_at }
      │
      ▼
GET /map returns:
  current: { wisdom: 72, discipline: 45, ... }
  snapshot: { wisdom: 60, discipline: 30, ... }  ← previous
  delta: { wisdom: +12, discipline: +15, ... }
```

---

## 11. Daily Challenge Architecture

```
Daily Challenge Table
  code        VARCHAR(50) UNIQUE   ← e.g. "stoic_morning_reflection"
  title       VARCHAR(150)
  description TEXT
  active_date DATE                 ← one challenge per day

GET /challenges/today
  │
  ├── SELECT WHERE active_date = CURRENT_DATE
  ├── Fallback: return hardcoded default challenge
  └── JOIN challenge_progress WHERE device_id = $device_id

POST /challenges/:id/progress
  │
  └── UPSERT challenge_progress
      { device_id, challenge_id, progress, completed }
```

---

## 12. Premium and Donation Architecture

### Premium Model

```
One-time unlock: $2.99 USD (no recurring charges)

Free tier:
  └── 200 free quotes (pack_name = 'free')

Premium tier:
  └── 5,000+ quotes (all pack_names)
  └── Export quote as image (canvas 1080×1080)
  └── Philosophy map with evolution history

POST /premium/unlock
  │
  ├── INSERT into purchases
  └── UPDATE users SET is_premium = true

GET /premium/status
  │
  └── CHECK users.is_premium AND purchases record
```

### Donation Flow

```
User taps "Support MindScrolling"
      │
      ▼
url_launcher opens DONATION_LINK
(external: Buy Me a Coffee / Ko-fi)
      │
No backend involvement — fully external
```

---

## 13. Multilanguage Strategy

```
Language detection priority:
  1. User preference saved in settings (SharedPreferences)
  2. Device locale (Platform.localeName)
  3. Fallback: "en"

Quote serving:
  GET /quotes/feed?lang=en   ← Backend filters by lang column
  GET /quotes/feed?lang=es   ← Serves Spanish dataset (1,375 quotes)

UI strings:
  flutter_app/lib/app/localization/
    strings_en.dart    ← English
    strings_es.dart    ← Spanish
    app_strings.dart   ← Abstract base

Price localization (display only):
  USD: $2.99
  MXN: $59
  BRL: R$14.90
  ARS: $2,800
  EUR: €2.79
  (Actual charge always in USD via payment provider)
```

---

## 14. Scalability Plan

> Full stress test analysis with code-level findings: [SCALABILITY.md](SCALABILITY.md)

| Stage | DAU | Rating | Primary action |
|---|---|---|---|
| Phase 1 | 0–1k | ✅ Ready | No changes needed |
| Phase 2 | 1k–10k | ⚠️ Optimize | Parallelize feed queries (Promise.all), fix UUID cursor |
| Phase 3 | 10k–100k | ❌ Requires work | Replace NOT IN with NOT EXISTS RPC, partition swipe_events, add Redis |
| Phase 4 | 100k–1M | ❌ Major changes | Precomputed feed, read replicas, swipe event queue, service decomposition |

### Concrete bottlenecks identified in code

1. **`GET /quotes/feed` makes 7 sequential DB round-trips** — queries 1–4 are independent and can be parallelized with `Promise.all()`. Saves ~30ms per request.
2. **Cursor uses UUID `gt()` comparison** — UUIDs are random strings; lexicographic comparison is non-deterministic. Bug at every scale. Fix: use `created_at` timestamp cursor.
3. **NOT IN with 500 UUIDs in URL** — causes `414 URI Too Long` once a user has 300+ seen quotes. Fix: server-side `NOT EXISTS` subquery via Supabase RPC.
4. **`POST /swipes` makes 5 sequential DB round-trips** — queries 1 and 4 (user read, prefs read) can be parallelized.
5. **`swipe_events` grows unbounded** — 100k DAU generates 1.1B rows/year. Requires monthly partitioning before Phase 3.
6. **Rate limiting is IP-based** — shared mobile carrier NAT blocks legitimate users at scale. Fix: key by `X-Device-ID`.
7. **No caching** — every feed request hits the database. At Phase 3, precompute ranked feed per user via background job and serve from a `pre_computed_feed` table.

---

## 15. API Error Contract

> Full endpoint specification: [API_CONTRACT.md](API_CONTRACT.md)

All backend endpoints return errors in a consistent JSON envelope:

```json
{
  "error": "Human-readable message",
  "code": "MACHINE_READABLE_CODE"
}
```

### Error codes

| HTTP | Code | Meaning |
|---|---|---|
| 400 | `INVALID_BODY` | Request body failed validation |
| 400 | `MISSING_FIELD` | Required field absent from body |
| 400 | `INVALID_DIRECTION` | `direction` not in `{up, down, left, right}` |
| 401 | `MISSING_DEVICE_ID` | `X-Device-ID` header absent |
| 404 | `NOT_FOUND` | Resource does not exist |
| 409 | `ALREADY_EXISTS` | Duplicate resource (e.g. vault duplicate) |
| 429 | `RATE_LIMITED` | Exceeded 60 requests per minute |
| 500 | `INTERNAL_ERROR` | Unexpected server error |

### Special cases

- `POST /vault` with an already-saved quote returns `200` (not `409`) with `{ "status": "already_saved" }`.
- `POST /premium/unlock` is idempotent — calling it twice for the same device returns `200` both times.
- `GET /profile` returns `null` (not 404) when no profile exists yet.
- `GET /challenges/today` returns a hardcoded default challenge (not 404) when no challenge is scheduled.

---

## 16. Canonical Swipe Direction Reference

This table is the **single source of truth** for direction → category mapping across all layers.

| Direction | Category | `swipe_dir` in DB | Flutter `directionToCategory` |
|---|---|---|---|
| ↑ up | stoicism | `up` | `'up' → 'stoicism'` |
| → right | discipline | `right` | `'right' → 'discipline'` |
| ← left | reflection | `left` | `'left' → 'reflection'` |
| ↓ down | philosophy | `down` | `'down' → 'philosophy'` |

**Implementation locations:**
- Flutter: `flutter_app/lib/core/constants/feed_constants.dart` → `directionToCategory`
- Backend seed: `backend/src/db/seed.js` → `CAT_TO_DIR`
- DB migration: `backend/src/db/migrations/002_fix_swipe_dir.sql`

> Any change to this mapping requires updating all three locations simultaneously.

---

## 17. Future Evolution

| Area | Planned direction |
|---|---|
| Auth | Optional Google/Apple sign-in for cross-device sync |
| Content | Curated packs: Stoicism Deep Dive, Zen Buddhism, Existentialism |
| Social | Optional sharing of Philosophy Map to social media |
| AI | Claude-powered daily quote generation tailored to user profile |
| Notifications | Daily reminder push notification at user-set time |
| Widgets | iOS/Android home screen widget with daily quote |
| Analytics | Cohort retention, most-liked quotes, category trends |
| API | Public quote API for third-party developers |
