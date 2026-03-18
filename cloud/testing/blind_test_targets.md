# Blind Test Targets — Sprint 6 QA Gate
**Date:** 2026-03-18
**Scope:** All CRIT/HIGH/MED/LOW fixes applied in Sprint 6 correction session
**Tester:** Any agent or human — must not rely on code review, only observed behavior

---

## How to use this document

Each target entry describes a specific fix from Sprint 6. Testers verify the fix produced the expected visible result without referencing code. A target is PASS only if the exact expected result is observed. Anything else is FAIL or PARTIAL.

---

## T-01 — Challenge Auto-Complete at 8 Swipes

**Feature:** Daily Challenge
**Sprint 6 fix:** Challenge completion now enforced server-side; previously the backend allowed bypassing the 8-swipe requirement.
**Expected user action:** Open app with a fresh device ID. Swipe quotes one at a time. Count swipes on the challenge progress ring.
**Expected visible result:** At exactly 8 swipes, the challenge ring reaches 100%, the completion animation fires, and the challenge card is marked done. No completion before swipe 8. No duplicate completions if the user continues swiping.
**Pass condition:** Challenge completes on swipe 8 and only swipe 8. Subsequent swipes do not re-trigger completion.
**Fail condition:** Challenge completes before swipe 8, after swipe 8, or triggers multiple times.

---

## T-02 — Vault Free Limit (20 quotes)

**Feature:** Vault
**Sprint 6 fix:** Free-tier vault enforces a hard limit of 20 saved quotes server-side (previously the limit was only checked client-side).
**Expected user action:** Use a non-premium device ID. Like quotes until 20 are saved to the vault. Attempt to save a 21st quote.
**Expected visible result:** The 21st save attempt is blocked. A paywall or upgrade prompt appears. The vault count stays at 20. No error toast showing a backend crash — the block must be clean and intentional.
**Pass condition:** Block fires at item 21. Upgrade prompt visible. Vault count does not exceed 20.
**Fail condition:** The 21st quote saves successfully, or an unhandled error appears, or the app crashes.

---

## T-03 — Vault Premium Unlimited

**Feature:** Vault (Premium)
**Sprint 6 fix:** Premium users bypass the 20-quote vault limit.
**Expected user action:** Use a device ID that has premium status. Save more than 20 quotes to the vault.
**Expected visible result:** All quotes save successfully. No paywall prompt. Vault displays all saved quotes.
**Pass condition:** 21+ quotes saved with no interruption.
**Fail condition:** Paywall or block appears for a premium user.

---

## T-04 — Premium Gate Enforcement

**Feature:** Premium
**Sprint 6 fix:** Premium features (unlimited vault, content packs, export) are now gated server-side, not only client-side.
**Expected user action:** On a non-premium device ID, attempt to access a premium-only feature (e.g., content packs, export).
**Expected visible result:** Feature is blocked. Upgrade screen appears or a clear locked state is shown. No premium content is revealed.
**Pass condition:** Premium gate blocks access on a non-premium device. Upgrade CTA visible.
**Fail condition:** Premium content accessible without purchase, or the app crashes when the gate fires.

---

## T-05 — Feed Category Balance

**Feature:** Feed
**Sprint 6 fix:** Feed now returns a balanced mix of categories. Previously, category weights could skew the feed to one category for new users.
**Expected user action:** Fresh device ID, no swipe history. Load the feed and note the categories of the first 10 quotes.
**Expected visible result:** The first 10 quotes include at least 2 different categories. The feed does not open with 8+ consecutive quotes from one category.
**Pass condition:** At least 3 distinct categories visible in the first 10 quotes.
**Fail condition:** 7 or more consecutive quotes from a single category on a cold start.

---

## T-06 — Author Retry Logic

**Feature:** Authors + Bio
**Sprint 6 fix:** When an author bio fetch fails, the app retries instead of showing an empty bio silently.
**Expected user action:** Open an author profile. Simulate a slow connection or navigate to an author with a long name. Observe bio loading.
**Expected visible result:** If bio loading fails initially, a retry occurs automatically. The bio eventually appears. No permanently blank bio card.
**Pass condition:** Bio loads on retry. Loading indicator visible during retry.
**Fail condition:** Bio card stays empty permanently after a failed fetch.

---

## T-07 — Notification Toggle (Settings)

**Feature:** Notifications
**Sprint 6 fix:** The notification toggle in Settings now correctly persists its state and does not reset on app restart.
**Expected user action:** Go to Settings. Toggle notifications OFF. Close and reopen the app. Go back to Settings.
**Expected visible result:** The toggle remains in the OFF position after restart.
**Pass condition:** Toggle state persists across app restarts.
**Fail condition:** Toggle resets to ON after restart.

