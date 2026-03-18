---
name: MindScrolling - Security context
description: Implemented security measures and known pending items as of Sprint 7 (2026-03-18)
type: project
---

## Implemented Security Measures (as of 2026-03-18)

- `@fastify/helmet` — HTTP security headers
- Logger redact: `authorization`, `x-device-id`, `cookie` fields stripped from logs
- Supabase key rotation: legacy JWT disabled, new `sb_publishable_*` / `sb_secret_*` in Railway
- RLS enabled on all tables (verified)
- `ADMIN_SECRET` header required on all `/admin/*` endpoints
- `@fastify/rate-limit` active on write endpoints
- TruffleHog + Gitleaks in `.github/workflows/security-scan.yml` (scheduled weekly)
- Dependabot configured for npm + GH Actions (`.github/dependabot.yml`)
- `SECURITY.md` published with vulnerability disclosure policy
- `.gitleaks.toml` present in repo root

## Known Pending Items

- Fastify v4→v5 upgrade pending (known DoS vulnerability, Dependabot will flag)
- RevenueCat / IAP receipt validation: currently stub (SnackBar "Próximamente") — server-side validation not yet implemented (pre-launch gate)
- Certificate pinning: not implemented in Flutter (flag before production)
- DEV_FORCE_PREMIUM=true must be removed from Railway env before Play Store launch

## Architecture Security Notes

- Auth model: X-Device-ID UUID header (anonymous, no email/password)
- Service role key: Fastify backend only, never in Flutter app
- Pack entitlement: server-enforced only — client cannot be trusted for access decisions
- Grandfathering cutoff (2026-06-01): enforced in `backend/src/services/packEntitlement.js`
- Source tracking on swipes: 'preview' swipes do NOT update preference weights (enforced server-side)

**Why:** Security sprint completed 2026-03-18. Most critical hardening done. Remaining gaps are pre-launch gates.
**How to apply:** Focus audits on new endpoints/routes added each sprint, and flag any IAP/receipt validation gaps before Play Store submission.
