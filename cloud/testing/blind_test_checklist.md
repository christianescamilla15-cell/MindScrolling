# Blind Test Checklist — Sprint 6 QA Gate
**Date:** 2026-03-18
**Version:** Build #1
**Instructions:** Execute each step as a real user. Do not look at code. Record PASS or FAIL in the checkbox. Add notes when behavior is unexpected.

---

## Prerequisites

- [ ] Backend is running (Railway or localhost:3000)
- [ ] `GET http://localhost:3000/health` returns `{ "status": "ok" }`
- [ ] Flutter app installed on a physical or emulated Android device
- [ ] Three test device IDs prepared: fresh ID (no history), 20-quote vault ID, premium ID
- [ ] App language set to EN for baseline; will switch to ES where noted

---

## 1. Feed

### 1.1 Feed loads on cold start
- Open the app with a fresh device ID
- Observe the feed screen
- [ ] PASS — First quote card appears within 3 seconds
- [ ] FAIL — Feed is blank, stuck loading, or shows an error

### 1.2 Feed loads next batch on scroll
- Swipe through 10 quotes continuously
- [ ] PASS — New quotes appear; no "end of feed" error before 20+ quotes
- [ ] FAIL — Feed stops loading after initial batch

### 1.3 Feed category balance (cold start)
- With a fresh device ID, note the category label on the first 10 quote cards
- [ ] PASS — At least 3 distinct categories appear in the first 10 cards
- [ ] FAIL — 7 or more consecutive cards share a single category

### 1.4 Feed language (EN)
- Language set to EN
- [ ] PASS — All quote text is in English
- [ ] FAIL — Non-English quotes appear in EN mode

### 1.5 Feed language (ES)
- Switch language to ES in Settings. Return to feed.
- [ ] PASS — All quote text is in Spanish
- [ ] FAIL — English quotes appear in ES mode

---

## 2. Swipe (4 directions)

### 2.1 Swipe UP (Stoicism)
- Swipe a quote card upward
- [ ] PASS — Card animates UP, category indicator shows "Stoicism/Wisdom", haptic fires on physical device
- [ ] FAIL — Card does not animate, wrong category registered, or no haptic

### 2.2 Swipe RIGHT (Discipline)
- Swipe a quote card to the right
- [ ] PASS — Card animates RIGHT, category indicator shows "Discipline/Growth", haptic fires
- [ ] FAIL — Card does not animate, wrong category, or no haptic

### 2.3 Swipe LEFT (Reflection)
- Swipe a quote card to the left
- [ ] PASS — Card animates LEFT, category indicator shows "Reflection/Life", haptic fires
- [ ] FAIL — Card does not animate, wrong category, or no haptic

### 2.4 Swipe DOWN (Philosophy)
- Swipe a quote card downward
- [ ] PASS — Card animates DOWN, category indicator shows "Philosophy/Existential", haptic fires
- [ ] FAIL — Card does not animate, wrong category, or no haptic

### 2.5 Swipe event recorded
- Complete 3 swipes in different directions. Check profile/stats.
- [ ] PASS — Reflection count increments by 1 per swipe (not 2)
- [ ] FAIL — Reflection count increments by 2, or does not increment

---

## 3. Like

### 3.1 Like a quote
- Tap the heart/like button on a quote card
- [ ] PASS — Heart icon fills/animates. Quote appears in Vault.
- [ ] FAIL — Heart does not respond, or quote does not appear in Vault

### 3.2 Unlike a quote
- Tap the like button on a quote already liked
- [ ] PASS — Heart icon reverts. Quote removed from Vault.
- [ ] FAIL — Like state does not toggle

### 3.3 Like persists across sessions
- Like a quote. Close and reopen the app.
- [ ] PASS — Previously liked quote still shows as liked
- [ ] FAIL — Like state resets on restart

---

## 4. Vault

### 4.1 Vault displays saved quotes
- Save 3 quotes. Navigate to Vault screen.
- [ ] PASS — All 3 quotes visible in vault list
- [ ] FAIL — Vault is empty or quotes are missing

### 4.2 Vault free limit (20 quotes)
- Using a non-premium device ID, save quotes until reaching 20 in the vault. Attempt to save a 21st.
- [ ] PASS — 21st save is blocked. Upgrade prompt appears. Vault count stays at 20.
- [ ] FAIL — 21st quote saves, app crashes, or error toast is unhandled

