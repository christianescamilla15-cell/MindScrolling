# Release Workflow — MindScrolling
**Last updated:** 2026-03-18

This document is the authoritative step-by-step guide for releasing MindScrolling to production. Follow every step in order. Do not skip gate checks.

---

## Pre-Release Gate Checklist

Before beginning this workflow, all of the following must be true. If any item is NO, stop and resolve it first.

| Gate | Required value | Current status |
|------|---------------|---------------|
| Build Quality Score | >= 90/100 | NO — 82/100 (Build #1) |
| Critical open blockers | 0 | NO — B-01 open |
| Major open blockers | 0 (or written Product Owner acceptance) | NO — B-02, B-03 open |
| Integration QA | PASS | YES |
| Release QA | PASS | NO — pending |
| Crash-free baseline | Collected on 3+ physical Android devices | NO — pending |
| RevenueCat sandbox test | PASS | NO — pending |
| dashboard.md last updated | Within 48 hours | YES (2026-03-18) |

**Current release status: BLOCKED.** Do not proceed with this workflow until all gate items are YES.

---

## Step 1: Confirm final score and blockers

1. Open `cloud/control_tower/dashboard.md` and confirm score >= 90.
2. Open `cloud/control_tower/blockers.md` and confirm zero open Critical or Major blockers.
3. Open `cloud/control_tower/release_status.md` and confirm it reads READY.
4. If any of the above are not true: STOP. This workflow cannot proceed.

---

## Step 2: Final code state

1. Confirm the main branch is clean:
   ```bash
   git status
   # Expected: nothing to commit, working tree clean
   ```
2. Confirm the latest commit includes all Sprint 7 fixes:
   ```bash
   git log --oneline -10
   ```
3. Confirm no local-only changes exist that have not been pushed:
   ```bash
   git diff origin/main
   # Expected: empty diff
   ```

---

## Step 3: Backend deploy to Railway (production)

1. Confirm Railway project is configured:
   - `SUPABASE_URL` environment variable set to production Supabase URL
   - `SUPABASE_ANON_KEY` set to production anon key
   - `PORT` set (Railway sets this automatically)
   - `ALLOWED_ORIGIN` set to the app's deep link or `*` for mobile-only backend
   - `ADMIN_SECRET` set to a strong random value (not the development default)

2. Deploy:
   ```bash
   # From the repository root, push to Railway via git or Railway CLI
   railway up
   ```

3. Confirm deployment succeeded:
   ```bash
   curl https://[your-railway-url]/health
   # Expected: { "status": "ok", "ts": "..." }
   ```

4. Confirm feed endpoint on production:
   ```bash
   curl -H "X-Device-ID: smoke-test-uuid-001" \
     "https://[your-railway-url]/quotes/feed?lang=en"
   # Expected: { "data": [...], "next_cursor": "...", "has_more": true }
   ```

5. If either curl fails: rollback deployment. Do not proceed to Step 4.

---

## Step 4: Flutter APK / App Bundle build

1. Update `flutter_app/lib/core/constants/api_constants.dart` — confirm `baseUrl` points to the Railway production URL (not `localhost:3000`).

2. Build the release APK:
   ```bash
   cd flutter_app
   flutter build apk --release
   # Output: build/app/outputs/flutter-apk/app-release.apk
   ```

3. Build the App Bundle (required for Play Store):
   ```bash
   flutter build appbundle --release
   # Output: build/app/outputs/bundle/release/app-release.aab
   ```

4. Confirm build exits 0 with no errors.

---

## Step 5: Final smoke test on physical device

Install the release APK on a physical Android device (not an emulator):

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

Run through the core loop manually:
- [ ] App launches, onboarding completes
- [ ] Feed loads with quotes from the Railway production backend
- [ ] Swipe in all 4 directions — haptic fires, categories correct
- [ ] Navigate to Vault — displays correctly
- [ ] Navigate to Daily Challenge — progress ring visible
- [ ] Navigate to Philosophy Map — radar chart renders
- [ ] Navigate to Premium screen — price ($4.99) displayed, trial status shown
- [ ] Navigate to Settings — language toggle works, notification toggle works
- [ ] Navigate to Packs — pack cards render with name, description, count
- [ ] Like a quote — appears in vault

If any step fails: do not submit to Play Store. Diagnose and fix. Re-run from Step 1.

---

## Step 6: Google Play Store submission

1. Open Google Play Console.
2. Navigate to the app → Production track → Create new release.
3. Upload `app-release.aab` from `flutter_app/build/app/outputs/bundle/release/`.
4. Confirm release notes are written in both EN and ES.
5. Confirm store listing is complete:
   - App name: MindScrolling
   - Short description (EN + ES)
   - Full description (EN + ES)
   - Screenshots (minimum 2 phone screenshots per language)
   - Feature graphic
   - App icon (512x512)
   - Content rating completed
   - Privacy policy URL set
6. Submit for review.
7. Record submission date in SCRUM.md and build_history.md.

---

## Step 7: Post-release Control Tower update

After Google Play submission:

1. Update `cloud/control_tower/build_history.md` — mark the release build row as "Released" with the submission date.
2. Update `cloud/control_tower/release_status.md` — change to RELEASED with the Play Store submission date.
3. Update `cloud/control_tower/dashboard.md` — reflect released status.
4. Update `SCRUM.md` — close Sprint 7 with completion date and velocity.
5. Update `BACKLOG.md` — mark S7-06 and completed Sprint 7 P0 items as done.

---

## Rollback Plan

If a critical bug is discovered post-submission but before review approval:
1. Navigate to Play Console → Production → Edit release → Remove the submitted release.
2. Fix the bug.
3. Re-run this workflow from Step 1.

If a critical bug is discovered after public release:
1. Immediately disable affected feature server-side via a feature flag or route handler patch (no app update required for backend-controlled features).
2. File the bug in debug_log.md as Critical.
3. Build and submit an expedited patch release.
4. Do not wait for the next sprint cycle — critical post-launch bugs are treated as P0 with same-day response.
