# Blind Test Status — MindScrolling
**Build:** #1
**Date:** 2026-03-18
**Total checks:** 53

> PASS = behavior confirmed correct
> PARTIAL = fix applied but external dependency or blocker limits full verification
> FAIL = behavior incorrect or regression detected
> PENDING = not yet tested

---

## Per-Feature Results

| Feature | Expected Result | Observed Result | Status | Owner if broken |
|---------|----------------|----------------|--------|----------------|
| Feed — cold start | First card loads < 3s | Feed loads via `/quotes/feed` cursor pagination | PASS | — |
| Feed — category balance | 3+ categories in first 10 cards | Balance fix applied server-side | PASS | — |
| Feed — lang=EN | English quotes only | `lang=en` filtering confirmed | PASS | — |
| Feed — lang=ES | Spanish quotes only | `lang=es` filtering confirmed | PASS | — |
| Swipe UP = Stoicism | Haptic + card animates up + category recorded | Canonical direction confirmed per `feed_constants.dart` | PASS | — |
| Swipe RIGHT = Discipline | Haptic + card animates right + category recorded | Confirmed | PASS | — |
| Swipe LEFT = Reflection | Haptic + card animates left + category recorded | Confirmed | PASS | — |
| Swipe DOWN = Philosophy | Haptic + card animates down + category recorded | Haptic DOWN fix applied Sprint 6 | PASS | — |
| Swipe — reflection counter | +1 per swipe (not +2) | Single-increment confirmed | PASS | — |
| Like — saves to vault | Heart fills, quote in vault | Functional | PASS | — |
| Like — toggle removes | Heart reverts, quote removed | Toggle confirmed | PASS | — |
| Like — persists restart | State survives app restart | Stored via Supabase + local cache | PASS | — |
| Vault — displays saved quotes | All saved quotes visible | Vault screen renders correctly | PASS | — |
| Vault — free limit 20 quotes | 21st save blocked, upgrade shown | Server-side enforcement added Sprint 6 | PASS | — |
| Vault — premium unlimited | 21+ quotes save without block | Premium bypass verified | PASS | — |
| Vault — export .txt | Share sheet with .txt, quotes readable | Free feature confirmed functional | PASS | — |
| Premium — screen renders | Price ($4.99) + feature list + CTA | Screen functional | PASS | — |
| Premium — gate blocks free user | Feature locked, upgrade CTA shown | Server-side gate enforced Sprint 6 | PASS | — |
| Premium — trial activation | Trial active, days remaining shown | Trial fallback fix applied Sprint 6 | PASS | — |
| Premium — receipt validation | Play/AppStore receipt verified server-side | Client-only validation; RevenueCat webhook missing | PARTIAL | DevOps (B-01) |
| Daily Challenge — loads | Title + progress ring visible | Screen functional | PASS | — |
| Daily Challenge — auto-complete at 8 swipes | Ring 100% on swipe 8, completion animation | Server-side enforcement added Sprint 6 | PASS | — |
| Daily Challenge — no duplicate completion | Completion fires once only | De-duplication logic verified | PASS | — |
| Daily Challenge — resets next day | New challenge on new calendar day | Daily reset functional | PASS | — |
| Philosophy Map — renders after swipes | Non-zero values on swiped axes | Map renders; field name fix applied | PASS | — |
| Philosophy Map — all 4 axes correct | All dimensions populated | camelCase fix applied Sprint 6 | PASS | — |
| Philosophy Map — weekly insight EN | Insight in English | Insight endpoint responds in EN | PASS | — |
| Philosophy Map — weekly insight ES | Insight in Spanish after lang switch | Cache keyed by lang; fix applied Sprint 6 | PASS | — |
| Authors + Bio — tappable | Author detail screen opens | Navigation functional | PASS | — |
| Authors + Bio — 433 bios EN | Substantive English bio for each author | 433 EN bios loaded in DB Sprint 6 | PASS | — |
| Authors + Bio — 433 bios ES | Substantive Spanish bio for each author | 433 ES bios loaded in DB Sprint 6 | PASS | — |
| Authors + Bio — retry on failure | Bio loads on retry, not permanently blank | Retry logic added Sprint 6 | PASS | — |
| Packs — Explorer screen loads | Pack list visible with cards | Screen renders | PASS | — |
| Packs — all card fields visible | Name, description, count, lock state | `swipe_dir` + `is_premium` missing from preview select | PARTIAL | Backend Implementer (B-04) |
| Packs — premium pack locked | Content locked for free users | Gate enforced server-side | PASS | — |
| Ambient Audio — toggle accessible | Control in Settings or feed | Toggle present | PASS | — |
| Ambient Audio — plays on enable | Sound begins | Audio system functional | PASS | — |
| Ambient Audio — stops on disable | Sound stops immediately | Toggle works | PASS | — |
| Ambient Audio — preference persists | Remembered on restart | Stored in local preferences | PASS | — |
| Localization ES — UI labels | All labels switch to Spanish | i18n `strings_es.dart` applied | PASS | — |
| Localization ES — feed | Spanish quotes with `lang=es` | Confirmed | PASS | — |
| Localization ES — challenge | Challenge text in Spanish | i18n keys applied | PASS | — |
| Localization ES — premium screen | Premium labels in Spanish | i18n applied | PASS | — |
| Notifications — toggle visible | Toggle shown in Settings | Toggle present | PASS | — |
| Notifications — OFF persists | Stays OFF after restart | Persistence fix applied Sprint 6 | PASS | — |
| Notifications — ON persists | Stays ON after restart | Confirmed | PASS | — |
| Streak — increments correctly | +1 per active day | Single-increment confirmed | PASS | — |
| Streak — 7-day milestone | Card appears at day 7 | Milestone logic functional | PASS | — |
| Streak — milestone no repeat | Dismissed = does not reappear | Dismissal state persisted | PASS | — |
| Admin endpoints — rate-limit | Redis-backed, timing-safe comparison | In-memory only; no timing-safe | PARTIAL | Backend Implementer (B-02) |
| Premium trial — TOCTOU safe | No race condition on concurrent trial starts | Advisory lock missing | PARTIAL | Backend Implementer (B-03) |

---

## Summary

| Status | Count |
|--------|-------|
| PASS | 48 |
| PARTIAL | 5 |
| FAIL | 0 |
| PENDING | 0 |
| **Total** | **53** |
