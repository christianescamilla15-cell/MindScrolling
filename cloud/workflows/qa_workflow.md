# QA Workflow — MindScrolling
**Last updated:** 2026-03-18

This document defines the complete QA process for MindScrolling. Every release, sprint close, and major code change must pass through the applicable QA levels before proceeding.

---

## CRITICAL RULE

> If any QA level fails, all work STOPS at that level.
> No new features. No deploys. No release decisions.
> The failure must be diagnosed, fixed, and the QA level re-run from the beginning before continuing.

---

## QA Levels Overview

| Level | Scope | Who runs it | When |
|-------|-------|------------|------|
| Micro QA | Boot, health, feed load, no crash | QA Agent | Every iteration |
| Feature QA | Feature-level correctness, known issue verification | QA Agent | After any feature or logic change |
| Integration QA | Frontend-backend contract alignment | QA Agent | After any API or model change |
| Release QA | Full end-to-end on production + real devices | QA Agent | Before any release only |

---

## Level 1: Micro QA

**Trigger:** Every iteration, no exceptions.

### Checks

| Check | Pass condition | Fail condition |
|-------|---------------|----------------|
| Flutter build compiles | `flutter build apk` exits 0 with no errors | Any compile error |
| App launches on device/emulator | App opens to bootstrap screen within 5s | Crash on launch, blank screen |
| Backend `/health` endpoint responds | `{"status":"ok"}` returned within 2s | 5xx, timeout, or wrong response shape |
| Feed endpoint loads quotes | `/quotes/feed?lang=en` returns `data` array with >= 1 quote | Empty array, 4xx, or 5xx |
| Device ID assigned | `X-Device-ID` header set on all requests after first launch | Missing header, UUID regenerated on every launch |
| No crash on first swipe | Swipe a quote card in any direction without crash | App crashes on swipe |

### Fail response
Stop all work. Open an issue in `cloud/debugging/debug_log.md`. Assign to the appropriate agent. Do not proceed to Feature QA until Micro QA passes clean.

---

## Level 2: Feature QA

**Trigger:** After any change to feature logic, route handlers, models, providers, or UI.
Scope is the changed feature(s) plus any directly adjacent features.

### Checks — Feed
- Feed loads with cursor pagination
- Category balance: 3+ categories in first 10 cards on cold start
- `lang=en` returns English quotes, `lang=es` returns Spanish quotes
- Adaptive scoring increases weight for swiped categories on subsequent loads

### Checks — Swipe
- UP = stoicism/wisdom category recorded
- RIGHT = discipline/growth category recorded
- LEFT = reflection/life category recorded
- DOWN = philosophy/existential category recorded
- Haptic fires on all 4 directions on physical device
- Reflection count increments by exactly 1 per swipe

### Checks — Vault
- Like saves quote to vault
- Unlike removes quote from vault
- Free tier: 21st save attempt is blocked server-side with upgrade prompt
- Premium: 21+ saves succeed with no block
- Vault list renders all saved quotes

### Checks — Premium
- Non-premium device: premium features locked, upgrade CTA visible
- Premium device: all premium features accessible
- Trial: activated on first onboarding completion, days remaining displayed correctly
- Premium status persists across app restarts

### Checks — Daily Challenge
- Challenge loads with title and progress ring
- Progress ring advances 1/8 per swipe
- At exactly 8 swipes: completion animation fires, challenge marked done
- After completion: subsequent swipes do not re-trigger completion
- Next day: new challenge with progress at 0

### Checks — Philosophy Map
- Radar chart renders with non-zero values after 5+ swipes
- All 4 axes (stoicism, discipline, reflection, philosophy) reflect swipe history
- Weekly insight language matches app language (not stale from previous language)

### Checks — Authors + Bio
- Tapping author name opens author detail screen
- Author bio loads in current app language (EN or ES)
- On failed bio fetch: retry occurs, loading indicator shown, bio eventually appears

### Checks — Packs
- Packs Explorer renders all pack cards with name, description, count, lock state
- Premium pack content locked for free-tier device
- Upgrade prompt shown on locked pack tap

