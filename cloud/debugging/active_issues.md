# Active Issues — MindScrolling
**Last updated:** 2026-03-20 (Build #4)

> This file shows only currently open issues. When an issue is resolved, move it to fix_history.md and remove it from here.

---

## Summary

| Severity | Count |
|----------|-------|
| Critical | 3 (B-01, B-05, B-06) |
| High | 1 (B-08) |
| Medium | 1 (B-07) |
| **Total** | **5** |

---

## Active Issue Table

| ID | Description | Severity | Assigned Agent | Attempts | Status |
|----|-------------|----------|---------------|----------|--------|
| B-01 | Real App Store / Google Play receipt validation missing. Backend grants premium based on client-reported RevenueCat data without server-side webhook verification. Revenue from purchases cannot be confirmed without this. | Critical | devops-engineer | 0 | Open — awaiting RevenueCat project setup + Railway webhook endpoint |
| B-05 | pgvector extension not enabled in Supabase. `004_ai_feed.sql` cannot run without it. AI feed entirely non-functional. | Critical | devops-engineer | 0 | Open — enable via Supabase Dashboard → Extensions → vector |
| B-06 | 004_ai_feed.sql migration not executed. `match_quotes` RPC, HNSW index, and `embedding` column do not exist. Depends on B-05. | Critical | devops-engineer | 0 | Open — blocked by B-05 |
| B-07 | embed-quotes batch not run. All quote embeddings are NULL. AI feed cannot rank by vector similarity. Depends on B-06. | Medium | devops-engineer | 0 | Open — blocked by B-06 |
| B-08 | Google Play Store production API access not available. Fewer than 12 testers have accepted the closed beta opt-in link. | High | growth-aso-strategist | 0 | Open — recruit 12 testers via opt-in link |

---

## Resolved This Session (Build #4 — 2026-03-20)

| ID | Description | Fix Applied |
|----|-------------|-------------|
| — | No new resolutions this session. B-05, B-06, B-07, B-08 added as new open issues. | — |

---

## Resolved in Prior Sessions (Build #2)

| ID | Description | Fix Applied |
|----|-------------|-------------|
| B-02 | Admin token compared with `===` (timing attack) | `crypto.timingSafeEqual(providedBuf, expectedBuf)` in `admin.js:requireAdmin()` |
| B-03 | TOCTOU race in `POST /premium/start-trial` | Replaced SELECT-then-UPDATE with a single atomic `.is("trial_start_date", null)` conditional UPDATE |
| B-04 | Pack preview missing `swipe_dir` and `is_premium` fields | Added both to `.select()` in `packs.js:/:id/preview` |

---

## Notes

- B-01 is owned by DevOps because it requires integrating RevenueCat (external service) and configuring a production webhook endpoint on Railway. The Backend Implementer writes the handler once the RevenueCat project is set up.
- No application logic bugs are active. All CRIT/HIGH/MED/LOW issues from Sprint 6 are resolved.
- All Major and Minor architectural blockers from Sprint 6 (B-02, B-03, B-04) are now resolved.
