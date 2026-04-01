# Context Refresh — End of Session Protocol

## Purpose
At the end of every work session, update memory to preserve continuity.

## What to Update

### 1. active_workstream.md
Update:
- Current phase
- Session summary
- Next step

### 2. recent_decisions.md
Append any durable decisions made:
- Architecture choices
- Pattern selections
- Tradeoff resolutions
- Rejected alternatives

### 3. known_risks.md
Append any new risks discovered:
- Technical risks
- Integration risks
- Migration risks
- Security concerns

## Automation
Run: `python scripts/session_refresh.py --summary "what was done" --next-step "what comes next"`

Optional flags:
- `--phase "Validation"`
- `--decisions "Chose strangler pattern over big-bang rewrite"`
- `--risks "Auth module has no tests — fragile"`

## Manual Refresh Prompt (paste in CloudCode)
```
Before ending this session, update:
1. /ai-memory/active_workstream.md with current phase and next step
2. /ai-memory/recent_decisions.md with any decisions made
3. /ai-memory/known_risks.md with any new risks

Summarize what was accomplished and what should happen next session.
```