### Checks — Localization (ES)
- UI labels in Spanish after language switch
- Quotes in Spanish in feed
- Challenge, premium, and settings screens in Spanish

### Checks — Notifications
- Toggle visible in Settings
- Toggle OFF state persists across app restarts
- Toggle ON state persists across app restarts

### Checks — Streak
- Streak increments correctly (+1 per active day)
- 7-day milestone card appears at streak day 7
- Milestone card dismissed state persists (does not reappear)

### Pass condition
All checks for all changed features return expected results. No adjacent features produce unexpected behavior.

### Fail condition
Any single check produces an unexpected result. Stop. Log in regression_log.md if this was previously passing. Log in debug_log.md if it is a new issue.

---

## Level 3: Integration QA

**Trigger:** After any change to:
- API response shape (field names, types, nesting)
- Flutter models (`fromJson`, field bindings)
- Backend route handler return values
- Supabase query select fields

### Checks

| Check | Method | Pass condition |
|-------|--------|---------------|
| Feed response shape | Inspect `/quotes/feed` response | `data`, `next_cursor`, `has_more` present; each quote has `id`, `text`, `author`, `category` |
| Challenge response shape | Inspect `/challenges/today` response | `challenge` object with `title`, `description`; `progress` object with `swipes`, `target`, `completed` |
| Map response shape | Inspect `/map` response | `current` object with `stoicism`, `discipline`, `reflection`, `philosophy` as numeric fields |
| Premium status shape | Inspect `/premium/status` response | `is_premium` boolean; `trial_active` boolean; `trial_days_remaining` integer |
| Vault response shape | Inspect `/vault` response | Array of quote objects with `id`, `text`, `author` |
| Author bio shape | Inspect `/authors/:id` response | `bio` string present and non-empty for known author IDs |
| Pack preview shape | Inspect `/packs` response | Each pack has `id`, `name`, `description`, `quote_count`, `swipe_dir`, `is_premium` |
| Swipe direction constants | Compare `feed_constants.dart` vs backend category enum | UP=stoicism, RIGHT=discipline, LEFT=reflection, DOWN=philosophy in both |

### Fail condition
Any field name mismatch, missing field, or type mismatch between Flutter model and backend response. Stop. Log in debug_log.md. Assign to Backend Implementer or Flutter Mobile Engineer depending on where the mismatch originates.

---

## Level 4: Release QA

**Trigger:** Only when ALL of the following are true:
- Score >= 90/100
- Zero Critical open blockers
- Zero Major open blockers (or all explicitly accepted with Product Owner written sign-off)
- Integration QA: PASS

### Checks

| Check | Environment | Pass condition |
|-------|-------------|---------------|
| Backend deployed to Railway production | Production | `/health` responds in production; no 5xx on feed endpoint |
| Flutter app connects to production backend | Production APK | API calls route to Railway URL, not localhost |
| RevenueCat + Play Billing sandbox purchase | Sandbox + physical Android | Purchase completes, `is_premium` set true server-side after webhook |
| Restore purchases flow | Physical Android | Restore recovers premium status on re-install |
| Crash-free baseline | 3 physical Android devices | App runs for 30 minutes with normal usage, zero crashes |
| Trial expiry UX | Device with trial at day 7-8 | Upgrade prompt appears on day 8 without manual trigger |
| Price localization | Android with locale set to MXN/BRL/ARS/COP | Correct prices displayed: MXN $79, BRL R$19.90, ARS automatic, COP $19,900 |
| Google Play store listing | Play Console | App bundle accepted, store listing complete, screenshots approved |

### Fail condition
Any check fails. Release is blocked. Log specific failure. Assign fix. Release QA must be re-run from the beginning after fixes are applied.

---

## QA Ownership

| Level | Run by | Results filed by |
|-------|--------|----------------|
| Micro QA | QA Agent | QA Agent → qa_status.md |
| Feature QA | QA Agent | QA Agent → qa_status.md + blind_test_status.md |
| Integration QA | QA Agent | QA Agent → qa_status.md |
| Release QA | QA Agent | QA Agent → qa_status.md + Documentation Writer → release_status.md |
