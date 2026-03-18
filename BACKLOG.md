# MindScrolling — Backlog
**Last updated:** 2026-03-18 | Sprint 7 planning (post-Google Play launch) + Bloque B scope defined

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
| S7-17 | Price localization audit: MXN / BRL / ARS display correct in Premium screen | P1 | Low | LATAM is a primary market given ES content; wrong prices destroy trust. Canonical prices: MXN $79, BRL $19.90, ARS automatic tier (review quarterly), COP $19,900 |
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
| S8-06 | Content curation: designate 15 pack preview quotes per pack per language (90 quotes total — Stoicism, Existentialism, Zen, EN+ES) | P0 | Medium | Prerequisite for Bloque B QA sign-off. Preview quotes must be editorially designated before the pack preview flow can be tested. |
| S8-07 | Content pack: Existentialism — verify 500 EN + 500 ES quotes in DB with pack_name = 'existentialism' | P1 | Medium | Second highest demand in user interest data (onboarding selections) |
| S8-08 | Content pack: Zen & Mindfulness — verify 500 EN + 500 ES quotes in DB with pack_name = 'zen_mindfulness' | P1 | Medium | Complements ambient audio feature; strong cross-sell |
| S8-09 | Content pack: Stoicism Deep Dive — verify 500 EN + 500 ES quotes in DB with pack_name = 'stoicism_deep' | P1 | Medium | Stoicism is the highest-demand category |
| S8-10 | New content pack: Spanish Philosophy (500+ ES quotes, Ortega y Gasset, Unamuno, Borges) | P1 | High | ES is ~48% of current DB but underrepresented in premium content. Post-Bloque B architecture. |
| S8-11 | Author deep-dive cards: bio + top 5 quotes for each author (premium) | P2 | Medium | Adds depth without UGC; reinforces the "anti-Wikipedia" curation angle |

### Pack Monetization — Bloque B (Sprint 8 primary deliverable)

> Scope fully defined in SCOPE_BLOCK_B_PACK_MONETIZATION.md (2026-03-18).
> Items S8-10 and S8-10b from previous backlog version are superseded by this block.
> Decision DP-06 is superseded: individual pack purchases at $2.99 are now in scope.
> See scope document for user stories US-B01 through US-B11, edge cases, and business rules.

| ID | Task | Priority | Effort | Business Reason |
|----|------|----------|--------|-----------------|
| B-01 | DB migration: add `pack_purchases` table + `is_pack_preview`, `pack_preview_rank`, `released_at` columns to `quotes` + `source`, `pack_id` to `swipes` | P0 | Low | Schema prerequisite for all Bloque B work |
| B-02 | Backend: modify `GET /packs` to include per-device `user_access` field (unlocked / preview_only / purchasable) | P0 | Medium | Drives catalog UI state without additional client round-trips |
| B-03 | Backend: modify `GET /packs/:id/preview` to respect entitlement tier (5 quotes Free, 15 quotes Trial, full for Inside/pack owner) | P0 | Medium | Core entitlement enforcement for preview flow |
| B-04 | Backend: new `GET /packs/:id/feed` — paginated full pack feed for entitled users, lang-aware, adaptive-ordered | P0 | High | Delivers the purchased content experience |
| B-05 | Backend: modify `GET /premium/status` to include `owned_packs: string[]` | P0 | Low | Client needs pack entitlement list on app launch without additional requests |
| B-06 | Backend: new `POST /packs/:id/purchase/verify` — RevenueCat pack purchase verification | P0 | Medium | Revenue collection for individual packs |
| B-07 | Backend: modify `POST /premium/restore` to restore individual pack entitlements | P0 | Low | Store policy and user trust requirement |
| B-08 | Backend: modify `POST /swipes` to accept `source` and `pack_id` fields | P1 | Low | Philosophy Map accuracy requires knowing swipe origin |
| B-09 | Backend: analytics events for pack funnel (pack_catalog_viewed, pack_preview_started, pack_preview_completed, pack_paywall_shown, pack_purchased, pack_feed_entered, trial_soft_paywall_shown, trial_hard_paywall_shown) | P1 | Medium | Without pack conversion data, pricing and CTA copy decisions are guesswork |
| B-10 | Flutter: rewrite PacksScreen — catalog with user_access state, per-pack entitlement badges, tappable cards | P0 | Medium | Current PacksScreen wraps everything in PremiumGate (blocks Free/Trial users entirely — wrong behavior) |
| B-11 | Flutter: new PackPreviewScreen — swipeable preview cards, hard paywall at quota, Inside + single pack CTAs | P0 | High | Core conversion surface of the block |
| B-12 | Flutter: new PackFeedScreen — full pack feed for entitled users, return navigation, same QuoteCard widget | P0 | High | Delivers the purchased content experience |
| B-13 | Flutter: soft paywall card widget injected into main FeedScreen at ~swipe 100 (trial users only) | P1 | Medium | Non-blocking trial reminder; drives conversion without disrupting reflection |
| B-14 | Flutter: update hard trial expiry modal to show both Inside CTA and "Browse individual packs" secondary CTA | P1 | Low | Inside remains primary; packs are a secondary conversion path |
| B-15 | Flutter: update PremiumScreen value proposition copy to reflect new pack architecture (3 packs + features for $4.99) | P1 | Low | Current copy predates individual pack pricing |
| B-16 | Flutter: add 11 new i18n keys (EN + ES) as defined in US-B10 | P0 | Low | All user-facing copy must be localized |
| B-17 | RevenueCat: create 3 individual pack products (com.mindscrolling.pack.stoicism_deep, .existentialism, .zen_mindfulness) on Android + iOS with regional pricing | P0 | Low | Cannot test purchase flow without configured products |
| B-18 | QA: verify grandfathering — existing Inside devices get full pack access without re-purchase | P0 | Low | Regression risk on the most trust-sensitive user group |
| B-19 | QA: verify entitlement matrix — all 5 user states (Free, Trial active, Trial expired, Pack owner, Inside) against all 3 access surfaces (catalog, preview, full feed) | P0 | High | 15 state-surface combinations, all must pass before ship |

