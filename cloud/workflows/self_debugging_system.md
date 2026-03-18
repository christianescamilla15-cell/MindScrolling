# Self-Debugging System — MindScrolling
**Last updated:** 2026-03-18

This document defines the self-debugging loop: how bugs are detected, classified, assigned, fixed, and verified. The loop integrates with the Control Tower so that every resolved bug is reflected in the score, dashboard, and QA history.

---

## Trigger Conditions

The self-debugging loop activates when any of the following occur:

1. Micro QA fails (app crash, /health down, feed empty)
2. Feature QA fails (a check produces an unexpected result)
3. A blind test returns FAIL or REGRESSION
4. A user-visible error is reported post-launch
5. A blocker in blockers.md is assigned and moved to "In Progress"
6. An agent identifies a bug during implementation work

---

## The Self-Debugging Loop

```
DETECT
  ↓
  Confirm the bug is reproducible (not a fluke).
  Record in debug_log.md: description, severity, reproduction steps.
  ↓
CLASSIFY
  ↓
  Critical:  Blocks app from launching, or compromises revenue/security.
  High:      Feature completely broken or data incorrect.
  Medium:    Feature works but with wrong behavior in a subset of cases.
  Low:       Visual/UX defect, minor text error, non-revenue impacting.
  Blocker:   External dependency required (DevOps, RevenueCat, DB migration).
  ↓
ASSIGN
  ↓
  (see assignment table below)
  ↓
FIX (max 3 attempts)
  ↓
  Attempt 1: Fix the most likely root cause.
  If Micro QA still fails after attempt 1 → Attempt 2.
  If Micro QA still fails after attempt 2 → Attempt 3 (deeper root cause analysis required).
  If 3 attempts all fail → escalate to Product Owner + API Architect for architectural review.
  ↓
MICRO QA
  ↓
  Run Micro QA checklist. If FAIL → return to FIX.
  ↓
FEATURE QA (scoped to fixed feature + adjacent features)
  ↓
  Run Feature QA checks for the fixed area. If FAIL → return to FIX.
  ↓
BLIND TEST (feature-level)
  ↓
  Run blind test for the fixed feature. If FAIL → return to FIX.
  ↓
RECALCULATE SCORE
  ↓
  Update build_status.md with new score.
  Update score_history.md (new row if score changed).
  ↓
UPDATE CONTROL TOWER
  ↓
  - Move issue from debug_log.md to fix_history.md.
  - Remove from active_issues.md.
  - Update blockers.md if issue was a blocker.
  - Refresh dashboard.md.
  - Add row to build_history.md.
  - Update release_status.md if readiness changed.
```

---

## Retry Rules

| Attempt | Approach |
|---------|---------|
| Attempt 1 | Fix the most likely root cause identified during classification. Run Micro QA. |
| Attempt 2 | If Micro QA still fails: analyze error logs, check adjacent code for side effects. Apply a different fix strategy. |
| Attempt 3 | If still failing: conduct a deeper root cause analysis. Review the last 3 commits that touched the affected file. Consider whether the architecture itself is the problem. |
| After 3 failures | Escalate to Product Owner + API Architect. Do not attempt a 4th fix without an architectural review session. Document all 3 attempts in debug_log.md. |

A "fix attempt" is defined as: a code change followed by a full Micro QA run. Partial changes that are not yet testable do not count as attempts.

---

## Assignment Table

| Bug Type | Assigned Agent | Escalation if stuck |
|----------|---------------|-------------------|
| Flutter UI regression (layout, animation, widget) | Flutter Mobile Engineer | API Architect |
| Flutter state management (Riverpod provider, cache) | Flutter Mobile Engineer | API Architect |
| Flutter navigation (GoRouter) | Flutter Mobile Engineer | API Architect |
| Flutter-backend mismatch (model binding, field names) | Flutter Mobile Engineer + Backend Implementer jointly | API Architect |
| Backend route handler logic | Backend Implementer | API Architect |
| Backend DB query (Supabase, SQL) | Backend Implementer | API Architect |
| Backend authentication / device ID logic | Backend Implementer | API Architect |
| Feed algorithm scoring | Recommendation Engineer | API Architect |
| Database schema / migration | API Architect | Product Owner |
| External service integration (RevenueCat, Railway) | DevOps | Product Owner |
| Content / data issues (wrong quotes, missing bios) | Data Engineer | Product Owner |
| Documentation mismatch | Documentation Writer | — |

---

## Integration with Control Tower

Every resolved bug triggers these Control Tower updates:

| Update | File |
|--------|------|
| Move bug from active to resolved | debug_log.md → fix_history.md |
| Remove from active issues | active_issues.md |
| Update blocker status | blockers.md |
| Recalculate and record score | build_status.md, score_history.md |
| New build row | build_history.md |
| Refresh QA status | qa_status.md, qa_history.md |
| Refresh dashboard | dashboard.md |
| Update release readiness | release_status.md |

No fix is considered complete until all Control Tower files are updated. A fix that is not reflected in the Control Tower does not exist from the product's perspective.

---

## Special Case: Architectural Blockers (B-01..B-04)

Blockers that require external services or architectural changes follow a modified loop:

1. Blocker is logged in blockers.md and active_issues.md at discovery.
2. Owner is assigned (DevOps or Backend Implementer).
3. Blocker status moves to "In Progress" when work begins.
4. When the external service is integrated or the architectural change is made:
   - Run the full loop from MICRO QA forward.
   - The blocker is only "Resolved" after Micro QA, Feature QA, and Blind Test all PASS for the affected feature.
5. Update score after resolution (deducted points are restored).

B-01 (receipt validation) additionally requires a RevenueCat sandbox test before it can be marked Resolved. A code-level fix alone is not sufficient.