---

## T-08 — Weekly Insight Language Binding

**Feature:** Localization (ES/EN)
**Sprint 6 fix:** The weekly insight card (Philosophy Map) now respects the user's selected language. Cache is keyed by language, so switching language invalidates the previous cache.
**Expected user action:** Set language to ES. View the weekly insight on the Philosophy Map screen. Switch language to EN. View the weekly insight again.
**Expected visible result:** In ES mode, insight text is in Spanish. After switching to EN, insight text is in English. The content is not stale from the previous language.
**Pass condition:** Insight language matches UI language after any switch.
**Fail condition:** Insight remains in previous language after language switch, or insight is blank after switching.

---

## T-09 — Packs Explorer Screen

**Feature:** Packs
**Sprint 6 fix:** Packs Explorer screen renders correctly after a bug where missing field names in the API response caused pack cards to render blank.
**Expected user action:** Navigate to the Packs section. View the list of available packs.
**Expected visible result:** Each pack card shows: pack name, description, quote count, and lock/unlock state. No blank cards. No missing text.
**Pass condition:** All pack fields visible on all pack cards.
**Fail condition:** Any pack card renders blank or with missing fields (name, count, or description absent).

---

## T-10 — Haptic Feedback on Swipe

**Feature:** Swipe (4-dir)
**Sprint 6 fix:** Haptic feedback fires correctly on all 4 swipe directions after it was broken for the DOWN direction.
**Expected user action:** On a physical Android device, swipe in all 4 directions one at a time.
**Expected visible result:** A haptic pulse is felt for each swipe direction (UP, RIGHT, LEFT, DOWN). No direction is silent.
**Pass condition:** Haptic fires on all 4 swipe directions.
**Fail condition:** One or more swipe directions produce no haptic feedback.

---

## T-11 — Trial Fallback for First-Time Users

**Feature:** Premium / Trial
**Sprint 6 fix:** First-time users now correctly receive a 7-day trial. Previously, the trial start could silently fail if the backend encountered an edge case on first install.
**Expected user action:** Use a brand-new device ID (never seen by the backend). Open the app and proceed through onboarding.
**Expected visible result:** Trial is activated automatically. The premium screen shows "Trial active — X days remaining". No error on first launch.
**Pass condition:** Trial active and days-remaining counter visible after first onboarding completion.
**Fail condition:** Trial not activated, error shown, or days-remaining shows 0 immediately.

---

## T-12 — Map Field Names (Philosophy Map)

**Feature:** Philosophy Map
**Sprint 6 fix:** Backend map endpoint now returns field names matching what the Flutter client expects (camelCase alignment fixed).
**Expected user action:** Navigate to the Philosophy Map screen after completing at least 5 swipes.
**Expected visible result:** The radar chart renders with values. No blank or zero-filled chart on a device that has swipe history.
**Pass condition:** Radar chart shows non-zero values for categories the user has swiped.
**Fail condition:** Radar chart is empty or all zeros despite existing swipe history.

---

## T-13 — Vault Export (Free Feature)

**Feature:** Vault Export
**Sprint 6 fix:** Vault export as plain text (.txt) is functional and available to all users (free feature).
**Expected user action:** Save 3+ quotes to the vault. Tap the Export button.
**Expected visible result:** A .txt file is generated and offered via the system share sheet. File content includes the saved quotes in readable format.
**Pass condition:** Export produces a non-empty .txt file with the user's saved quotes.
**Fail condition:** Export fails, produces an empty file, or is incorrectly gated behind premium.

---

## T-14 — 433 Author Bios (EN + ES)

**Feature:** Authors + Bio
**Sprint 6 fix:** 433 author bios added to the database in both English and Spanish.
**Expected user action:** Tap on 5 different author names across different quotes (in both EN and ES modes).
**Expected visible result:** A bio appears for each author in the current app language. Bio text is substantive (not placeholder text).
**Pass condition:** 5/5 author taps show a real bio in the correct language.
**Fail condition:** Any author tap shows empty bio, placeholder text, or the wrong language.

---

## T-15 — Streak Milestone Display

**Feature:** Streak Milestones
**Sprint 6 fix:** Streak milestone card (7-day, 30-day) displays correctly and does not re-trigger after being dismissed.
**Expected user action:** Use a device ID with a 7-day streak. Open the app.
**Expected visible result:** A milestone card appears acknowledging the 7-day streak. After dismissing, reopening the app does not show the card again for the same milestone.
**Pass condition:** Milestone shows exactly once per streak milestone. Dismissal persists.
**Fail condition:** Milestone never shows, shows every session, or shows for the wrong streak count.
