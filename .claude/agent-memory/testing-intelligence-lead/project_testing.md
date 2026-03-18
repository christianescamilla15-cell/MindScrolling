---
name: MindScrolling - Testing Intelligence context
description: Tester cohort, infrastructure, and known patterns as of Sprint 7 (2026-03-18)
type: project
---

## Tester Cohort

- Size: up to 12 human testers
- Recruitment channel: WhatsApp (coordinator: 525546822297, México CDMX)
- Feedback channels: WhatsApp messages + GitHub Pages form
- Tester form URL: https://christianescamilla15-cell.github.io/MindScrolling/
- Form deployed via: `.github/workflows/pages.yml`

## Form Captures

- Tester name, device model, OS version
- App version (build number)
- User state tested: Free / Trial / Inside
- Module tested (4 modules defined in form)
- Screenshots (up to 3)
- Description (free text)
- Auto-send to WhatsApp on submit

## Testing Infrastructure

- Dev Tools panel in app: tap version number 5× in Settings → hidden panel to switch Free/Trial/Inside without DB changes (SharedPreferences override in `premium_controller.dart`)
- No remote crash reporting yet (Sentry / Firebase Crashlytics not integrated)
- App version: tracked in `pubspec.yaml`

## Known Issue Patterns (post-Sprint 7)

All QA bugs from Sprint 7 resolved:
- CRIT-01: premium.js missing product_id in restore insert ✅ Fixed
- CRIT-03: Badge showed "Included in Inside" for pack owners ✅ Fixed
- HIGH-02: Double navigation hop for entitled users ✅ Fixed
- HIGH-04: restorePurchases didn't refresh owned_packs ✅ Fixed
- HIGH-05: PaywallCard hardcoded price ✅ Fixed

## Pending Monitoring

- Trial 1,000-quote limit: currently only time-based (7 days). Quote count limit not yet enforced server-side.
- RevenueCat integration: stub (SnackBar "Próximamente") — receipt validation not yet implemented
- Reflection card: fixed in Sprint 7 (no count + auto-dismiss 4s + no horizontal swipe)

## App Behavior to Know

- Free limit: 20 swipes/day (client-side), 20 vault quotes
- Trial: 7 days OR 1,000 quotes (whichever first)
- Reflection card: appears every 5 real swipes, auto-dismisses after 4s, does NOT count toward 20-swipe limit
- Swipe-back: left edge (20dp), velocity>300px/s or offset>100px → go back
- Pack preview: Free=5 quotes, Trial=15 quotes, Inside/purchased=full feed

**Why:** Human testing about to begin at scale. Testing Intelligence Lead activates now.
**How to apply:** On receiving first tester batch, process all reports through triage format before passing to engineering agents. Detect version mismatches (check if tester is on latest build) before diagnosing bugs.
