# Active Issues — MindScrolling
**Last updated:** 2026-03-18 (Build #2)

> This file shows only currently open issues. When an issue is resolved, move it to fix_history.md and remove it from here.

---

## Summary

| Severity | Count |
|----------|-------|
| Critical | 1 (B-01) |
| Major | 0 |
| Minor | 0 |
| **Total** | **1** |

---

## Active Issue Table

| ID | Description | Severity | Assigned Agent | Attempts | Status |
|----|-------------|----------|---------------|----------|--------|
| B-01 | Real App Store / Google Play receipt validation missing. Backend grants premium based on client-reported RevenueCat data without server-side webhook verification. Revenue from purchases cannot be confirmed without this. | Critical | DevOps | 0 | Open — awaiting RevenueCat project setup + Railway webhook endpoint |

---

## Resolved This Session (Build #2)

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
