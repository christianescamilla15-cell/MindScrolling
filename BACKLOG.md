# MindScrolling — Backlog
**Last updated:** 2026-03-15 | Sprint 5 state

> Sprints 0–4 are complete. This document tracks remaining work from Sprint 5 onward.
> Historical sprint tasks are recorded in [SCRUM.md](SCRUM.md).

---

## Sprint 5 — Flutter Migration (In Progress)

See [SCRUM.md Sprint 5](SCRUM.md#sprint-5--migración-a-flutter-app-móvil-nativa) for full task list.

**Remaining open items:**

| ID | Task | Status |
|----|------|--------|
| S5-10 | Feed screen: full CardSwiper integration + toast system | 🔄 |
| S5-13 | Philosophy Map: radar chart + snapshot history | 🔄 |
| S5-14 | Challenges screen: progress ring widget | 🔄 |
| S5-15 | Premium screen: RevenueCat stub + comparison table | 🔄 |
| S5-16 | Donations screen: url_launcher integration | 🔄 |
| S5-17 | Profile screen: stats display | 🔄 |
| S5-18 | Settings screen: lang toggle + navigation | 🔄 |
| S5-19 | Share/Export: screenshot → share_plus integration | 🔄 |
| S5-21 | Shared extensions: BuildContext + String | 🔄 |

---

## Phase 4 — Philosophy Map & Evolution

| ID | Task | Priority |
|----|------|----------|
| P4-01 | Philosophy Map radar chart (CustomPainter Flutter widget) | P0 |
| P4-02 | Evolution delta display (before/after week comparison) | P0 |
| P4-03 | "Your philosophy this week" summary card injected into feed | P1 |
| P4-04 | Snapshot history scroll (past weeks) | P1 |
| P4-05 | Insight message generation ("You've been exploring Stoicism more") | P2 |
| P4-06 | Backend: `/map?compare=last` endpoint for delta | P1 |
| P4-07 | Push notification: "Your weekly philosophy map is ready" | P2 |

---

## Phase 5 — Premium & Content Packs

| ID | Task | Priority |
|----|------|----------|
| P5-01 | RevenueCat SDK integration in Flutter | P0 |
| P5-02 | Backend receipt validation webhook | P0 |
| P5-03 | Restore purchases flow (iOS + Android) | P0 |
| P5-04 | Content pack: Stoicism Deep Dive (500+ quotes) | P1 |
| P5-05 | Content pack: Zen Buddhism (300+ quotes) | P1 |
| P5-06 | Content pack: Existentialism (300+ quotes) | P1 |
| P5-07 | Content pack: Spanish Philosophy (500+ ES quotes) | P1 |
| P5-08 | Pack preview screen (locked quotes visible, upgrade prompt) | P1 |
| P5-09 | `POST /premium/unlock` receipt validation (Apple + Google) | P0 |

---

## Phase 6 — Scale to 100k Users

| ID | Task | Priority |
|----|------|----------|
| P6-01 | Redis feed cache (hot quotes per category) | P0 |
| P6-02 | pgBouncer connection pooling (Supabase Pro) | P0 |
| P6-03 | Feed query optimization (EXPLAIN ANALYZE + partial indexes) | P0 |
| P6-04 | Structured logging + Sentry error tracking | P1 |
| P6-05 | Background job queue for swipe event processing (BullMQ) | P1 |
| P6-06 | CDN for font and image assets | P1 |
| P6-07 | Load testing suite (k6 or Artillery) | P1 |
| P6-08 | iOS App Store submission | P0 |
| P6-09 | Google Play Store submission | P0 |
| P6-10 | Push notifications (daily reminder at user-set time) | P2 |
| P6-11 | Home screen widget (iOS + Android) | P2 |

---

## Post-MVP Open Items (No Phase Assigned)

These require product validation before scheduling:

| ID | Item | Notes |
|----|------|-------|
| PM-01 | Streak milestone animation (7 / 14 / 30 days) | Was in original post-MVP, still not built |
| PM-02 | Service Worker / offline cache for web legacy | Low priority — Flutter is primary |
| PM-03 | Auth (Google/Apple) for cross-device sync | Only after Phase 5 completes |
| PM-04 | Public quote API for developers | Phase 7+ |
| PM-05 | Analytics dashboard (retention, top quotes, trends) | Phase 6+ |
| PM-06 | Vault collections (themed folders) | Product validation needed |

---

## Resolved Decisions (Archive)

These were blocking questions from Sprint 0 — all resolved:

| ID | Question | Resolution |
|----|----------|-----------|
| DP-01 | Likes: client-side or backend? | Backend — `POST /quotes/:id/like` (Sprint 3) |
| DP-02 | Cursor: UUID or page number? | UUID of last seen item (Sprint 2) |
| DP-03 | Language fallback behavior? | Show EN if no quotes available in user's lang |
| DP-04 | Streak: frontend or backend? | Backend owns streak (Sprint 2+) |

---

## Won't Build

| Item | Reason |
|------|--------|
| Mandatory user accounts | Kills frictionless onboarding |
| Advertising | Contradicts the anti-doom-scrolling mission |
| Subscription model | One-time purchase aligns incentives better |
| Social feed (public likes/shares) | Turns philosophy into performance |
| User-generated content (public) | Content quality is non-negotiable |
| Gamification (leaderboards, badges) | Undermines genuine reflection |
