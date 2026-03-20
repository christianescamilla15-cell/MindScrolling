# Automation Rules — MindScrolling

Defines what Claude agents may do autonomously vs. what requires human approval.
These rules apply to all 18 MindScrolling agents.

---

## ALWAYS AUTO-APPROVE

### File Operations
- Create or edit files in `backend/src/`
- Create or edit files in `flutter_app/lib/`
- Create or edit files in `scripts/`
- Create or edit files in `docs/`
- Create or edit files in `cloud/`
- Create or edit files in `.claude/`
- Create or edit files in `.github/workflows/` (non-destructive edits only)

### Run Commands
- `node --check <file>` — syntax check only, no execution
- `npm test` — test suite, backend only
- `flutter analyze` — static analysis, no side effects
- `flutter test` — unit and widget tests
- `flutter test --coverage` — test suite with coverage report
- `node scripts/generate-docs.js` — documentation generation
- `node scripts/workflow.js` — workflow automation scripts

### Git Commands
- `git add <specific-files>` — stage specific files only (never `git add -A` or `git add .`)
- `git commit -m "<message>"` — conventional commits only
- `git status` — read-only
- `git log` — read-only
- `git diff` — read-only

### Documentation
- Update `cloud/control_tower/dashboard.md`
- Update `cloud/control_tower/build_history.md`
- Update `cloud/debugging/active_issues.md`
- Update `docs/checklist.md`
- Update any `.claude/agent-memory/*/MEMORY.md`

---

## ASK HUMAN FIRST

The agent must stop and request explicit approval before proceeding:

- `git push` — pushing to any remote
- `supabase db reset` — destructive database operation
- Any deletion of production data
- Rotating API keys (SUPABASE_ANON_KEY, VOYAGE_API_KEY, ANTHROPIC_API_KEY)
- Submitting to Google Play Store or Apple App Store
- `git push --force` — force push to any branch
- Running database migrations with `--run` flag on production Supabase
- Enabling or disabling Supabase extensions in production
- Changing `NODE_ENV=production` environment variables
- Triggering a RevenueCat product or pricing change

---

## NEVER DO

Hard rules — no exceptions, no human override:

- Commit `.env`, `.keystore`, `.jks`, or any file containing real credentials
- Hardcode API keys, tokens, or secrets in source files
- Skip pre-commit hooks (`--no-verify`, `--no-gpg-sign`)
- Push to main with failing CI checks
- Fire-and-forget async — always `await` or handle errors explicitly
- Use `.single()` for Supabase queries that may return 0 rows — use `.maybeSingle()`
- Modify `.gitignore` to un-ignore sensitive files
- Run `004_ai_feed.sql` without confirming pgvector extension is enabled in Supabase
- Run migrations out of order (order: 001 → 002 → 003 → 004, then sequential)
- Delete from `cloud/control_tower/build_history.md` — it is append-only

---

## Auto-Commit Protocol

After every completed feature that passes all gates (syntax check + tests + analyze):

```bash
# Stage specific files — never git add -A
git add backend/src/routes/example.js flutter_app/lib/features/example/...

# Conventional commit format
git commit -m "feat(feed): add AI-powered quote ranking via pgvector match_quotes"
# OR
git commit -m "fix(premium): restore purchases flow validates receipt before granting access"
# OR
git commit -m "chore(deps): upgrade @anthropic-ai/sdk to 0.24.0"

# DO NOT push — wait for human approval
```

### Conventional Commit Types
- `feat` — new feature
- `fix` — bug fix
- `chore` — dependency, config, or tooling change
- `docs` — documentation only
- `test` — adding or updating tests
- `refactor` — code change that is neither a bug fix nor a feature
- `perf` — performance improvement
- `ci` — CI/CD workflow changes

---

## Auto-Update Protocol

After every commit, in order:

1. Update `cloud/control_tower/dashboard.md` — reflect new build state, open blockers, last updated timestamp
2. Update `cloud/control_tower/build_history.md` — append new row (never edit existing rows)
3. Check `docs/checklist.md` — mark completed items with `[x]`
4. Propose next task from `docs/checklist.md` Sprint 7 P0 list

---

## Migration Safety Rules

Before running any migration:

1. Confirm current state: which migrations have already been applied
2. Run in order — never skip
3. Before `004_ai_feed.sql`: confirm pgvector is enabled in Supabase Dashboard → Extensions
4. After each migration: verify the schema change took effect (spot-check via Supabase SQL editor)
5. Never run `supabase db reset` in production — only in local development

Migration order:
```
001_initial.sql
002_fix_swipe_dir.sql
003_feed_algorithm.sql
004_ai_feed.sql
... (subsequent numbered migrations in order)
```

---

## Embed-Quotes Safety Rules

The `npm run embed-quotes` script is a one-time batch operation:

- Run only after `004_ai_feed.sql` is applied and pgvector index exists
- Run only from the `backend/` directory
- Monitor output — if it errors mid-batch, it is safe to re-run (idempotent on already-embedded quotes)
- Expected duration: ~30 minutes for ~5,500 quotes
- After completion: verify `GET /quotes/feed` returns AI-ranked results

---

## Environment Variable Rules

- All new env variables must be added to `.env.example` with a placeholder value and inline comment
- Never add real values to `.env.example`
- Format for `.env.example` entries:
  ```
  VARIABLE_NAME=your_value_here  # Description of what this is and where to get it
  ```
- Required variables for production are documented in `.env.example` and in `CLAUDE.md`
