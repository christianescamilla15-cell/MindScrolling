# Blind Test Protocol — MindScrolling
**Last updated:** 2026-03-18

---

## Principle

A blind test is performed as a real user. The tester does not reference source code, implementation notes, or QA reports during the test. The only inputs are the running application and the feature's expected behavior.

The goal is to verify that a fix produced an observable improvement, not just that the code changed.

> DO NOT TRUST THE CODE. Trust only what you see.

---

## When to run a blind test

- After every Feature QA cycle
- After any fix for a CRIT or HIGH severity issue
- Before any release candidate is declared
- Whenever a stakeholder or Product Owner requests one

---

## Test Execution Rules

1. Use the running application on a real device or emulator. Do not inspect code, logs, or network traffic during the test (logs may be used only after to diagnose a FAIL).
2. Perform each step exactly as described in `cloud/testing/blind_test_checklist.md`. Do not skip steps.
3. Record the exact observed behavior. Do not infer. If a button has no label, write "button has no label" — do not assume it works.
4. If a step is ambiguous, mark it PENDING and add a note. Do not guess PASS.
5. Each feature area must be tested independently. Do not combine steps across features.

---

## Status Definitions

| Status | Definition |
|--------|-----------|
| PASS | Observed behavior exactly matches expected behavior. No deviation. |
| PARTIAL | Fix is applied and partially working, but full verification requires an external dependency (e.g., RevenueCat webhook, production deployment) that is not available. Document the specific dependency. |
| FAIL | Observed behavior does not match expected behavior. A new bug or regression is present. |
| REGRESSION | A feature that previously had PASS status now FAILs. Must be logged in regression_log.md immediately. |
| PENDING | Step could not be executed (environment not available, device limitation, etc.). Must be resolved before Release QA. |

---

## Evidence Requirements

For every FAIL or REGRESSION result, the tester must collect and save to `cloud/testing/evidence/`:
- A screenshot of the failure state (named `[build]-[feature]-[check-id].png`)
- A written description of reproduction steps (added to debug_log.md)

For PASS results, evidence is optional but encouraged for Release QA.

For PARTIAL results, document the specific dependency that prevented full verification.

---

## Recording Results

Results are recorded in two places:
1. `cloud/testing/blind_test_results.md` — the detailed results table per feature
2. `cloud/control_tower/blind_test_status.md` — the summary table used by the Control Tower dashboard

Both must be updated after every blind test run.

---

## Blocking Rules

| Finding | Action |
|---------|--------|
| Any FAIL | Stop and log in debug_log.md. Assign fix. Do not proceed to Integration QA or Release QA. |
| Any REGRESSION | Stop immediately. Log in regression_log.md AND blockers.md. Escalate to the relevant agent. |
| PARTIAL on Critical-path feature (premium purchase, challenge completion) | Log in blockers.md. Do not proceed to Release QA until resolved or explicitly accepted. |
| PARTIAL on Minor feature | Log in blind_test_status.md with blocker reference. Continue. |
| PENDING after 2 build iterations | Escalate to Product Owner. PENDING items cannot remain indefinitely. |

---

## Feature Areas to Always Test

Every blind test run (not just delta testing) must include these features:

1. Feed — cold start category balance
2. Swipe — all 4 directions with haptic on physical device
3. Vault — free tier limit enforcement
4. Premium — gate blocks non-premium user
5. Daily Challenge — auto-complete at 8 swipes only
6. Philosophy Map — radar chart renders with swipe data
7. Localization — weekly insight language binding

These 7 areas are the core product loop. Any regression in any of these 7 is a release blocker.

---

## Blind Test vs Code Review

These are not the same thing.

| Code Review | Blind Test |
|-------------|-----------|
| Confirms the fix exists in code | Confirms the fix produces a visible result |
| Done by the implementer or peer | Done by the QA Agent as a user |
| Can be done without a running app | Requires the running app |
| Catches logic errors | Catches UX regressions, missing wiring, and silent failures |

Both are required. Neither replaces the other.
