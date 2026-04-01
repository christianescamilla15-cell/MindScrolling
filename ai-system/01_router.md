# Router — Task Mode Detection

## Purpose
Detect the correct execution mode for any incoming task.

## Modes
| Mode | Trigger | Primary Spec File |
|------|---------|-------------------|
| BUGFIX | fix, bug, broken, crash, regression, error | bugfix.md |
| FEATURE | add, create, build, new module/dashboard/endpoint | requirements.md |
| MIGRATION | migrate, dockerize, microservices, move to cloud/AWS | requirements.md |
| LEGACY_MODERNIZATION | legacy, technical debt, stabilize, decouple, modernize | requirements.md |

## Detection Rules
1. If task mentions migration/cloud/containerize/monolith → MIGRATION
2. If task mentions legacy/debt/stabilize/decouple → LEGACY_MODERNIZATION
3. If task mentions fix/bug/broken/crash/regression → BUGFIX
4. Default → FEATURE

## Output
After detection, the router must:
1. State the detected mode
2. Create spec folder under /specs/{mode}-{slug}/
3. Generate the correct spec files for that mode
4. Print the execution prompt for that mode

## Automation
Use `python scripts/new_task.py --task "description"` to automate this.
The script handles detection, folder creation, memory update, and prompt generation.