### Monetization

| ID | Task | Priority | Effort | Business Reason |
|----|------|----------|--------|-----------------|
| S8-12 | Regional pricing confirmation for individual packs (USD $2.99 / MXN $49 / BRL $14.90 / EUR $2.69 / CAD $3.99) — PO sign-off required | P0 | Low | RevenueCat products cannot be created without confirmed prices (see OQ-05 in scope doc) |
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
| DP-06 | Content packs: separate purchase or bundled in premium? | **SUPERSEDED 2026-03-18.** Original decision: bundled in $4.99 (Option A, 2026-03-17). New decision: individual packs at $2.99 each + Inside at $4.99 as value anchor (3 packs + features). Inside grandfathers current 3 packs for existing users. Future packs always $2.99 separately. Full scope in SCOPE_BLOCK_B_PACK_MONETIZATION.md. |
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
| Individual pack purchases ($0.99-$1.99 each) — micro pricing | Paradox of choice at micro price point; LATAM purchasing behavior favors single transactions. NOTE: Individual pack purchases at $2.99 ARE now in scope (Bloque B, 2026-03-18) — the Won't Build constraint was for micro-pricing only, not the $2.99 value tier. |
| Tiered content gating (Basic/Full/Lifetime) | Artificial gate on wisdom is tonally wrong; creates resentment among Basic-tier users who hit locked content |

---

## Pricing Decision Record

### v1 Decision (2026-03-17) — superseded
**Anchor price:** $4.99 USD one-time, all content bundled.
Options A/B/C/D evaluated — Option A selected. See SCRUM.md Sprint 7 for full rationale.

### v2 Decision (2026-03-18) — current
**Model:** Individual packs at $2.99 each. Inside at $4.99 as value anchor (3 packs worth $8.97 + premium features, all for $4.99).
**Grandfathering:** Existing Inside users receive all 3 current packs automatically. Future packs = $2.99 separately for all users including Inside.
**Rationale:** The $2.99 individual pack introduces a lower entry point that captures users unwilling to commit to $4.99. The Inside upsell at the pack paywall ("3 packs for the price of 1.67") creates a natural upgrade path. The value framing is stronger than bundled pricing alone because the user can perceive the savings. LATAM friction concern from v1 is mitigated by the lower $2.99 entry point.

**Individual pack regional prices (canonical):**
| Region | Currency | Price |
|--------|----------|-------|
| United States | USD | $2.99 |
| Mexico | MXN | $49 |
| Brazil | BRL | $14.90 |
| European Union | EUR | $2.69 |
| Canada | CAD | $3.99 |
| Colombia | COP | $12,900 |
| Argentina | ARS | Automatic App Store tier |

**Inside regional prices (unchanged from v1):**
| Region | Currency | Price |
|--------|----------|-------|
| United States | USD | $4.99 |
| Mexico | MXN | $79 |
| Brazil | BRL | $19.90 |
| Argentina | ARS | Automatic App Store tier |
| Colombia | COP | $19,900 |
| European Union | EUR | $4.49 |
| Canada | CAD | $6.99 |

**Regional prices (canonical):**
| Region | Currency | Price |
|--------|----------|-------|
| United States | USD | $4.99 |
| Mexico | MXN | $79 |
| Brazil | BRL | $19.90 |
| Argentina | ARS | Automatic App Store tier |
| Colombia | COP | $19,900 |
| European Union | EUR | $4.49 |
| Canada | CAD | $6.99 |

**Review cadence:** ARS quarterly. All other regions annually.
**Business rationale:** Simplicity converts. One price, one action. Regional pricing captures LATAM purchasing power without changing the product model. The pack browser UI (S8-10) is the conversion lever — not price fragmentation.
