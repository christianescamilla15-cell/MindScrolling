# Execution — Agent-Based Task Processing

## Purpose
Execute tasks from tasks.md using specialized agents.

## Execution Protocol

For EVERY task in tasks.md:
1. State which AGENT is acting
2. Show: AGENT | TASK | INPUTS | OUTPUTS | VALIDATION | RISKS
3. Execute the work
4. Validate before moving to next task

## Agent Assignments

| Task Type | Primary Agent | Reviewer |
|-----------|--------------|----------|
| Architecture decisions | Architect | Reviewer |
| Code generation | Developer | Reviewer + Test |
| Service extraction | Developer + Architect | Security |
| Tests | Test | Reviewer |
| Security review | Security | Architect |
| Docker/CI/CD | Deployment | Reviewer |
| Infra (Terraform) | Deployment + Architect | Security |
| Documentation | Developer | Reviewer |

## Execution Rules by Mode

### BUGFIX
- Prefer surgical fixes
- No unrelated refactors
- Add regression test before fix if possible
- Validate fix resolves root cause, not just symptom

### FEATURE
- Incremental implementation
- Preserve existing behavior
- Tests for critical paths
- Document API/schema changes

### MIGRATION
- Phased execution (strangler pattern preferred)
- Anti-corruption layers where needed
- Parallel run when possible
- Rollback plan for each phase

### LEGACY_MODERNIZATION
- Stability first, then cleanup
- Tests around fragile areas before refactoring
- Quick wins first, risky refactors last
- Document everything for future team

## Hook Simulation
Since CloudCode doesn't have native hooks, simulate:

```
HOOK SIMULATION
Trigger: [on_save / before_task / after_task / on_commit / before_deploy]
Action: [what would run]
Expected result: [what should pass]
Blocker conditions: [what would block]
```