### 4.3 Vault premium unlimited
- Using a premium device ID, save 25+ quotes to the vault.
- [ ] PASS — All 25+ quotes save. No paywall prompt.
- [ ] FAIL — Block fires for premium user, or count is capped

### 4.4 Vault export (.txt)
- With 5+ quotes in vault, tap Export button
- [ ] PASS — System share sheet appears with a .txt file. File contains saved quotes in readable text.
- [ ] FAIL — Export fails, file is empty, or export is blocked by a premium gate

---

## 5. Premium

### 5.1 Premium screen renders
- Navigate to the Premium / Upgrade screen
- [ ] PASS — Screen shows pricing ($4.99 USD), feature comparison, and CTA button
- [ ] FAIL — Screen is blank, crashes, or price is missing

### 5.2 Premium gate blocks non-premium users
- On a non-premium device ID, attempt to access a premium feature (content packs or export image)
- [ ] PASS — Feature is blocked. Upgrade CTA shown.
- [ ] FAIL — Premium content accessible, or app crashes

### 5.3 Trial activation (first-time user)
- Use a brand-new device ID. Complete onboarding.
- [ ] PASS — Trial activated. "Trial active — X days remaining" visible on premium screen.
- [ ] FAIL — Trial not started, days = 0, or error on first launch

### 5.4 Premium status persists
- Activate or confirm premium. Close and reopen app.
- [ ] PASS — Premium status still active after restart
- [ ] FAIL — Premium status lost on restart

---

## 6. Daily Challenge

### 6.1 Challenge loads
- Navigate to the Daily Challenge screen (or observe challenge card in feed)
- [ ] PASS — Challenge title and progress ring visible
- [ ] FAIL — Challenge screen blank or missing

### 6.2 Challenge auto-completes at exactly 8 swipes
- Fresh device ID or reset challenge. Swipe quotes one at a time. Count swipes.
- [ ] PASS — Challenge ring reaches 100% on swipe 8. Completion animation fires.
- [ ] FAIL — Completes before swipe 8, after swipe 8, or does not complete

### 6.3 Challenge does not re-trigger after completion
- Complete the challenge (8 swipes). Continue swiping 5 more times.
- [ ] PASS — Completion animation fires once only. No duplicate completion.
- [ ] FAIL — Completion animation fires again on subsequent swipes

### 6.4 Challenge resets the next day
- Complete today's challenge. Change device clock to tomorrow (or wait). Open app.
- [ ] PASS — New challenge appears with progress at 0
- [ ] FAIL — Yesterday's completed challenge still shows as active challenge

---

## 7. Philosophy Map

### 7.1 Map renders after swipes
- Complete 5+ swipes in different directions. Navigate to Philosophy Map screen.
- [ ] PASS — Radar chart shows non-zero values for swiped categories
- [ ] FAIL — Chart is empty, all zeros, or does not render

### 7.2 Map field names correct
- Navigate to Philosophy Map on a device with swipe history. Check all 4 axes.
- [ ] PASS — All 4 dimensions (Stoicism, Discipline, Reflection, Philosophy) display values
- [ ] FAIL — One or more axes show 0 or null despite swipe history

### 7.3 Weekly insight language binding
- Set language to ES. View weekly insight on Philosophy Map.
- [ ] PASS — Insight text is in Spanish
- [ ] FAIL — Insight is in English while app language is ES

- Switch language to EN. View weekly insight again.
- [ ] PASS — Insight text is now in English (not stale Spanish)
- [ ] FAIL — Insight remains in Spanish after language switch

---

## 8. Authors + Bio

### 8.1 Author name tappable
- On a quote card, tap the author name
- [ ] PASS — Author detail screen opens
- [ ] FAIL — Tap does nothing or crashes

### 8.2 Author bio loads (EN)
- Language set to EN. Tap on 3 different author names.
- [ ] PASS — Each author shows a substantive bio in English
- [ ] FAIL — Any bio is empty, placeholder, or in wrong language

### 8.3 Author bio loads (ES)
- Language set to ES. Tap on 3 different author names.
- [ ] PASS — Each author shows a substantive bio in Spanish
- [ ] FAIL — Any bio is empty, placeholder, or in English

### 8.4 Author bio retry
- Tap an author on a slow connection (toggle airplane mode briefly then off). Observe bio screen.
- [ ] PASS — Bio loads after retry. Loading indicator shown during retry.
- [ ] FAIL — Bio stays blank permanently after a failed first attempt

---

## 9. Packs

