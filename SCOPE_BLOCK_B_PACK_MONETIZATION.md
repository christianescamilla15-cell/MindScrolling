# Scope Document — Bloque B: Pack Monetization Nueva Arquitectura

**Version:** 1.0
**Date:** 2026-03-18
**Author:** Product Owner
**Status:** Approved — ready for API Architect
**Target:** Sprint 8 (Phase 7 — Content Depth & Growth)

---

## 1. Context and Strategic Rationale

MindScrolling currently has a single monetization gate: MindScrolling Inside at $4.99 one-time.
The previous backlog decision (DP-06) bundled all packs into that price. That decision is **superseded** by the business decisions documented in this block.

The new architecture introduces individual pack purchases ($2.99 each) while preserving Inside ($4.99) as the dominant value anchor — positioning Inside as "3 packs ($8.97 value) + premium features, all for $4.99." This is not fragmentation; it is a value ladder. The pack browser becomes the primary conversion surface.

Three packs exist in the database: Stoicism Deep Dive, Existentialism, Zen & Mindfulness. Each contains 500 quotes in EN and 500 in ES.

Grandfathering: any device with `is_premium = true` or `premium_status IN ('premium_onetime', 'premium_lifetime')` before this block ships receives access to all three current packs automatically. Future packs added after this block ships are always sold separately, even to grandfathered Inside users.

---

## 2. Glossary

| Term | Definition |
|------|-----------|
| Free user | No trial started, no purchase. 20 swipes/day, 20-quote vault cap. |
| Trial user | Active 7-day trial OR within 1,000-quote trial quota (whichever expires first). |
| Inside user | Paid $4.99 or redeemed activation code. Grandfathered to current 3 packs. |
| Pack owner | Has purchased a specific pack at $2.99. Access scoped to that pack only. |
| Grandfathered | Inside users who purchased before this block ships. Permanent access to the 3 packs in the initial catalog. |
| Curated previews | A fixed editorial selection of quotes designated as the best representatives of a pack. Not random. |
| Hard paywall | Full stop — no content shown beyond the preview quota. Navigation to upgrade is mandatory. |
| Soft paywall card | A card injected into the feed that invites upgrade but does not block scrolling. |
| Pack catalog | The list of all available packs shown on the Packs screen. |

---

## 3. User States and Entitlement Matrix

| State | Main Feed | Pack Preview | Pack Full Access |
|-------|-----------|--------------|-----------------|
| Free | 20 swipes/day from general pool | 5 curated quotes | Hard paywall |
| Trial (active) | Up to 1,000 quotes or 7 days | 15 curated quotes | Hard paywall + secondary Inside CTA |
| Pack owner (specific pack) | Same as Free for general feed | Full 500 quotes (user lang) | Yes, for owned packs only |
| Inside (paid) | Unlimited | Full 500 quotes (user lang) | Yes, all packs (including grandfathered) |
| Inside + pack owner | Same as Inside | Full 500 quotes | Yes, all packs |

Note: A Pack owner who has not purchased Inside still hits Free limits (20 swipes/day) on the main feed. Pack access is scoped only to the Packs section and does not alter main feed behavior.

---

## 4. User Stories and Acceptance Criteria

### US-B01 — Pack catalog listing

**As a user, I want to see all available content packs with their name, description, quote count, and a visual indicator of my access status, so that I can make an informed decision about what to explore.**

Acceptance criteria:
- The Packs screen shows all packs regardless of user entitlement status.
- Each pack card displays: name (in user's configured language), description (in user's language), total quote count (500), pack accent color, and category icon.
- Pack cards show one of three states: "Unlocked" (Inside or pack owner), "Preview available" (all users), "Get for $2.99" (free or trial, not Inside).
- Inside users see "Included in Inside" badge instead of price.
- Trial users see "Preview" badge; price is visible but secondary.
- Quote count shown is always 500 (the full pack size), not the preview count.
- Response time for pack list: under 500ms at p95.
- If the backend is unreachable, the client shows the last cached pack list (TTL: 24 hours).

---

### US-B02 — Pack preview for Free users

**As a free user, I want to read a sample of 5 curated quotes from a pack, so that I can evaluate whether the pack is worth purchasing.**

