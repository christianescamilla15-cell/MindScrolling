# Agent Handoff Report

## Instructions

Every agent must produce this report when completing a task. This ensures the next agent in the pipeline has full context to continue safely.

---

## Template

```
Agent: <agent name>
Task: <task description>
Sprint: <sprint number or N/A>

Files Modified:
  - <file path 1>: <what changed>
  - <file path 2>: <what changed>

Files Created:
  - <file path>: <purpose>

What Was Implemented:
  <clear description of what was done>

Assumptions Made:
  - <assumption 1>
  - <assumption 2>

Risks:
  - <risk 1>
  - <risk 2>
  - none (if no risks identified)

What Needs Validation:
  - <item 1>
  - <item 2>

Breaking Changes:
  - <contract change, schema change, or behavioral change>
  - none (if no breaking changes)

Dependencies Introduced:
  - <new package, service, or external dependency>
  - none (if no new dependencies)

Tests Run:
  - <test description>: pass/fail
  - <manual verification>: pass/fail
  - none (if no tests applicable — explain why)

Next Recommended Owner: <agent name or "QA Reviewer">
```

---

## Rules

1. Every modified file must be listed — no silent changes
2. Assumptions must be explicit so reviewers can verify them
3. Risks must be honest — hiding risks causes bugs downstream
4. "What Needs Validation" guides the QA Reviewer on what to test
5. If the task is incomplete, state what remains and why
