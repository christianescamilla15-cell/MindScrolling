# Feature Implementation Workflow

## Purpose

This document defines the exact execution sequence for implementing new features in MindScrolling. Every feature request must follow this pipeline. No implementation begins without scope definition. No feature closes without QA validation.

---

## Agents Involved

| Order | Agent | Role |
|-------|-------|------|
| 1 | Product Owner | Define scope |
| 2 | Scrum Coordinator | Break into tasks |
| 3 | API Architect | Define contracts |
| 4 | Domain Specialists | Implement |
| 5 | QA Reviewer (First Pass) | Structural review |
| 6 | Performance Engineer | Performance impact (if applicable) |
| 7 | Documentation Writer | Update docs |
| 8 | DevOps Engineer | Env/deploy impact |
| 9 | QA Reviewer (Final Pass) | Integration validation |
| 10 | Agent Orchestrator | Close or re-route |

---

## Execution Sequence

### STEP 1 — Product Owner

**Trigger:** New feature request received.

**Responsibilities:**
- Define feature objective
- Define included functionality
- Define excluded functionality (out of scope)
- Define expected user impact

**Required Output:**
```
Feature: <name>
Objective: <what it achieves>
Included: <what is in scope>
Excluded: <what is NOT in scope>
User Impact: <how the user experience changes>
```

**Gate:** Feature scope must be approved before proceeding.

---

### STEP 2 — Scrum Coordinator

**Trigger:** Product Owner scope approved.

**Responsibilities:**
- Break feature into discrete tasks
- Define execution order
- Identify dependencies between tasks
- Assign tasks to correct agents

**Required Output:**
```
Tasks:
  1. <task> → <assigned agent> [depends on: none]
  2. <task> → <assigned agent> [depends on: task 1]
  3. ...

Estimated complexity: low | medium | high
```

**Gate:** Task plan must be reviewed before implementation starts.

---

### STEP 3 — API Architect

**Trigger:** Task plan approved.

**Responsibilities:**
- Determine backend contract changes (new/modified endpoints)
- Determine DB schema changes (new tables, columns, indexes)
- Define API endpoint signatures and payload structures
- Update API_CONTRACT.md if contracts change

**Required Output:**
```
Contract Changes:
  Endpoints: <list of new/modified endpoints>
  DB Schema: <migrations needed>
  Payload: <request/response shapes>
  Breaking Changes: yes/no

Files to update: API_CONTRACT.md, ARCHITECTURE.md (if applicable)
```

**CRITICAL RULE:** Implementation must NOT start before this step completes when APIs are involved.

**Skip condition:** If the feature is purely UI (no new endpoints, no DB changes, no contract modifications), Step 3 outputs "No contract changes needed" and implementation proceeds directly to Step 4.

---

### STEP 4 — Domain Specialists

**Trigger:** API contracts defined (or confirmed no contract changes needed).

**Assignment rules:**

| Domain | Agent |
|--------|-------|
| Backend routes, services, DB logic | Backend Implementer |
| Flutter screens, widgets, state | Flutter Mobile Engineer |
| Feed scoring, embeddings, AI logic | Recommendation Engineer |
| Quote dataset, quality pipeline, translations | Data Content Engineer |

**Execution rules:**
- Backend must be implemented BEFORE Flutter when APIs are involved
- Recommendation logic changes MUST go through Recommendation Engineer
- Dataset/content changes MUST go through Data Content Engineer
- Each specialist produces a handoff report on completion (see template)

**Required Output:** Handoff report per agent (see `templates/handoff_template.md`).

---

### STEP 5 — QA Reviewer (First Pass)

**Trigger:** All domain specialists complete their handoff reports.

**Responsibilities:**
- Verify architectural consistency
- Check code boundaries (no agent overwriting another's domain)
- Detect obvious bugs
- Verify API contract matches between backend and Flutter
- Check localization coverage (EN + ES)
- Check premium gating correctness

**Required Output:**
```
Review: PASS | FAIL
Issues Found:
  - <issue 1> → <assigned agent>
  - <issue 2> → <assigned agent>
Blocking: yes/no
```

**Gate:** If FAIL with blocking issues, route back to responsible agent before proceeding.

---

### STEP 6 — Performance Engineer (if applicable)

**Trigger:** First pass review completed.

**Responsibilities:**
- Review performance impact of the new feature
- Check for unnecessary widget rebuilds, heavy queries, large payloads
- Flag any performance regression risk

**Skip condition:** If the feature has no performance-sensitive component (no new queries, no new rendering, no new assets), this step is skipped.

**Required Output:**
```
Performance Impact: NONE | LOW | MEDIUM | HIGH
Concerns: none | <list>
Recommendations: none | <list>
```

---

### STEP 7 — Documentation Writer

**Trigger:** First pass review completed (PASS or non-blocking issues only).

**Responsibilities:**
- Update relevant documentation files
- Ensure docs reflect the new feature

**Files that may need updates:**
- README.md
- ARCHITECTURE.md
- API_CONTRACT.md
- SCRUM.md
- ROADMAP.md
- FEED_ALGORITHM.md
- DATASET_PIPELINE.md

---

### STEP 8 — DevOps Engineer

**Trigger:** Documentation updated (or confirmed no doc changes needed).

**Responsibilities (if applicable):**
- Create/run database migrations
- Update environment variables
- Adjust runtime configuration
- Update CI/CD pipeline if needed

**Skip condition:** If feature has zero infrastructure impact, this step is skipped.

---

### STEP 9 — QA Reviewer (Final Validation)

**Trigger:** All implementation, docs, and infra work complete.

**Responsibilities:**
- Validate full integration end-to-end
- Confirm no broken existing features
- Confirm no API contract mismatches
- Confirm no major regressions
- Confirm feature behaves as defined in scope

**Required Output:**
```
Final Review: PASS | FAIL
Test Results:
  - <test area>: pass/fail
Regressions Detected: none | <list>
Approval: APPROVED | REJECTED (reason)
```

**Gate:** Feature cannot close without APPROVED status.

---

### STEP 10 — Agent Orchestrator

**Trigger:** Final review APPROVED.

**Responsibilities:**
- Confirm all handoff reports received
- Confirm all review gates passed
- Mark feature as COMPLETE in SCRUM.md
- Or re-route unresolved issues to the correct agent

**Required Output:**
```
Feature: <name>
Status: COMPLETE | REOPENED
Agents involved: <list>
Issues remaining: none | <list with assignments>
```

---

## Rules Summary

1. No implementation without scope definition (Step 1)
2. No implementation without API contracts (Step 3) when APIs are involved
3. Backend before Flutter when APIs are involved
4. Every specialist produces a handoff report
5. Performance-sensitive features must pass Performance Engineer review (Step 6)
6. No feature closes without QA validation (Step 9)
7. Architecture-impacting changes must update documentation
8. Agent Orchestrator has final authority to close or re-route
