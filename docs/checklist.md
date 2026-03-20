# MindScrolling — Development Checklist

Current state: Sprint 7 (Google Play launch hardening). Build #3, score 91/100 — release eligible.

---

## Sprint 7 — P0 (Launch Blockers)

- [ ] Enable pgvector extension in Supabase Dashboard (Dashboard → Extensions → vector)
- [ ] Run 004_ai_feed.sql migration (requires pgvector enabled first)
- [ ] Run `npm run embed-quotes` one-time batch (~5,500 quotes, ~30 min)
- [ ] Deploy backend to Railway production (set all env vars from .env.example)
- [ ] Make GitHub repo private
- [ ] Google Play Store submission
- [ ] Validate RevenueCat + Google Play Billing (sandbox test full purchase flow)
- [ ] Restore purchases flow — verify on Android physical device
- [ ] Crash-free rate baseline — smoke test on 3 physical Android devices
- [ ] Trial expiry UX — confirm upgrade prompt appears on day 8

---

## Sprint 7 — P1 (First Month)

- [ ] Push notifications: daily reminder (local notification, not FCM)
- [ ] Philosophy Map weekly snapshot notification
- [ ] Sentry integration (backend) — add SENTRY_DSN to Railway env vars
- [ ] Feed query optimization (partial indexes migration 007 already applied)
- [ ] Trial-to-paid conversion analytics (server-side events)
- [ ] Onboarding completion rate tracking
- [ ] Price localization audit (MXN/BRL/ARS display)
- [ ] Vault export as plain text (confirm free tier access)

---

## Sprint 8 — Bloque B (Pack Monetization)

### Database
- [ ] DB migration: pack_purchases table

### Backend
- [ ] GET /packs — list all packs with user_access field
- [ ] GET /packs/:id/preview — preview with entitlement check
- [ ] GET /packs/:id/feed — paginated feed, entitlement-gated
- [ ] POST /packs/:id/purchase/verify — RevenueCat receipt validation

### Flutter
- [ ] Rewrite PacksScreen (currently basic)
- [ ] PackPreviewScreen — show locked/unlocked state
- [ ] PackFeedScreen — paginated swipe feed for pack content

### RevenueCat
- [ ] Create 3 pack products in RevenueCat dashboard
- [ ] Map product identifiers to pack IDs in backend

### QA
- [ ] Verify entitlement matrix — 15 combinations (free/trial/premium × pack states)

---

## Infrastructure (ongoing)

- [x] Supabase PostgreSQL — migrations 001–003 applied
- [x] Backend deployed to Render (https://mindscrolling.onrender.com)
- [x] Flutter app — Android APK builds in CI
- [x] Sentry SDK integrated (backend code ready — DSN config pending)
- [x] RevenueCat webhook handler (POST /webhooks/revenuecat — secret config pending)
- [ ] Railway production deployment (migrating from Render)
- [ ] pgvector enabled + 004_ai_feed.sql applied
- [ ] embed-quotes batch completed

---

## Completed (Sprint 6 + Sprint 7 Fixes)

- [x] Feed algorithm (vault_count, skip_count, total_dwell_ms, RPCs)
- [x] Swipe direction fix (stoicism/philosophy)
- [x] Author bios — 433 EN/ES loaded
- [x] Vault 20-quote free limit (server-side enforcement)
- [x] Premium unlock ($4.99 one-time via RevenueCat)
- [x] Daily Challenge (8-swipe auto-complete, server-side)
- [x] Philosophy Map (radar chart, weekly snapshot)
- [x] Ambient audio toggle + persistence
- [x] Localization EN/ES (100% UI strings)
- [x] Streak milestones (single-trigger dismissal)
- [x] Admin endpoint (timing-safe comparison — B-02 resolved)
- [x] Trial TOCTOU race fix (atomic conditional UPDATE — B-03 resolved)
- [x] Pack preview fields fix (swipe_dir + is_premium — B-04 resolved)
- [x] Partial indexes migration 007 (feed, vault, challenge, map, audit)
