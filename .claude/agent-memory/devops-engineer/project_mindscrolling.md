---
name: MindScrolling - DevOps Engineer context
description: Infrastructure state, migration checklist, environment variables, and deployment status
type: project
---

## Infrastructure State (2026-03-16)

- Backend: Fastify 4.x on Node.js (ESM)
- Database: Supabase (PostgreSQL + pgvector when enabled)
- Embeddings: Voyage AI HTTP API (`voyage-3-lite`, 512 dims)
- AI Insights: Anthropic Claude (`claude-haiku-4-5-20251001`)
- Deployment target: Railway (preferred) or Fly.io
- Status: **NOT YET deployed to production**

## Migration Status

| Migration | Status |
|---|---|
| 001_initial.sql | ❓ Unknown — assumed applied (app was running before) |
| 002_fix_swipe_dir.sql | ❓ Unknown |
| 003_feed_algorithm.sql | ❓ Unknown |
| 004_ai_feed.sql | ❌ NOT applied — requires pgvector extension first |

## Required Environment Variables

```
SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_ANON_KEY=eyJ...
VOYAGE_API_KEY=pa-...        # from voyageai.com
ANTHROPIC_API_KEY=sk-ant-... # from console.anthropic.com
PORT=3000
NODE_ENV=production
```

## Deployment Sequence (MUST follow this order)

1. Enable pgvector extension in Supabase Dashboard → Extensions
2. Run `004_ai_feed.sql` in Supabase SQL Editor
3. `cd backend && npm install` (installs @anthropic-ai/sdk)
4. Import `data/seed_quotes.sql` into Supabase (298 curated quotes)
5. `npm run embed-quotes` (one-time batch, ~30 min for 5500 quotes)
6. Deploy backend to Railway/Fly.io with all env vars set
7. Verify `GET /health` → `{ status: "ok" }`
8. Verify `GET /quotes/feed` with X-Device-ID header

## New npm Scripts (from Sprint 5)

```json
"embed-quotes": "node src/db/scripts/embed_quotes.js"
```

**Why:** Sprint 5 AI feed implementation requires new infrastructure setup.
**How to apply:** Use as the definitive deployment checklist. Do not skip any step.
