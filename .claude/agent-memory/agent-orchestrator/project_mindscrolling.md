---
name: MindScrolling - Agent Orchestrator context
description: Full project state, Sprint 5 progress, 11-agent system status, pending deployment blockers
type: project
---

## Project Overview

MindScrolling — philosophical content app ("TikTok for philosophy"). Flutter mobile app + Fastify backend + Supabase database.

## Sprint 5 State (as of 2026-03-16)

### Completed this sprint
- Feed algorithm v2: Voyage AI embeddings + EMA preference vectors + hybrid/behavioural dual mode
- `embeddings.js` and `insights.js` services created
- `quotes.js`, `likes.js`, `swipes.js`, `vault.js` all updated for AI signals
- `004_ai_feed.sql` migration written (pgvector + HNSW + match_quotes RPC)
- 298 curated philosophical quotes in `data/quotes_core.json`
- Full dataset pipeline `scripts/prepare_quotes_dataset.py`
- 11-agent Claude Code system: all agent .md files created

### Pending (blockers to production)
- Run `004_ai_feed.sql` in Supabase (requires pgvector extension enabled first)
- `npm install` (for @anthropic-ai/sdk)
- `npm run embed-quotes` (one-time batch embedding, ~30 min)
- Import `data/seed_quotes.sql` into Supabase
- Flutter `features/insights/` screen not yet implemented

## 11-Agent System Status

| Agent | File | Memory | Status |
|---|---|---|---|
| product-owner | ✅ | ✅ | Upgraded |
| scrum-coordinator | ✅ | ✅ | Upgraded |
| api-architect | ✅ | ✅ | Upgraded |
| backend-implementer | ✅ | ✅ | Upgraded |
| qa-reviewer | ✅ | ✅ | Upgraded |
| flutter-mobile-engineer | ✅ | ✅ | NEW |
| recommendation-engineer | ✅ | ✅ | NEW (model: opus) |
| data-content-engineer | ✅ | ✅ | NEW |
| devops-engineer | ✅ | ✅ | NEW |
| documentation-writer | ✅ | ✅ | NEW |
| agent-orchestrator | ✅ | ✅ | NEW (model: opus) |

## Standard Agent Sequences

- New feature: product-owner → api-architect → backend-implementer → flutter-mobile-engineer → qa-reviewer → documentation-writer
- Algorithm change: recommendation-engineer → qa-reviewer → documentation-writer
- Dataset update: data-content-engineer → devops-engineer → qa-reviewer
- Sprint close: qa-reviewer → scrum-coordinator → documentation-writer
- Production deploy: qa-reviewer → devops-engineer → documentation-writer

**Why:** Complete multi-agent system build during Sprint 5.
**How to apply:** Use as the definitive project state reference before orchestrating any task.
