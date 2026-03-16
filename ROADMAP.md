# MindScrolling — Product Roadmap

**Last updated:** 2026-03-15
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
| 4 | Philosophy Map & Evolution | 🔄 In Progress |
| 5 | Premium & Content Packs | 🔜 Next |
| 6 | Scale to 100k Users | 📅 Planned |
| 7 | Scale to 1M+ Users | 📅 Future |

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
- [x] Premium unlock (one-time $2.99)
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
- `frontend/src/components/` — Onboarding, Settings, PhilosophyMap, DailyChallenge, EvolutionCard, DonationPanel

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

### Product Milestones
- [ ] Philosophy Map with animated score bars
- [ ] Weekly evolution delta (before/after comparison)
- [ ] "Your philosophy this week" summary card in feed
- [ ] Radar chart visualization (Stoicism / Philosophy / Discipline / Reflection quadrants)
- [ ] Snapshot history (scroll through past weeks)
- [ ] Insight messages: "You've been exploring Stoicism more this week"

### Technical Milestones
- [ ] Materialized score view or scheduled score computation
- [ ] Evolution card injected into feed at interval (every 10 quotes)
- [ ] Snapshot comparison endpoint (`/map?compare=last`)
- [ ] Push notification: "Your weekly philosophy map is ready"
- [ ] Flutter radar chart widget (CustomPainter)

### Key Deliverables
- Enhanced `PhilosophyMapScreen` with radar + history
- Evolution cards in `FeedScreen`
- Weekly insight generation (backend or local)

---

## Phase 5 — Premium & Content Packs

**Goal:** Establish a sustainable revenue model and significantly expand the content library.

### Product Milestones
- [ ] Payment integration (RevenueCat or direct Stripe)
- [ ] Premium receipt validation
- [ ] Content packs (purchasable or included in premium):
  - Stoicism Deep Dive (500+ quotes, Marcus Aurelius, Seneca, Epictetus)
  - Zen Buddhism (300+ quotes)
  - Existentialism (300+ quotes, Camus, Sartre, Nietzsche)
  - Spanish Philosophy (500+ ES quotes)
- [ ] Pack preview (see locked quotes, upgrade prompt)
- [ ] Restore purchases flow

### Technical Milestones
- [ ] Purchases table integration with receipt validation
- [ ] Pack-gated quotes in feed query
- [ ] RevenueCat SDK integration in Flutter
- [ ] Backend webhook for purchase events
- [ ] 2,000+ additional quotes curated and seeded

### Key Deliverables
- `premium_screen.dart` — full purchase flow
- `backend/routes/premium.js` — receipt validation
- 4 new content packs in database
- 2,000+ new quotes

---

## Phase 6 — Scale to 100k Users

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

## Phase 7 — Scale to 1M+ Users

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