Acceptance criteria:
- The preview screen shows exactly 5 quotes. These are editorially designated — not random — and must be consistent across sessions for the same pack and language.
- Quotes are displayed as swipeable cards using the same QuoteCard widget as the main feed.
- After the 5th quote, a hard paywall is shown. The user cannot swipe further.
- The paywall shows: pack name, price ($2.99), primary CTA "Get this pack — $2.99", secondary CTA "Or unlock everything with Inside — $4.99".
- The paywall does not auto-redirect. The user can navigate back to the catalog.
- No swipe events are logged to the main feed algorithm from pack preview swipes (they are separate interactions).

---

### US-B03 — Pack preview for Trial users

**As a trial user, I want to read 15 curated quotes from a pack, so that I can experience more depth before the trial ends.**

Acceptance criteria:
- The preview screen shows exactly 15 quotes. These are editorially designated and consistent across sessions.
- The first 5 quotes are the same as the Free preview (the curated set is additive: 5 base + 10 trial-only). This allows a Trial user who previously saw 5 as Free to now see the full 15 without repeating.
- After the 15th quote, a hard paywall is shown.
- The paywall copy: "485 more quotes — $2.99" as primary CTA. Secondary CTA: "Or get all 3 packs with Inside — $4.99".
- The "485 more quotes" count is always 500 minus 15 = 485, hardcoded in copy.
- Trial users who purchase a pack during trial retain pack access permanently after trial expires.

---

### US-B04 — Full pack access for pack owners

**As a user who purchased a pack, I want to read all 500 quotes from that pack in my configured language, so that I receive the full value of my purchase.**

Acceptance criteria:
- All 500 quotes in the user's configured language (EN or ES) are accessible.
- Quotes are served through the same swipeable feed interface used in the main feed.
- Swipe events from within a pack feed are logged normally and contribute to the user's Philosophy Map.
- If the user's configured language is changed in settings, the pack feed reloads in the new language on next visit.
- Pack feed supports pagination: 20 quotes per page, cursor-based.
- Pack feed respects the same adaptive ordering logic as the main feed (affinity scoring), but scoped to the pack's quote pool.
- A "Return to Packs" navigation action is available at all times within the pack feed.

---

### US-B05 — Full pack access for Inside users (grandfathered and new)

**As a MindScrolling Inside user, I want automatic access to all available packs without additional purchase, so that my existing investment covers the full content catalog at the time of my purchase.**

Acceptance criteria:
- Inside users (is_premium = true with any premium_status) see all packs as "Unlocked" in the catalog.
- No purchase prompt is ever shown to Inside users for the 3 current packs.
- The Inside badge on each pack card reads "Included in Inside" in both EN and ES.
- Grandfathering is determined server-side by checking `is_premium = true` at the time of the request, not by purchase date. The distinction between current and future packs is enforced at the data layer by a pack release date flag, not by client logic.
- Future packs (added after this block ships) display a "Get for $2.99" CTA even for Inside users. The pack card must clearly communicate "New — not included in existing Inside" in both languages.

---

### US-B06 — Individual pack purchase

**As a free or trial user, I want to purchase a single pack for $2.99, so that I can access deep content on a specific topic without committing to the full Inside price.**

Acceptance criteria:
- The purchase flow is triggered from the pack paywall CTA or directly from the pack catalog card.
- Purchase goes through RevenueCat with product IDs following the pattern: `com.mindscrolling.pack.<pack_id>` (e.g., `com.mindscrolling.pack.stoicism_deep`).
- After successful purchase, the backend records the entitlement in a new `pack_purchases` table (device_id, pack_id, store, product_id, transaction_id, purchase_token, purchased_at, status).
- The user is immediately redirected to the full pack feed without requiring an app restart.
- A purchase confirmation message is shown: "Stoicism Deep Dive unlocked. 500 quotes ready."
- Regional pricing mirrors the Inside regional pricing proportionally. Canonical: USD $2.99 / MXN $49 / BRL $14.90 / EUR $2.69 / CAD $3.99. ARS: automatic App Store tier. COP: $12,900.
- The `GET /premium/status` endpoint must return owned pack IDs so the client can gate content without an additional round-trip on app launch.

---

### US-B07 — Trial paywall soft card in main feed

**As a trial user approaching the trial limit, I want to receive a non-blocking reminder about upgrading, so that I am informed without being interrupted during reflection.**

