# Spec Generator — Structure by Mode

## Purpose
Generate the correct spec files based on the detected mode.

## Spec Files by Mode

### BUGFIX
```
/specs/bugfix-{slug}/
  bugfix.md          — problem, symptoms, root cause, acceptance criteria
  design.md          — fix strategy, root cause analysis
  tasks.md           — surgical tasks with validation
  validation.md      — test checklist, regression checks
  rollback.md        — rollback conditions and steps
  risks.md           — known risks and mitigations
```

### FEATURE
```
/specs/feature-{slug}/
  requirements.md    — objective, user impact, acceptance criteria
  design.md          — proposed design, architecture impact
  tasks.md           — incremental implementation tasks
  validation.md      — test matrix, release gate
  rollout.md         — deployment plan, post-deploy checks
  risks.md           — risks and open questions
```

### MIGRATION
```
/specs/migration-{slug}/
  requirements.md    — migration objectives, constraints
  design.md          — current state, target state, strategy
  tasks.md           — phased migration tasks
  validation.md      — compatibility checks, test matrix
  rollout.md         — staged rollout plan
  rollback.md        — rollback conditions and recovery
  risks.md           — migration risks
```

### LEGACY_MODERNIZATION
```
/specs/legacy-{slug}/
  requirements.md    — stabilization objectives
  design.md          — pain points, modernization strategy
  tasks.md           — incremental refactor tasks
  modernization-roadmap.md — quick wins, medium-term, high-risk
  validation.md      — stability checks
  rollback.md        — safety net
  risks.md           — fragility risks
```

## Automation
`python scripts/new_task.py --task "description"` creates all of this automatically.
