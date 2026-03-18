# MindScrolling — Product Roadmap

**Last updated:** 2026-03-18
**Methodology:** Continuous delivery with sprint-based milestones

---

## Guiding Principle

Every phase must leave the product meaningfully more valuable to the user — not just more complex. We ship working software, learn from real usage, and build the next phase on evidence, not assumptions.

---

## Phase Overview

| Phase | Name | Status |
|---|---|---|
| 1 | MVP Foundation | ✅ Complete |
| 2 | Intelligent Feed & Onboarding | ✅ Complete |
| 3 | Flutter Mobile Migration | ✅ Complete |
| 4 | Philosophy Map & Evolution | ✅ Complete |
| 5 | Premium & Content Packs | ✅ Complete (v1 — trial + one-time unlock) |
| 6 | Google Play Launch + Retention | 🔄 In Progress (Sprint 7) |
| 7 | Content Depth & Growth | 🔜 Next (Sprint 8) |
| 8 | Scale to 100k Users | 📅 Planned |
| 9 | Scale to 1M+ Users | 📅 Future |

---

## Phase 1 — MVP Foundation

**Goal:** A working philosophical swipe app, functional without a backend.

### Product Milestones
- [x] 4-direction swipe mechanic (left/right/up/down)
- [x] Quote cards with author and category
- [x] Streak counter (local)
- [x] Reflection counter (local)
- [x] Vault (save quotes locally)
- [x] Share via Web Share API + clipboard fallback
- [x] Static quote dataset (EN + ES)

### Technical Milestones
- [x] React + Vite single-file prototype
- [x] localStorage persistence for vault, streak, liked
- [x] Device language detection
- [x] Quote shuffle and pagination
- [x] Bug-free swipe counter logic

### Key Deliverables
- `MindScroll_MVP.jsx` (stable, bug-free)
- 32 curated ES quotes + 100+ EN quotes

---

## Phase 2 — Intelligent Feed & Onboarding

**Goal:** Real backend, adaptive algorithm, user profiling, premium infrastructure.

### Product Milestones
- [x] 3-screen onboarding (guide → profile → start)
- [x] User profile: age range, interest, goal, language
- [x] Daily challenge with progress tracking
- [x] Philosophy Map (category score bars)
- [x] Evolution snapshots (week-over-week delta)
- [x] Premium unlock (one-time $2.99 → updated to $4.99 in Sprint 6, see Pricing Decision Record)
- [x] Donation panel (Buy Me a Coffee)
- [x] Export quote as image (canvas 1080×1080, premium)
- [x] Full EN/ES localization (i18n system)
- [x] Localized price display (USD/MXN/BRL/ARS/EUR)

### Technical Milestones
- [x] PostgreSQL schema (12 tables)
- [x] Fastify REST API (15 endpoints)
- [x] Adaptive feed scoring formula
- [x] Swipe event logging with dwell time
- [x] Preference weights (like×3 + swipe + base_5)
- [x] 5,500 philosophical quotes seeded (EN)
- [x] Author repeat penalty
- [x] Premium gate in feed query

### Key Deliverables
- `backend/src/routes/` — 9 route files
- `backend/src/db/migrations/001_initial.sql` — 12 tables
- `backend/src/db/seed.js` — v5, 5,500 quotes, resume-safe
- `frontend_legacy/src/components/` — Onboarding, Settings, PhilosophyMap, DailyChallenge, EvolutionCard, DonationPanel

---

## Phase 3 — Flutter Mobile Migration

**Goal:** Replace the React web app with a native Flutter mobile application for iOS and Android.

### Product Milestones
- [x] Feature parity with React version
- [x] Native swipe gestures (flutter_card_swiper)
- [x] Dark theme with category accent colors
- [x] Playfair Display + DM Sans typography
- [x] Bottom navigation (Feed / Vault / Map / Settings)
- [x] Share + Export (share_plus, screenshot)
- [x] Offline fallback (cached feed)

### Technical Milestones
- [x] Clean architecture: app / core / data / features / shared
- [x] Riverpod 2.x state management
- [x] GoRouter navigation (10 routes)
- [x] ApiClient with device ID injection
- [x] TTL-based feed cache
- [x] SharedPreferences + flutter_secure_storage
- [x] All 12 features implemented as isolated modules
- [x] Android + iOS platform configuration
- [x] React frontend preserved as `frontend_legacy/`