Acceptance criteria:
- A soft paywall card is injected into the main feed at approximately swipe 100 (within a ±5 quote tolerance to avoid predictability).
- The card is not a blocking modal. The user can swipe it away like any other card.
- Card copy: "You've reflected on 100 ideas. Inside unlocks unlimited depth — $4.99, once." (EN). Must be localized in ES.
- The card is shown only once per device per trial period. If swiped away, it does not reappear.
- After the trial quota (1,000 quotes) or 7-day period expires, the main feed shows a hard paywall on the next app open. The hard paywall is a full-screen modal, not an injected card.
- The hard paywall at trial end shows: primary CTA "Unlock Inside — $4.99", secondary CTA "Browse individual packs ($2.99 each)".
- Trial end is determined server-side. The client checks `/premium/status` on each app launch and caches the result with a 5-minute TTL.

---

### US-B08 — Pack purchase upsell from Inside paywall

**As a user viewing the Inside paywall from a pack preview, I want to see a clear value comparison between buying Inside vs. buying a single pack, so that I can make the choice that fits my intent.**

Acceptance criteria:
- The pack paywall always shows both purchase options simultaneously.
- The value framing on the Inside CTA reads: "3 packs ($8.97 value) + premium features — $4.99" (EN). Localized in ES.
- If the user already owns one pack, the Inside upsell adjusts: "You already own 1 pack. Get the other 2 + premium features for $4.99."
- If the user owns two packs, the Inside upsell adjusts: "You own 2 packs. Complete your library + premium features for $4.99."
- This cross-sell copy is computed client-side based on the owned_packs list returned by `/premium/status`.

---

### US-B09 — Pack purchase restore

**As a user who reinstalls the app or uses a new device, I want to restore my pack purchases, so that I do not lose access to content I already paid for.**

Acceptance criteria:
- The existing "Restore Purchases" flow (RevenueCat) is extended to also restore individual pack entitlements.
- After restore, the backend grants access to all packs whose product IDs are present in the RevenueCat receipt.
- Restored pack entitlements are stored in `pack_purchases` with `status = 'restored'`.
- The user sees a confirmation: "Your purchases have been restored: Stoicism Deep Dive, Zen & Mindfulness."
- If no pack purchases exist for the receipt, only Inside status is restored (existing behavior preserved).

---

### US-B10 — Language-aware pack content

**As a Spanish-speaking user, I want all pack quotes, preview quotes, and paywall copy to be in Spanish, so that my experience is fully in my configured language.**

