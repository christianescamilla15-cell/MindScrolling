# MindScrolling — Backlog
**Last updated:** 2026-03-17 | Sprint 7 planning (post-Google Play launch)

> Sprints 0–6 are complete. This document tracks Sprint 7 onward.
> Historical sprint tasks are recorded in [SCRUM.md](SCRUM.md).
> Sprint 5 items below marked 🔄 were superseded by Sprint 6 delivery — see SCRUM.md for resolution.

---

## Sprint 7 — Google Play Launch Hardening (P0 items)

These are blockers. Nothing ships to users until this list is green.

| ID | Task | Priority | Effort | Business Reason |
|----|------|----------|--------|-----------------|
| S7-01 | Enable pgvector extension in Supabase Dashboard | P0 | Low | AI feed algorithm is inert without it |
| S7-02 | Run `004_ai_feed.sql` migration in Supabase SQL Editor | P0 | Low | Schema required for hybrid feed scoring |
| S7-03 | Run `npm run embed-quotes` (one-time batch ~30 min) | P0 | Low | Without embeddings the AI feed falls back to behavioural only — acceptable but suboptimal |
| S7-04 | Deploy backend to Railway production (not Render free) | P0 | Medium | Render free tier sleeps after 15 min — first user opens app, 30s cold start = uninstall |
| S7-05 | Make GitHub repository private | P0 | Low | 13K curated quotes + proprietary feed algorithm are a competitive asset |
| S7-06 | Google Play Store submission (app bundle, store listing, screenshots) | P0 | Medium | Primary launch objective |
| S7-07 | Validate RevenueCat + Google Play Billing end-to-end (sandbox) | P0 | Medium | Premium revenue is broken if billing is not tested before release |
| S7-08 | Restore purchases flow — verify works on Android (Play Billing) | P0 | Low | Store policy requires a working restore flow |
| S7-09 | Crash-free rate baseline — run on 3 physical Android devices | P0 | Low | Launch with unknown crash rate is unacceptable |
| S7-10 | Trial expiry UX — confirm upgrade prompt appears on day 8 correctly | P0 | Low | Trial is the primary conversion funnel; a broken prompt = zero revenue |

---

## Sprint 7 — P1 Items (First Month Post-Launch)

| ID | Task | Priority | Effort | Business Reason |
|----|------|----------|--------|-----------------|
| S7-11 | Push notifications: daily reminder at user-configured time | P1 | Medium | Primary retention driver; users who disable notifications churn 3× faster |
| S7-12 | Philosophy Map weekly snapshot notification ("Your map is ready") | P1 | Medium | Creates a weekly re-engagement hook without gamification |
| S7-13 | Structured error logging + Sentry integration (backend) | P1 | Low | Blind production ops is not acceptable post-launch |
| S7-14 | Feed query optimization: EXPLAIN ANALYZE + partial indexes on `quotes` | P1 | Medium | Free tier Supabase has connection limits; slow queries will throttle under modest load |
| S7-15 | Trial-to-paid conversion analytics (server-side event: trial_started, trial_expired, premium_purchased) | P1 | Low | Without this data, pricing and trial length decisions are guesswork |
| S7-16 | Onboarding completion rate tracking (server-side funnel: screen 1 / 2 / 3 / feed) | P1 | Low | Onboarding drop-off is the most impactful silent killer of new apps |
| S7-17 | Price localization audit: MXN / BRL / ARS display correct in Premium screen | P1 | Low | LATAM is a primary market given ES content; wrong prices destroy trust |
| S7-18 | Vault export as plain text (.txt) — free feature | P1 | Low | Users who export their vault share the app organically; this is word-of-mouth fuel |

---

## Sprint 8 — Retention & Depth (First Quarter Post-Launch)

### Retention

| ID | Task | Priority | Effort | Business Reason |
|----|------|----------|--------|-----------------|
| S8-01 | Home screen widget (Android): daily quote | P2 | High | Widgets drive passive habit formation — the single highest-retention surface on Android |
| S8-02 | Vault collections (themed folders: "Stoicism", "On Grief", "On Work") | P2 | Medium | Users with organized vaults have higher LTV; it signals deep engagement |
| S8-03 | "Today's reflection" card: one curated question injected into feed daily | P2 | Medium | Transforms passive reading into active reflection — core product mission |
| S8-04 | Streak milestone moments (7 / 30 days): full-screen card, not a badge | P2 | Low | A moment of acknowledgment is not gamification; it is closure. Must feel earned, not manipulative |
| S8-05 | Evolution card injected into feed every 10 quotes ("Your philosophy shifted this week") | P2 | Medium | Closes the feedback loop between behavior and self-understanding |

