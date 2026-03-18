---
name: MindScrolling - DevOps Engineer context
description: Infrastructure state, migration checklist, deployment status, and repo governance as of Sprint 7 (2026-03-18)
type: project
---

## Infrastructure State (2026-03-18)

- Backend: Fastify 4.x on Node.js (ESM) — deployed on Railway
- Database: Supabase (PostgreSQL + pgvector enabled)
- Embeddings: Voyage AI HTTP API (`voyage-3-lite`, 512 dims)
- AI Insights: Anthropic Claude (`claude-haiku-4-5-20251001`)
- Deployment: Railway (active)
- GitHub Pages: https://christianescamilla15-cell.github.io/MindScrolling/ (tester form)

## Migration Status (all applied in Supabase)

| Migration | Status |
|---|---|
| 001–007 | ✅ Applied (via 008 catch-up) |
| 008_catchup_schema.sql | ✅ Applied |
| 009_pack_monetization.sql | ✅ Applied (2026-03-18) |
| 010_authors_table.sql | ✅ Applied (2026-03-18) |

## Required Environment Variables (Railway production)

```
SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJ...   # service role, NOT anon
VOYAGE_API_KEY=pa-...
ANTHROPIC_API_KEY=sk-ant-...
ADMIN_SECRET=...                   # protects /admin/* endpoints
PORT=3000
NODE_ENV=production
```

**CRITICAL:** `DEV_FORCE_PREMIUM=true` must NOT be set in Railway production env. Remove before Play Store launch.

## Repository Governance (owns + maintains)

### Branch Protection Rules (GitHub — main branch)

Configured in: GitHub repo Settings → Branches → Branch protection rules

Rules for `main`:
- ✅ Require pull request before merging (1 approval)
- ✅ Dismiss stale pull request approvals when new commits are pushed
- ✅ Require status checks to pass before merging: `security-scan`
- ✅ Require branches to be up to date before merging
- ✅ Do not allow force pushes
- ✅ Do not allow deletions
- ✅ Include administrators

### CODEOWNERS

File: `.github/CODEOWNERS`

```
# Global fallback — founder reviews everything
*                           @christianescamilla15-cell

# Backend routes and services
/backend/src/routes/        @christianescamilla15-cell
/backend/src/services/      @christianescamilla15-cell

# DB migrations — extra caution, always require review
/backend/src/db/migrations/ @christianescamilla15-cell

# Flutter app
/flutter_app/lib/           @christianescamilla15-cell

# Agent system — only founder can modify
/.claude/                   @christianescamilla15-cell

# CI/CD workflows
/.github/workflows/         @christianescamilla15-cell
```

### CI/CD Workflows (owns)

| Workflow | Trigger | Purpose |
|---|---|---|
| `security-scan.yml` | push + weekly cron | Gitleaks + TruffleHog |
| `pages.yml` | push to main | Deploy tester form to GitHub Pages |
| `dependabot.yml` | weekly | npm + GH Actions updates |

## Pending Pre-Launch Gates

- [ ] Remove `DEV_FORCE_PREMIUM=true` from Railway before Play Store submission
- [ ] Fastify v4→v5 upgrade (DoS vuln — Dependabot will flag)
- [ ] Verify all 10 migrations applied and schema matches code
- [ ] Confirm Railway health check passing on `/health`

**Why:** Sprint 7 complete. Infrastructure stable. Repo governance configured. Pre-launch checklist is the next devops priority.
**How to apply:** Before any Play Store submission, run through pending pre-launch gates. CODEOWNERS and branch protection are set — do not modify without user approval.