Acceptance criteria:
- The `lang` parameter (derived from the user's configured language in Settings, not device locale) governs all pack content responses.
- Preview quotes are designated separately for EN and ES. A quote curated as a preview in EN does not automatically become a preview in ES — curation is per-language.
- If a quote has no ES translation, it is excluded from ES pack feeds. The EN fallback is NOT used in pack content (unlike the main feed). This ensures pack quote counts are accurate.
- All UI strings in the pack browser, paywall, and confirmation messages are covered by the existing EN/ES i18n system.
- New i18n keys required: `packIncludedInInside`, `packGetFor`, `packPaywallPrimary`, `packPaywallSecondaryInside`, `packTrialPaywallPrimary`, `packTrialPaywallSecondary`, `packConfirmationUnlocked`, `packNewNotIncluded`, `insideValueProp`, `insideValuePropOwn1`, `insideValuePropOwn2`.

---

### US-B11 — Admin: designate curated preview quotes

**As a product admin, I want to designate which quotes are shown in the Free (5) and Trial (15) previews for each pack, so that the best quotes represent each pack editorially.**

Acceptance criteria:
- A new boolean column `is_pack_preview` and an integer column `pack_preview_rank` (1–15) are added to the `quotes` table.
- Pack preview rank 1–5 = shown to Free and Trial users. Rank 6–15 = shown to Trial users only.
- Admin designation is done via the existing admin routes or Supabase dashboard — no new admin UI is required in this block.
- The `/packs/:id/preview` endpoint reads `pack_preview_rank IS NOT NULL` ordered by `pack_preview_rank ASC`, filtered by the user's entitlement-appropriate limit (5 or 15), and by `lang`.
- Initial curation (designating 15 quotes per pack per language = 90 total) is a content task, not a development task. It is a prerequisite for QA sign-off.

---

## 5. Edge Cases

| ID | Scenario | Required Behavior |
|----|----------|------------------|
| EC-01 | User purchases Inside after owning 1 or 2 packs | Inside is granted. Pack purchases remain in DB. No refund flow. User sees unified "Unlocked" status. |
| EC-02 | User is mid-trial and purchases a pack | Pack purchase is permanent. Trial continues for the main feed. When trial expires, user retains pack access but loses main feed trial access. |
| EC-03 | User's language changes from EN to ES mid-pack | On next pack screen visit, the feed reloads in ES. Current position is not preserved (acceptable). |
| EC-04 | Pack has fewer than 500 quotes in a given language due to translation gaps | The actual count is returned by the API. The UI shows the real count, not "500." If a pack has fewer than 5 quotes in a language, the preview is not available in that language and a "Not available in [language]" message is shown. |
| EC-05 | RevenueCat purchase succeeds client-side but backend verification fails | The client retries the backend call up to 3 times with exponential backoff. If all retries fail, the user sees "Purchase recorded — restart the app to activate." RevenueCat receipt is stored client-side for the next restore attempt. |
| EC-06 | Trial user has seen 5 Free preview quotes, then starts trial | On next preview visit, the preview shows all 15 (not 10 new ones). The client does not track which preview quotes were already seen — the server always returns the appropriate count for the user's current state. |
| EC-07 | Future pack is added to the catalog after a user is grandfathered Inside | Future pack must have a `released_after_grandfathering = true` flag (or a `released_at` date after the block ship date). Grandfathered Inside users see it as "New — $2.99" in the catalog. The server checks this flag, not the user's `premium_since` date. |
| EC-08 | User with `premium_status = 'trial'` in DB (expired trial, not yet paid) hits `/packs/:id/preview` | Server detects trial is expired. Returns 5 quotes (Free tier preview), not 15. |
| EC-09 | Two concurrent pack purchase requests for the same device and pack | Backend uses an upsert with conflict handling on (device_id, pack_id) to prevent duplicate rows. |
| EC-10 | User purchases a pack that is later removed from the catalog | The pack remains accessible to the purchaser. The catalog API supports a `is_active = false` flag that hides packs from the catalog but still serves content to entitled users. |
| EC-11 | Device with no network on first launch | Pack catalog is not shown (no cached data on first launch). A "Connect to load packs" empty state is shown. Pack feed with cached quotes works offline for the last cached batch. |
| EC-12 | Pack preview is opened by Inside user | Inside user sees full 500 quotes immediately (no preview limit). The `is_pack_preview` flag is irrelevant for this user. |

---

## 6. Explicit Out of Scope for This Block

The following are NOT part of Bloque B and must not be implemented:

| Item | Reason |
|------|--------|
| New content packs (beyond the 3 existing ones) | Content production is a separate task tracked under S8-06 through S8-09. Bloque B only defines the architecture for existing packs. |
| Pack gifting or transferring | Not in business requirements. |
| Bundle discount (e.g., "buy 2 packs for $4.99") | This is the Inside product. Do not create a separate bundle SKU. |
| Free pack rotation (one free pack per month) | Contradicts the one-time purchase model and creates subscription expectations. |
| Pack-specific push notifications ("New quote added to your pack") | Phase 8+ feature. |
| In-pack search or filtering by author | Phase 8+ feature. |
| Pack ratings or reviews | Won't build — social feature. |
| Download-for-offline toggle per pack | Phase 8+ feature. |
| Admin UI for managing pack metadata | Admin routes via existing `/admin` endpoints are sufficient. |
| RevenueCat webhook handler for purchase events | Tracked separately as a backend hardening task (S7-07). Bloque B assumes RevenueCat client-side purchase verification calls the backend directly. |
| iOS App Store submission | Tracked as S8-14. Bloque B is Android-first but must be architected for iOS parity. |
| Analytics events for pack conversion funnel | Tracked under S7-15 (trial-to-paid funnel). Pack-specific events (pack_viewed, pack_purchased, pack_preview_completed) are a Bloque B deliverable and must be included. |

---

## 7. Business Rules (Non-Negotiables)

**BR-01 — Price integrity.** Individual pack price is always $2.99 USD (regional equivalents as defined in US-B06). This value must come from the backend, not be hardcoded in the client, to allow price updates without an app release.

**BR-02 — Inside as dominant value anchor.** Every paywall in this block must show the Inside option ($4.99) alongside the single-pack option ($2.99). The Inside option must always appear below the pack option with the value framing ("3 packs + features for $4.99"). This is the core conversion mechanic of the block.

**BR-03 — No free content degradation.** The Free tier still receives 5 preview quotes per pack. This must not be reduced in future iterations without a full Product Owner decision and BACKLOG.md update.

**BR-04 — Grandfathering is permanent.** Once a device is determined to be grandfathered Inside, its access to the 3 current packs is irrevocable. No server-side migration, cleanup job, or schema change may remove this access.

**BR-05 — Server-side entitlement is the source of truth.** The client must never grant pack access based solely on local state. All entitlement decisions are made by the server at `/premium/status` and cached for a maximum of 5 minutes. A forced refresh occurs immediately after any purchase or restore action.

**BR-06 — Preview quotes are editorially curated, not algorithmic.** The 5 (Free) and 15 (Trial) preview quotes per pack per language are designated by the product team. The backend returns them in designated order (by `pack_preview_rank`). The feed algorithm does not select or reorder preview quotes.

**BR-07 — Pack feed swipes count toward Philosophy Map.** Swiping within a pack is not a passive browsing action. It is a reflective act. Swipe events from pack feeds must be recorded in `swipes` with a `source = 'pack'` field so they can be analyzed separately but still feed the map algorithm.

**BR-08 — Trial quota is shared.** The 1,000-quote trial limit is shared across the main feed. Pack preview swipes do not count against the trial quota. Only main feed swipes are counted.

**BR-09 — No paywall on pack content for entitled users.** Any user who is an Inside user or a pack owner must never encounter a paywall while browsing their entitled pack content. Any regression where a paywall appears for an entitled user is a P0 bug.

**BR-10 — Language consistency.** The pack feed always serves quotes in the language configured in the user's app settings at the time of the request. Language detection must not fall back to device locale for pack content.

---

## 8. New API Contracts Required (for API Architect)

This section summarizes the new or modified endpoints. Exact request/response schemas are the API Architect's deliverable.

| Endpoint | Change | Notes |
|----------|--------|-------|
| `GET /packs` | Modified | Must return `user_access` field per pack: `unlocked`, `preview_only`, `purchasable`. Requires device entitlement check. |
| `GET /packs/:id/preview` | Modified | Must respect user entitlement: return 5 quotes (Free/expired trial), 15 quotes (active trial), or redirect to full feed (Inside/pack owner). |
| `GET /packs/:id/feed` | New | Paginated full pack feed for entitled users. Params: `lang`, `cursor`, `limit` (default 20). |
| `GET /premium/status` | Modified | Must include `owned_packs: string[]` — list of pack IDs the device is entitled to. |
| `POST /packs/:id/purchase/verify` | New | Accepts RevenueCat verification payload for individual pack purchases. Records in `pack_purchases`. |
| `POST /premium/restore` | Modified | Must also restore individual pack entitlements from RevenueCat receipt. |
| `POST /swipes` | Modified | Must accept optional `source: 'feed' | 'pack'` and `pack_id?: string` fields. |

---

## 9. New DB Schema Changes Required (for API Architect)

| Change | Table | Details |
|--------|-------|---------|
| New table | `pack_purchases` | `(id, device_id, pack_id, store, product_id, transaction_id, purchase_token, amount, currency, status, purchased_at, updated_at)` |
| New columns | `quotes` | `is_pack_preview BOOLEAN DEFAULT false`, `pack_preview_rank INT NULL (1-15)` |
| New column | `swipes` | `source VARCHAR(10) DEFAULT 'feed'`, `pack_id VARCHAR(50) NULL` |
| New column | `quotes` (packs) | `released_at TIMESTAMPTZ DEFAULT NOW()` — used to determine grandfathering boundary for future packs |

---

## 10. Dependencies on Other Blocks

| Dependency | Direction | Detail |
|-----------|-----------|--------|
| Bloque A — Feed Algorithm v2 | Bloque B depends on A | Pack feed adaptive ordering (BR-07, US-B04) requires the feed scoring query to be parameterizable by pack scope. If Bloque A changes the scoring schema, Bloque B's pack feed query must be updated in the same sprint. |
| Bloque C — Trial Quota Enforcement | Bloque B depends on C | The 1,000-quote trial limit (US-B07, BR-08) requires a swipe counter that is server-side and accurate. If Bloque C has not shipped, the soft paywall card trigger (at swipe ~100) can be estimated client-side as a fallback, but the hard paywall at quota exhaustion must be server-side. |
| Bloque D — RevenueCat Webhooks | Bloque D depends on B | Bloque B defines the `pack_purchases` schema. Bloque D's webhook handler must write to that same table. Coordinate schema before Bloque D begins implementation. |
| S7-07 — RevenueCat end-to-end validation | Bloque B depends on S7-07 | Individual pack purchases go through RevenueCat. Bloque B cannot reach QA sign-off until S7-07 is green. |
| S8-06 through S8-09 — Content pack production | Independent | Bloque B architecture works with 0 to N packs. Content production does not block architecture work. However, QA requires at least 15 curated preview quotes designated per pack per language before the preview flow can be tested. |

---

## 11. Analytics Events (Deliverable of This Block)

The following server-side events must be emitted to `premium_audit_log` or a dedicated analytics table as part of this block:

| Event | Trigger | Fields |
|-------|---------|--------|
| `pack_catalog_viewed` | User opens Packs screen | `device_id`, `user_state` (free/trial/inside/pack_owner), `lang` |
| `pack_preview_started` | User opens a pack preview | `device_id`, `pack_id`, `user_state`, `preview_quota` (5 or 15) |
| `pack_preview_completed` | User reaches the end of their preview quota | `device_id`, `pack_id`, `user_state` |
| `pack_paywall_shown` | Hard paywall is displayed | `device_id`, `pack_id`, `user_state`, `cta_shown` (single_pack / inside / both) |
| `pack_purchase_started` | User taps a pack purchase CTA | `device_id`, `pack_id`, `product_id`, `price_usd` |
| `pack_purchased` | Backend confirms pack purchase | `device_id`, `pack_id`, `store`, `amount`, `currency` |
| `pack_feed_entered` | User enters the full pack feed | `device_id`, `pack_id`, `access_reason` (inside / pack_owner / grandfathered) |
| `trial_soft_paywall_shown` | Soft paywall card injected into main feed | `device_id`, `swipe_count_at_injection` |
| `trial_hard_paywall_shown` | Trial quota/time expired, hard paywall shown | `device_id`, `expiry_reason` (quota / time) |

---

## 12. Impact on BACKLOG.md and ROADMAP.md

BACKLOG.md changes:
- DP-06 is superseded: individual pack purchases at $2.99 are now in scope. The "Won't Build" entry for individual pack purchases is removed and replaced with the Bloque B scope.
- S8-10 and S8-10b are superseded and replaced by Bloque B stories US-B01 through US-B11.
- New sprint items for Sprint 8 are listed under the Pack Monetization section.

ROADMAP.md changes:
- Phase 5 pricing model note is updated to reflect new pack architecture.
- Phase 7 content packs milestones are updated to reference Bloque B scope document.

These changes are applied in BACKLOG.md and ROADMAP.md immediately below.

---

## 13. Open Questions Requiring Product Owner Decision Before API Architect Begins

| ID | Question | Default if Not Resolved |
|----|----------|------------------------|
| OQ-01 | Should pack feed swipes count against the Free user's 20 swipes/day limit? A Free user cannot access the full pack feed (they hit the paywall), but this edge case arises if they are in an Inside trial and then lose access. | Recommendation: Pack feed swipes do NOT count against the 20/day Free limit. They are separate. Requires confirmation. |
| OQ-02 | What is the grandfathering cutoff date to use in the `released_at` column for future packs? The block ships at end of Sprint 8. Should the cutoff be the date the migration runs, or a fixed date declared in this document? | Recommendation: Use a hardcoded constant `GRANDFATHERING_CUTOFF = '2026-06-01'` (Sprint 8 estimated ship). Requires confirmation. |
| OQ-03 | Should the 5 curated preview quotes for Free users be the same 5 regardless of the user's swipe history (profile), or should they be personalized from the 15-quote curated set? | Recommendation: Same 5 for all users — curation wins over personalization in preview. Requires confirmation. |
| OQ-04 | If a user is in active trial and purchases Inside (not a pack), do they immediately lose the pack preview (15 quotes) and gain full access? Or does the trial preview continue until the trial expires? | Recommendation: Purchasing Inside immediately supersedes trial state. User gets full access. Requires confirmation. |
| OQ-05 | Regional prices for individual packs (listed in US-B06) — are these final and approved for RevenueCat product configuration? | Requires explicit PO sign-off before RevenueCat products are created. |
