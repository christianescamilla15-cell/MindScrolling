# Sprint Planner — MindScrolling
**Last updated:** 2026-03-18

The Sprint Planner converts the current product state into a focused, actionable sprint. It enforces constraints to prevent scope creep and ensure every sprint delivers measurable progress toward stability or release.

---

## Planning Rules

1. **Maximum 5 tasks per sprint.** More than 5 tasks in a sprint is a sign of poor scope definition. If more than 5 candidates exist, apply the Product Brain model to rank and cut.
2. **Score < 90 → stabilization first.** If the Build Quality Score is below 90, every sprint must contain at least one blocker-resolution task. No purely feature sprints while blockers are open.
3. **No new features if any core feature is Unstable.** Core features are: Feed, Swipe, Vault, Challenge, Map, Premium. If any of these shows FAIL in the blind test status, no new features are added.
4. **Every task must have a measurable acceptance criterion.** "Make it better" is not acceptable. "Vault free limit enforced server-side: POST to /vault with 21st item returns 403" is acceptable.
5. **Every sprint must state its QA level requirement.** A sprint that changes API shape requires Integration QA. A sprint that changes route logic requires Feature QA. A release sprint requires Release QA.

---

## Sprint Structure Template

```
## Sprint [N] — [Sprint Name]
**Goal:** [One sentence describing the primary outcome]
**Type:** [Stabilization / Feature / Release Prep / Content]
**Start date:** YYYY-MM-DD
**End date:** YYYY-MM-DD
**QA level required:** [Micro / Feature / Integration / Release]
**Current score entering sprint:** [N]/100
**Target score exiting sprint:** [N]/100

---

### Tasks

#### Task 1: [Short task name]
**ID:** S[N]-[01]
**Owner:** [Agent name]
**Effort:** [Low / Medium / High]
**Acceptance Criteria:**
- [ ] [Specific, testable condition]
- [ ] [Another condition]
**Blind test target:** [What a tester should observe after this fix]
**Blockers this resolves:** [B-0N or N/A]

[Repeat for each task, up to 5]

---

### Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| [Risk description] | [Low/Med/High] | [Low/Med/High] | [How to mitigate] |

---

### Expected outcome

- Score after sprint: [N]/100 (if all tasks complete)
- QA level after sprint: [Micro / Feature / Integration / Release]
- Release status after sprint: [NOT READY / BLOCKED / READY]
- Key improvement: [What is better for users after this sprint]
```

---

## Current Sprint — Sprint 7 (Google Play Launch Hardening)

**Goal:** Resolve B-01..B-03 blockers and complete Release QA to reach score >= 90 and ship to Google Play.
**Type:** Stabilization + Release Prep
**Start date:** 2026-03-18
**End date:** 2026-04-01
**QA level required:** Release QA
**Current score entering sprint:** 82/100
**Target score exiting sprint:** 91/100

### Recommended Sprint 7 Tasks (top 5)

| Priority | Task | Owner | Effort | Resolves |
|----------|------|-------|--------|---------|
| 1 | Resolve B-01: RevenueCat webhook + server-side premium grant | DevOps + Backend Implementer | High | B-01 Critical |
| 2 | Deploy backend to Railway production (S7-04) | DevOps | Medium | Release QA unblocked |
| 3 | Resolve B-02: Redis rate-limit + crypto.timingSafeEqual for admin endpoints | Backend Implementer | Medium | B-02 Major |
| 4 | Resolve B-03: UNIQUE constraint or advisory lock on trial start | Backend Implementer | Low | B-03 Major |
| 5 | Crash-free baseline on 3 physical Android devices (S7-09) + Release QA | Flutter Mobile Engineer + QA Agent | Medium | Score +2, Release QA |

### Sprint 7 Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| RevenueCat webhook integration takes longer than estimated | Medium | High | Start B-01 first; all other tasks can proceed in parallel |
| Railway deployment exposes previously unseen production bugs | Low | High | Run Micro QA immediately after deployment; have rollback plan |
| Physical device testing reveals Android-specific crash | Medium | High | Test on minimum 3 devices (different Android versions) before Release QA |

### Expected sprint 7 outcome

- Score after sprint: 91/100 (B-01..B-04 resolved, crash baseline collected, Release QA complete)
- QA level after sprint: Release QA — PASS
- Release status after sprint: READY (pending Google Play submission approval)
- Key improvement: MindScrolling premium revenue is real and verifiable; app is safe to list on Play Store

---

## Backlog Prioritization Quick Reference

When planning the next sprint, consult these sources in order:

1. `cloud/control_tower/blockers.md` — open blockers always come first
2. `cloud/control_tower/build_status.md` — "Path to 90+" section lists the highest-value fixes
3. `BACKLOG.md` — Sprint 7 P0 items are launch blockers; P1 items are post-launch
4. `cloud/workflows/product_brain.md` — apply the scoring model if priorities are unclear