### Key Deliverables
- `flutter_app/` — 97+ Dart files across 5 layers
- `flutter_app/pubspec.yaml` — 14 dependencies
- `ARCHITECTURE.md` — full system documentation
- `SCRUM.md` — Sprint 5 section added

---

## Phase 4 — Philosophy Map & Evolution

**Goal:** Turn the Philosophy Map into the app's signature retention feature.

**Status: Complete as of Sprint 6.**

### Product Milestones
- [x] Philosophy Map with radar chart visualization
- [x] Radar chart (Stoicism / Philosophy / Discipline / Reflection quadrants)
- [x] Mental state labels on map
- [ ] Weekly evolution delta (before/after comparison) — deferred to Sprint 8
- [ ] Evolution card injected into feed every 10 quotes — deferred to Sprint 8
- [ ] Snapshot history (scroll through past weeks) — deferred to Sprint 8

### Key Deliverables
- `PhilosophyMapScreen` with CustomPainter radar chart
- AI Weekly Insight gated behind MindScrolling Inside premium

---

## Phase 5 — Premium & Content Packs

**Goal:** Establish a sustainable revenue model and significantly expand the content library.

**Status: v1 complete as of Sprint 6. Content packs and pack browser deferred to Sprint 8.**

### Pricing Model (v2 — 2026-03-18, supersedes 2026-03-17 decision)
Two-tier monetization: individual packs at $2.99 USD each, and MindScrolling Inside at $4.99 USD as the value anchor (all packs + premium features). No subscriptions, no tiered gating.
Inside regional prices: MXN $79 / BRL $19.90 / ARS automatic / COP $19,900 / EUR $4.49 / CAD $6.99.
Individual pack regional prices: MXN $49 / BRL $14.90 / EUR $2.69 / CAD $3.99 / COP $12,900 / ARS automatic.
Grandfathering: existing Inside users get the 3 current packs at no extra cost. Future packs are always $2.99 for everyone.
See BACKLOG.md Pricing Decision Record v2 and SCOPE_BLOCK_B_PACK_MONETIZATION.md for full rationale.

### Product Milestones (v1 — Complete)
- [x] MindScrolling Inside premium ($4.99 one-time unlock)
- [x] 7-day free trial (server-side protected)
- [x] Activation code system for donors
- [x] Restore purchases flow (RevenueCat)
- [x] AI Weekly Insight gated behind premium
- [ ] Pack catalog UI with per-entitlement state badges (Bloque B, Sprint 8) — supersedes "single Unlock All CTA" from v1
- [ ] Pack preview flow: 5 quotes (Free) / 15 quotes (Trial) / full 500 (entitled) with appropriate paywalls (Bloque B, Sprint 8)
- [ ] Individual pack purchase at $2.99 via RevenueCat (Bloque B, Sprint 8)
- [ ] Inside as value anchor: paywall always shows both $2.99 and $4.99 options (Bloque B, Sprint 8)
- [ ] Grandfathering: existing Inside users get current 3 packs automatically (Bloque B, Sprint 8)
- [ ] Content packs: Stoicism Deep Dive, Existentialism, Zen & Mindfulness — verify 500 EN + 500 ES each in DB (Sprint 8)
- [ ] New content pack: Spanish Philosophy (Sprint 8-9)
- [ ] Trial quota enforcement: 1,000 quotes or 7 days (Bloque C, Sprint 8)

### Key Deliverables
- `premium_controller.dart` — trial + purchase + restore state machine
- `backend/routes/premium.js` — `/status`, `/start-trial`, `/unlock` endpoints
- `PremiumPurchaseService` — RevenueCat integration

---

## Phase 6 — Google Play Launch + Retention

**Goal:** Ship to real users on Google Play, protect the revenue funnel, and establish the first retention loop.

### Product Milestones
- [ ] Google Play Store submission and approval
- [ ] Backend deployed to Railway production (no cold starts)
- [ ] pgvector enabled + AI feed fully operational
- [ ] Trial-to-paid conversion funnel instrumented
- [ ] Push notifications: daily reminder at user-set time
- [ ] "Your weekly map is ready" weekly re-engagement notification
- [ ] Vault export as plain text (free — drives word of mouth)
- [ ] Price localization audit (MXN / BRL / ARS)

### Technical Milestones
- [ ] Sentry error tracking on backend
- [ ] Feed query optimization (partial indexes)
- [ ] Server-side funnel events: trial_started / trial_expired / premium_purchased
- [ ] Railway production deployment with health check