### Content Depth

| ID | Task | Priority | Effort | Business Reason |
|----|------|----------|--------|-----------------|
| S8-06 | Content pack: Stoicism Deep Dive (500+ quotes, Marcus Aurelius, Seneca, Epictetus) | P1 | High | Stoicism is the highest-demand category; a deep pack justifies the premium price alone |
| S8-07 | Content pack: Existentialism (300+ quotes, Camus, Sartre, de Beauvoir, Nietzsche) | P1 | High | Second highest demand in user interest data (onboarding selections) |
| S8-08 | Content pack: Zen & Buddhism (300+ quotes) | P2 | High | Complements ambient audio feature; strong cross-sell |
| S8-09 | Content pack: Spanish Philosophy (500+ ES quotes, Ortega y Gasset, Unamuno, Borges) | P1 | High | ES is ~48% of current DB but underrepresented in premium content |
| S8-10 | Pack preview screen: locked quotes visible with upgrade blur | P1 | Low | Visible locked content converts better than abstract feature lists |
| S8-11 | Author deep-dive cards: bio + top 5 quotes for each author (premium) | P2 | Medium | Adds depth without UGC; reinforces the "anti-Wikipedia" curation angle |

### Monetization

| ID | Task | Priority | Effort | Business Reason |
|----|------|----------|--------|-----------------|
| S8-12 | Price increase evaluation: $4.99 → $6.99 post content packs | P2 | Low | Content packs increase perceived value; pricing should reflect that |
| S8-13 | Activation code system audit: ensure codes are single-use, time-limited | P2 | Low | Donor codes leaking = unpaid premium users at scale |
| S8-14 | iOS App Store submission | P1 | Medium | iOS opens a second revenue channel; LATAM iOS users are a meaningful segment |

---

## Phase 6 — Scale to 100k Users (Planned)

| ID | Task | Priority | Effort |
|----|------|----------|--------|
| P6-01 | Redis feed cache (hot quotes per category) | P0 | High |
| P6-02 | pgBouncer connection pooling (Supabase Pro) | P0 | Medium |
| P6-03 | Feed query optimization (EXPLAIN ANALYZE + partial indexes) | P0 | Medium |
| P6-04 | Structured logging + Sentry error tracking | P1 | Low |
| P6-05 | Background job queue for swipe event processing (BullMQ) | P1 | High |
| P6-06 | CDN for font and image assets | P1 | Medium |
| P6-07 | Load testing suite (k6 or Artillery) | P1 | Medium |
| P6-10 | Push notifications (daily reminder at user-set time) | P2 | Medium |
| P6-11 | Home screen widget (iOS + Android) | P2 | High |

---

## Post-MVP Open Items (Requires Validation Before Scheduling)

| ID | Item | Notes |
|----|------|-------|
| PM-02 | Service Worker / offline cache for web legacy | Low priority — Flutter is primary |
| PM-03 | Auth (Google/Apple) for cross-device sync | Only after Phase 5 completes AND user demand confirmed |
| PM-04 | Public quote API for developers | Phase 7+ |
| PM-05 | Internal analytics dashboard (retention, top quotes, funnel) | Needed by Sprint 8 to make evidence-based decisions |

---

## Resolved Decisions (Archive)

| ID | Question | Resolution |
|----|----------|-----------|
| DP-01 | Likes: client-side or backend? | Backend — `POST /quotes/:id/like` (Sprint 3) |
| DP-02 | Cursor: UUID or page number? | UUID of last seen item (Sprint 2) |
| DP-03 | Language fallback behavior? | Show EN if no quotes available in user's lang |
| DP-04 | Streak: frontend or backend? | Backend owns streak (Sprint 2+) |
| DP-05 | Streak milestones: badges or moments? | Full-screen moment card only — no persistent badge, no leaderboard |
| DP-06 | Content packs: separate purchase or bundled in premium? | Bundled in premium ($4.99 one-time) — simplifies purchase decision |
| DP-07 | Trial: client-side or server-side? | Server-side (backend `/premium/status`) with local fallback — prevents clock manipulation |

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
| Streak counter as primary UI element | Shifts motivation from reflection to number-chasing |
| "Most popular quotes" ranking visible to users | Creates social pressure — same problem as likes |
