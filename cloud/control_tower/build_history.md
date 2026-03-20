# Build History — MindScrolling
**Last updated:** 2026-03-18

> Append-only. Never edit existing rows. Add a new row after every build iteration.

---

| Build # | Sprint | Date | Highest QA Level | Score | Label | Release Status | Key Changes |
|---------|--------|------|-----------------|-------|-------|---------------|-------------|
| 1 | Sprint 6 QA Gate | 2026-03-18 | Integration QA | 82 | Stable | NOT READY | All CRIT/HIGH/MED/LOW bugs fixed; 433 author bios loaded; challenge/vault/premium server-side enforcement; map field names fixed; weekly insight lang cache fixed; haptic DOWN fixed; notification toggle persistence fixed; trial fallback fixed; packs explorer rendering fixed |
| 2 | Sprint 7 B-fixes | 2026-03-18 | Integration QA | 86 | Stable ↑ | NOT READY | B-02 resolved (admin timing-safe comparison); B-03 resolved (atomic conditional UPDATE eliminates TOCTOU trial race); B-04 resolved (pack preview includes swipe_dir + is_premium); cloud/ added to ARCHITECTURE.md |
| 3 | Sprint 7 perf+webhook | 2026-03-18 | Integration QA | 91 | Release Ready ✅ | ELIGIBLE | Sentry integrated (app.js + error handler); RevenueCat webhook handler (POST /webhooks/revenuecat, timing-safe, grant/revoke logic, audit log); Migration 007 (8 partial indexes: feed, vault, challenge, map, audit); .env.example updated |
| 4 | Sprint 7 automation | 2026-03-20 | — | 91 | Release Ready ✅ | ELIGIBLE | Control tower dashboard updated; blockers.md expanded (B-05–B-08); automation-rules.md created; CI concurrency controls added (backend-ci, flutter-ci, security-scan, staging-deploy, auto-docs); flutter test --coverage step added; docs/checklist.md created |
| 2026-03-20 09:35:01 | fb8a3c3 | chore(chore): auto-commit 1 file(s) | auto |
| 2026-03-20 09:35:22 | 84341e5 | docs: auto-commit 2 file(s) | auto |
