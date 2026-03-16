# Bug Triage Workflow

## Purpose

This document defines how bugs are reported, classified, assigned, fixed, and validated in MindScrolling. Every bug follows this pipeline. No bug is closed without QA validation.

---

## Severity Levels

| Level | Definition | Response Time |
|-------|-----------|---------------|
| **Critical** | App crashes, data loss, security vulnerability, feed completely broken | Immediate — blocks all other work |
| **Major** | Feature broken but app functional, wrong data displayed, navigation failure | Same sprint — high priority |
| **Minor** | Visual glitch, non-blocking UX issue, edge case behavior | Next sprint — normal priority |
| **Suggestion** | Improvement idea, not a defect | Backlog — prioritize later |

---

## Bug Routing Table

| Bug Domain | Owner Agent | Examples |
|-----------|-------------|----------|
| Backend routes, services, DB | Backend Implementer | 500 errors, wrong API response, DB query failures |
| Flutter UI, navigation, state | Flutter Mobile Engineer | Black screen, broken navigation, widget errors |
| Feed scoring, recommendations | Recommendation Engineer | Wrong quote ordering, broken diversity, stale feed |
| Quote dataset, translations | Data Content Engineer | Missing quotes, bad translations, wrong categories |
| Environment, deploy, config | DevOps Engineer | Wrong env vars, migration failures, SSL issues |
| Performance (slow feed, jank, memory) | Performance Engineer | Slow feed load, UI jank, memory leaks, large payloads |
| Ambient audio | Flutter Mobile Engineer + Performance Engineer | Audio not playing, audio crash, battery drain from audio |
| Cross-system integration | API Architect + relevant implementers | Contract mismatch between backend and Flutter |

---

## Execution Sequence

### STEP 1 — Bug Intake

**Trigger:** Bug detected (user report, testing, or agent discovery).

**Required Information:**
```
Bug Report:
  Title: <short description>
  Severity: Critical | Major | Minor | Suggestion
  Domain: backend | frontend | feed | dataset | integration | config
  Steps to Reproduce:
    1. <step>
    2. <step>
  Expected Behavior: <what should happen>
  Actual Behavior: <what happens instead>
  Screenshots/Logs: <if available>
  Device/Environment: <phone model, OS, backend URL>
```

---

### STEP 2 — QA Reviewer Classification

**Trigger:** Bug report received.

**Responsibilities:**
- Verify the bug is reproducible
- Classify bug domain (backend, frontend, feed, dataset, integration, config)
- Assign severity level
- Identify affected files/modules if possible

**Required Output:**
```
Classification:
  Domain: <domain>
  Severity: <level>
  Affected Area: <files or modules>
  Reproducible: yes/no
  Recommended Owner: <agent name>
```

---

### STEP 3 — Agent Orchestrator Assignment

**Trigger:** QA Reviewer classification complete.

**Responsibilities:**
- Assign bug to the correct owner agent based on domain
- If cross-system, assign primary owner and supporting agents
- Set priority based on severity

**Required Output:**
```
Assignment:
  Primary Owner: <agent>
  Supporting Agents: <if any>
  Priority: <based on severity>
  Deadline: <if critical>
```

---

### STEP 4 — Responsible Agent Fix

**Trigger:** Assignment received.

**Responsibilities:**
- Investigate root cause
- Implement fix
- Verify fix does not introduce regressions
- Produce handoff report

**Required Output:** Handoff report (see `templates/handoff_template.md`)

**Rules:**
- Fix must be scoped to the bug — no unrelated refactoring
- If fix requires changes in another agent's domain, request collaboration through Agent Orchestrator
- If root cause is in a different domain than initially classified, report back to Agent Orchestrator for reassignment

---

### STEP 5 — QA Reviewer Validation

**Trigger:** Fix handoff report received.

**Responsibilities:**
- Verify the bug is resolved
- Verify no regressions introduced
- Test the specific reproduction steps from the original report

**Required Output:**
```
Validation:
  Bug Fixed: yes/no
  Regression Check: pass/fail
  Notes: <any observations>
  Status: RESOLVED | REOPEN (reason)
```

---

### STEP 6 — Agent Orchestrator Close/Reopen

**Trigger:** QA validation complete.

**If RESOLVED:**
- Mark bug as closed
- Log resolution in sprint notes

**If REOPEN:**
- Route back to responsible agent with QA feedback
- Repeat Steps 4-5

**Required Output:**
```
Bug: <title>
Status: CLOSED | REOPENED
Resolution: <summary of fix>
Agents Involved: <list>
```

---

## Escalation Rules

1. **Critical bugs** bypass normal sprint flow — immediate attention required
2. If a bug is reopened **more than twice**, Agent Orchestrator must escalate to API Architect for architectural review
3. If a bug spans **multiple domains**, Agent Orchestrator coordinates a joint fix with all affected agents
4. If a fix **breaks another feature**, severity is automatically elevated to Critical

---

## Prevention Checklist

After every bug fix, the responsible agent should verify:

- [ ] Root cause identified and documented
- [ ] Fix is minimal and scoped to the bug
- [ ] No changes to other agents' domain without coordination
- [ ] Localization not broken (EN + ES)
- [ ] Premium gating not affected
- [ ] Navigation still works correctly
- [ ] Feed still loads and displays properly
