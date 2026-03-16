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
 ├── LEFT  → Stoicism
 ├── RIGHT → Discipline
 ├── UP    → Philosophy
 └── DOWN  → Reflection
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
user_pref_snapshots ← Weekly evolution snapshots
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

## 8. Adaptive Philosophical Feed Engine

### Scoring Formula

```
score(quote) =
  (category_affinity   × 0.35)   // weighted by like×3 + swipe + base_5
  + (onboarding_boost  × 0.15)   // interest match from profile
  + (goal_match        × 0.10)   // goal-to-category affinity
  + (like_history      × 0.10)   // category liked most historically
  + (random_novelty    × 0.05)   // exploration factor
  - author_repeat_penalty        // -0.1 if same author in last 3 seen
  - premium_gate                 // exclude is_premium=true for free users
```

### Algorithm Flow

```
User Signals (swipes, likes, dwell time)
            │
            ▼
    Preference Model
    ┌─────────────────────────────┐
    │ user_preferences table      │
    │ like_count × 3 per category │
    │ swipe_count × 1 per category│
    │ base weight = 5             │
    └────────────┬────────────────┘
                 │
                 ▼
    Onboarding Boost
    ┌─────────────────────────────┐
    │ user_profiles.interest      │
    │ match → +10 to affinity     │
    │ user_profiles.goal          │
    │ match → +8 to affinity      │
    └────────────┬────────────────┘
                 │
                 ▼
    Feed Ranking (SQL + Node scoring)
    ┌─────────────────────────────┐
    │ Exclude seen_quotes         │
    │ Apply premium gate          │
    │ Score each candidate        │
    │ Sort by score DESC          │
    │ Apply author repeat penalty │
    │ Paginate with cursor        │
    └────────────┬────────────────┘
                 │
                 ▼
    Quote Delivery (20 per batch)
                 │
                 ▼
    New Signals → loop
```

### Feed Composition (per batch of 20)

```
12 quotes  → dominant category (highest affinity)
 4 quotes  → secondary category
 2 quotes  → exploration (lowest affinity, random)
 2 slots   → special cards (challenge card / evolution card)
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
User taps "Support MindScroll"
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

| Stage | DAU | Architecture change |
|---|---|---|
| Current | 0–500 | Supabase free tier, Railway starter |
| Phase 6 | 10k–100k | Supabase Pro, connection pooling (pgBouncer), CDN for quote assets |
| Phase 7 | 100k–1M | Read replicas, Redis cache for feed, background job queue, push notifications |

### Bottlenecks to address at scale

1. **Feed query** — currently full-table scan with exclusion. At 100k users: partition seen_quotes by device, add partial indexes, consider Redis for hot feeds.
2. **Swipe events** — high write volume. At 100k DAU: batch writes, async queue (BullMQ or similar).
3. **Philosophy map** — computed on every request. At scale: materialize scores via cron job, serve from cache.

---

## 15. Future Evolution

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
