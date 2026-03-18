# Control Tower — MindScrolling
**Last updated:** 2026-03-18

The Control Tower is the single source of truth for the health, readiness, and release status of the MindScrolling product. It is updated after every build iteration, QA cycle, and sprint close.

---

## What each file means

### dashboard.md
The executive summary. One page. Shows the current Build Quality Score, QA pipeline status, blind test summary, open issues, core feature health, and release readiness. This is the first file any agent or stakeholder should read to understand the current state of the product. Updated after every build iteration.

### build_status.md
The detailed score breakdown for the current build. Score is broken into 7 categories with max points per category. Includes narrative on what earned points, what lost points, and what is needed to improve. Updated by the QA Agent after each build.

### qa_status.md
Current status of each QA level (Micro / Feature / Integration / Release). Shows what was tested, what passed, what is pending. Updated by the QA Agent. A QA level is never marked PASS until all checks in that level are complete.

### blind_test_status.md
Per-feature blind test results. Each row is a feature area with expected behavior, observed behavior, and PASS/PARTIAL/FAIL status. Updated by the QA Agent or Documentation Writer after each blind test run.

### blockers.md
All open issues that must be resolved before the next milestone or release. Includes severity, owner, impacted feature, and the specific unblock condition. Updated by the API Architect, Backend Implementer, or DevOps as issues are opened or closed.

### release_status.md
Binary go/no-go for the current build. States exactly why the build is NOT READY or READY. Lists required fixes remaining. Updated by the QA Agent or Documentation Writer.

### build_history.md
One row per build iteration. Tracks build number, sprint, date, highest QA level reached, score, label, and release status. Append-only — never edit existing rows. Updated after every build.

### score_history.md
Score evolution table. One row per build. Shows score delta from previous build. Append-only. Updated after every build alongside build_history.md.

### qa_history.md
QA level results per build. Each build has a sub-table showing Micro/Feature/Integration/Release results and dates. Append-only. Updated after every QA cycle.

### regression_log.md
Any regression introduced in a given build. If a feature that previously passed now fails, it is logged here with the build that introduced it and the owner assigned to fix it. Never edited retroactively — new entries only.

### automation_rules.md
The rules that govern how all control tower files are updated. Defines the automation loop, fail conditions, and the release rule. This file should not need frequent updates — it is the protocol definition.

### templates/status_template.md
A blank template that agents fill in to create a new build status entry. Used as the starting point for each new build in build_status.md.

---

## When to update each file

| Event | Files to Update |
|-------|----------------|
| After every code change / iteration | build_status.md, build_history.md, score_history.md |
| After every QA run | qa_status.md, qa_history.md, blind_test_status.md |
| After every sprint close | dashboard.md, release_status.md, all above |
| When a blocker is opened or resolved | blockers.md, release_status.md, dashboard.md |
| When a regression is detected | regression_log.md, blockers.md, dashboard.md |

---

## Which agent owns each file

| File | Primary Owner | Reviewer |
|------|--------------|----------|
| dashboard.md | Documentation Writer | QA Agent |
| build_status.md | QA Agent | Documentation Writer |
| qa_status.md | QA Agent | Documentation Writer |
| blind_test_status.md | QA Agent | Documentation Writer |
| blockers.md | API Architect / Backend Implementer | QA Agent |
| release_status.md | Documentation Writer | QA Agent |
| build_history.md | Documentation Writer | — |
| score_history.md | Documentation Writer | — |
| qa_history.md | QA Agent | Documentation Writer |
| regression_log.md | QA Agent | All Agents |
| automation_rules.md | Documentation Writer | All Agents |
| templates/status_template.md | Documentation Writer | — |

---

## How to use Control Tower per workflow phase

### Per iteration (after any code change)
1. QA Agent runs Micro QA → Feature QA as applicable
2. QA Agent updates qa_status.md and blind_test_status.md
3. QA Agent calculates new score → updates build_status.md
4. Documentation Writer updates build_history.md, score_history.md, dashboard.md
5. If regressions detected: log in regression_log.md, add to blockers.md

### Per stabilization sprint
1. All of the above, plus:
2. Integration QA run → update qa_status.md with Integration result
3. Backend Implementer resolves any PARTIAL/FAIL blockers
4. blockers.md updated with resolution
5. release_status.md updated
6. dashboard.md refreshed to reflect new score and readiness

### Per release
1. All blockers at Critical/Major severity must be resolved or explicitly accepted
2. Score must be >= 90/100
3. Release QA must be PASS
4. release_status.md must show READY
5. Documentation Writer publishes final dashboard.md snapshot
6. Documentation Writer tags build in build_history.md as released