### Key Deliverables
- Live Google Play listing
- Production backend on Railway
- Conversion analytics pipeline

---

## Phase 7 — Content Depth & Growth

**Goal:** Give users a reason to stay beyond the first 30 days through deeper content and richer personal context.

### Product Milestones
- [ ] Pack monetization new architecture — Bloque B (scope: SCOPE_BLOCK_B_PACK_MONETIZATION.md)
- [ ] Content packs: Stoicism Deep Dive, Existentialism, Zen & Mindfulness, Spanish Philosophy
- [ ] Author deep-dive cards (bio + top 5 quotes, premium)
- [ ] "Today's reflection" daily question card injected into feed
- [ ] Evolution card in feed every 10 quotes ("Your philosophy shifted this week")
- [ ] Vault collections (themed folders)
- [ ] Streak milestone moments (7 / 30 days): full-screen card only, no badge
- [ ] iOS App Store submission

### Technical Milestones
- [ ] 2,000+ additional curated quotes seeded for content packs
- [ ] Pack-gated feed query (premium required for pack quotes)
- [ ] Daily question rotation system (backend-driven)
- [ ] Snapshot history comparison endpoint (`/map?compare=last`)

### Key Deliverables
- 4 content packs live in database
- Author deep-dive cards in `FeedScreen`
- Live iOS listing

---

## Phase 8 — Scale to 100k Users

**Goal:** The infrastructure reliably serves 100k daily active users with sub-200ms feed responses.

### Product Milestones
- [ ] Push notifications (daily reminder at user-set time)
- [ ] iOS/Android home screen widget (daily quote)
- [ ] Social sharing of Philosophy Map (image export)
- [ ] Content moderation for any UGC

### Technical Milestones
- [ ] Supabase Pro (connection pooling via pgBouncer)
- [ ] Redis cache for hot feeds (most popular quotes per category)
- [ ] Feed query optimization (partial indexes, EXPLAIN ANALYZE)
- [ ] Background job queue for swipe event processing (BullMQ)
- [ ] CDN for font and image assets
- [ ] Structured logging + error tracking (Sentry)
- [ ] Performance monitoring (p50/p95/p99 latency dashboards)
- [ ] Load testing suite (k6 or Artillery)

### Key Deliverables
- Deployment on Railway or Render with auto-scaling
- Redis integration for feed caching
- Monitoring dashboard
- Load test results confirming 100k DAU capacity

---

## Phase 9 — Scale to 1M+ Users

**Goal:** MindScrolling operates as a resilient, globally distributed product at million-user scale.

### Product Milestones
- [ ] Optional Google/Apple sign-in for cross-device sync
- [ ] Community features: "This week's most swipe-right quote"
- [ ] AI-powered personalized daily insight (Claude API integration)
- [ ] Public API for developers (philosophical quote API)
- [ ] Web version rebuilt (PWA or Next.js)
- [ ] Localization to 5+ languages (FR, DE, PT, JA, ZH)

### Technical Milestones
- [ ] Read replicas for feed queries
- [ ] Materialized views for preference scores (refreshed every 15 min)
- [ ] Event streaming for swipe analytics (Kafka or Redpanda)
- [ ] Microservice extraction: feed service, notification service
- [ ] Multi-region deployment (US + EU + LATAM)
- [ ] Supabase Enterprise or self-hosted PostgreSQL
- [ ] CI/CD pipeline with automated Flutter builds (GitHub Actions + Fastlane)
- [ ] A/B testing framework for feed algorithm variants

### Key Deliverables
- Multi-region infrastructure
- Event streaming pipeline
- Claude API integration for daily insight generation
- iOS App Store + Google Play listings

---

## Won't Build (Explicit Non-Goals)

These are permanently out of scope unless the product thesis fundamentally changes:

| Item | Reason |
|---|---|
| Mandatory user accounts | Kills frictionless onboarding |
| Social feed / likes visible to others | Turns philosophy into performance |
| Advertising | Contradicts the anti-doom-scrolling mission |
| Subscription model | One-time purchase aligns incentives better |
| Gamification (badges, leaderboards) | Undermines genuine reflection |
| User-generated content (public) | Content quality is non-negotiable |

---

*The roadmap reflects our best current understanding of what will create value. It evolves as we learn. No commitment implied beyond the current sprint.*
