# Session Boot — Context Loading Protocol

## Purpose
Every new session MUST start by reading project memory.
This ensures continuity between sessions and prevents context loss.

## Mandatory Steps (in order)

### Step 1: Read Memory
Read these files in order:
1. /ai-memory/active_workstream.md — what's the current task?
2. /ai-memory/product_context.md — what's the product?
3. /ai-memory/tech_context.md — what's the stack?
4. /ai-memory/architecture_context.md — how is it structured?
5. /ai-memory/recent_decisions.md — what was decided recently?
6. /ai-memory/known_risks.md — what's dangerous?

### Step 2: Resume or Start
- If active_workstream has a current task → resume it
- If no active task → ask what to work on
- If starting a new task → run the Router (01_router.md)

### Step 3: Confirm Context
Before any work, state:
- Current task
- Current mode
- Current phase
- Active spec path
- Key constraints

## Session Boot Prompt (paste in CloudCode)
```
Read /ai-memory/active_workstream.md, /ai-memory/product_context.md, 
/ai-memory/tech_context.md, /ai-memory/architecture_context.md,
/ai-memory/recent_decisions.md, and /ai-memory/known_risks.md.

Then tell me: what is the current task, mode, phase, and what should I do next?
Follow the rules in /ai-system/00_master_rules.md.
```
