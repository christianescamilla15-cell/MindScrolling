# Automation Rules — MindScrolling Control Tower
**Last updated:** 2026-03-18

These rules define the mandatory protocol every agent must follow after any code change, QA run, or sprint event. Deviating from these rules produces an unreliable Control Tower and invalidates the release readiness signal.

---

## The Automation Loop

After every iteration (any code change, however small):

```
1. Run Micro QA
      ↓ (if FAIL → STOP. Log to debug_log.md. Assign fix. Do not proceed.)
2. Run Feature QA (scope: changed features only, plus regression check on adjacent features)
      ↓ (if any FAIL → STOP. Log regression in regression_log.md. Do not proceed.)
3. Run Blind Test (for all affected feature areas)
      ↓ (record results in blind_test_status.md)
4. Calculate new Build Quality Score
      ↓ (update build_status.md)
5. Update Control Tower files:
      - build_history.md (new row)
      - score_history.md (new row if score changed)
      - qa_status.md (current status)
      - qa_history.md (new build block)
      - dashboard.md (refreshed summary)
      - regression_log.md (new entries if regressions found)
      - blockers.md (update status of any resolved/new blockers)
      - release_status.md (update if readiness changed)
```

If a step fails, the loop stops at that step. The next iteration cannot begin until the failure is resolved and the loop can restart from step 1.

---

## Fail Conditions

| Condition | Response | Who acts |
|-----------|----------|----------|
| Micro QA FAIL | STOP all work. Log to debug_log.md. Assign fix immediately. | QA Agent assigns; relevant implementer fixes |
| Feature QA FAIL (new regression) | STOP. Log to regression_log.md AND blockers.md. Do not merge. | QA Agent logs; implementer fixes |
| Feature QA FAIL (known blocker) | Document in blockers.md. Do not STOP the loop if it is an existing known blocker. Continue with PARTIAL status. | Documentation Writer documents; Product Owner accepts risk |
| Blind Test FAIL (not a known blocker) | Treat as a regression. Same as Feature QA FAIL. | QA Agent |
| Blind Test PARTIAL | Log in blind_test_status.md. Note blocker ID. Continue loop. | Documentation Writer |
| Score drops from previous build | Log delta in score_history.md with explanation. Investigate if drop > 3 points. | QA Agent investigates |
| New blocker discovered mid-iteration | Add to blockers.md immediately. Update dashboard.md. | Agent who found it |

---

## QA Level Trigger Rules

| QA Level | Triggered when |
|----------|---------------|
| Micro QA | Every iteration without exception |
| Feature QA | Any change to feature logic, routes, models, or UI |
| Integration QA | Any change to API shape, response field names, or model structure |
| Release QA | Only when: score >= 90, zero Critical blockers, all Major blockers resolved or accepted, production backend deployed |

---

## Score Calculation Rules

The Build Quality Score is calculated from 7 categories. Each category is scored independently. The sum is the total.

| Category | Max |
|----------|-----|
| Build Integrity | 20 |
| Core Product | 20 |
| Localization | 15 |
| Premium / Free | 15 |
| Data / Backend | 10 |
| Performance | 10 |
| Docs Alignment | 10 |
| **Total** | **100** |

Score rules:
- Never round up. If a category earns 7.5, record 7.
- Deductions are applied for open blockers in the category's scope.
- A resolved blocker restores its deduction in the next build.
- Performance score cannot exceed 7 without crash-free baseline data.
- Docs Alignment cannot exceed 8 without all swipe direction tables in sync across README, ARCHITECTURE, and API_CONTRACT.

---

## Release Rule

A release is approved ONLY when all of the following are simultaneously true:

1. Build Quality Score >= 90/100
2. Zero Critical open blockers
3. Zero Major open blockers (OR all documented as accepted risk with written Product Owner sign-off)
4. Release QA: PASS (all checks completed on production environment with real devices)
5. No regressions in regression_log.md without a documented resolution
6. release_status.md shows READY
7. dashboard.md has been refreshed within 24 hours of the release decision

This rule cannot be overridden by any single agent. It requires documentation of score + QA result + blocker status from QA Agent and Documentation Writer.

---

## Dashboard Refresh Rule

dashboard.md must be refreshed:
- After every build iteration
- After any blocker status changes
- After any QA level changes
- Before any release decision

A dashboard that is more than 48 hours old without an update is considered stale. Stale dashboards are not valid inputs to release decisions.