### 9.1 Packs Explorer screen loads
- Navigate to the Packs section
- [ ] PASS — Pack list loads. At least 1 pack card visible.
- [ ] FAIL — Screen is blank or crashes

### 9.2 Pack cards show all fields
- On the Packs Explorer, inspect each visible pack card
- [ ] PASS — Each card shows: pack name, description, quote count, lock/unlock state
- [ ] FAIL — Any pack card has a blank name, missing description, or missing quote count

### 9.3 Premium pack locked for free users
- Non-premium device ID. Tap on a premium pack.
- [ ] PASS — Pack content is locked. Upgrade prompt shown.
- [ ] FAIL — Premium pack content accessible without payment

---

## 10. Ambient Audio

### 10.1 Audio toggle accessible
- Navigate to Settings or the feed audio control
- [ ] PASS — Audio toggle or control visible
- [ ] FAIL — Audio controls missing from UI

### 10.2 Audio plays
- Enable ambient audio
- [ ] PASS — Audio begins playing. No crash.
- [ ] FAIL — App crashes, no audio plays, or toggle has no effect

### 10.3 Audio stops
- Disable ambient audio
- [ ] PASS — Audio stops immediately
- [ ] FAIL — Audio continues after toggle off

### 10.4 Audio state persists
- Enable audio. Close and reopen app.
- [ ] PASS — Audio preference remembered (enabled on reopen)
- [ ] FAIL — Audio preference resets

---

## 11. Localization (ES)

### 11.1 Language switch to ES
- In Settings, switch language to ES
- [ ] PASS — All UI labels switch to Spanish immediately or after app restart
- [ ] FAIL — Any UI label remains in English after language switch

### 11.2 Feed in ES
- With ES selected, load feed
- [ ] PASS — Quotes are in Spanish
- [ ] FAIL — English quotes appear in ES mode

### 11.3 Challenge text in ES
- With ES selected, view Daily Challenge screen
- [ ] PASS — Challenge title and description in Spanish
- [ ] FAIL — Challenge text in English when app is in ES mode

### 11.4 Premium screen in ES
- With ES selected, view Premium screen
- [ ] PASS — All pricing labels and feature descriptions in Spanish
- [ ] FAIL — English text visible on premium screen in ES mode

---

## 12. Notifications

### 12.1 Notification toggle visible in Settings
- Navigate to Settings
- [ ] PASS — Notification toggle visible and shows current state
- [ ] FAIL — Toggle missing from Settings

### 12.2 Toggle OFF persists across restart
- Toggle notifications OFF. Close and reopen app. Check Settings.
- [ ] PASS — Toggle still shows OFF
- [ ] FAIL — Toggle resets to ON after restart

### 12.3 Toggle ON persists across restart
- Toggle notifications ON. Close and reopen app. Check Settings.
- [ ] PASS — Toggle still shows ON
- [ ] FAIL — Toggle resets to OFF after restart

---

## 13. Streak Milestones

### 13.1 Streak increments correctly
- Swipe 5 quotes. Check streak counter in profile.
- [ ] PASS — Streak shows 1 (one session today)
- [ ] FAIL — Streak shows 0, 2, or a wrong value

### 13.2 Streak milestone card (7 days)
- Use a device ID with a 7-day streak (or advance clock). Open app.
- [ ] PASS — Milestone card appears acknowledging 7-day streak
- [ ] FAIL — No milestone card, or wrong milestone threshold

### 13.3 Milestone does not repeat
- Dismiss the 7-day milestone card. Close and reopen app.
- [ ] PASS — Milestone card does not reappear
- [ ] FAIL — Milestone card reappears on subsequent launches

---

## Summary Tally

After completing all checks, fill in:

| Area | Total Checks | PASS | FAIL | PARTIAL |
|------|-------------|------|------|---------|
| Feed | 5 | | | |
| Swipe | 5 | | | |
| Like | 3 | | | |
| Vault | 4 | | | |
| Premium | 4 | | | |
| Daily Challenge | 4 | | | |
| Philosophy Map | 3 | | | |
| Authors + Bio | 4 | | | |
| Packs | 3 | | | |
| Ambient Audio | 4 | | | |
| Localization ES | 4 | | | |
| Notifications | 3 | | | |
| Streak Milestones | 3 | | | |
| **TOTAL** | **53** | | | |

**Overall result:** PASS / FAIL / PARTIAL
**Tester:** _______________
**Date:** _______________
**Build:** Build #1
