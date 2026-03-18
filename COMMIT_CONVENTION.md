# Commit Convention — MindScrolling

Every commit in this repository must follow this convention.
Enforced automatically by `.git/hooks/commit-msg`.

---

## Format

```
type(scope): short description
```

- **One line**, max **100 characters**
- **No period** at the end
- **Lowercase** type and scope
- **Imperative mood** — "add" not "added", "fix" not "fixed"

---

## Types

| Type | When to use | Example |
|------|-------------|---------|
| `feat` | New feature or visible improvement | `feat(feed): add diversity cap for category balance` |
| `fix` | Bug fix | `fix(premium): correct iOS premium_source in /verify` |
| `sec` | Security fix or hardening | `sec(admin): replace string equality with timingSafeEqual` |
| `perf` | Performance improvement | `perf(db): add partial indexes for free-user feed query` |
| `refactor` | Code change with no behavior change | `refactor(challenges): extract TARGET_QUOTES constant` |
| `docs` | Documentation only | `docs: add cloud/ directory to ARCHITECTURE.md` |
| `chore` | Dependencies, tooling, config | `chore(deps): upgrade @sentry/node to 10.x` |
| `test` | Tests only | `test(vault): add free-user limit enforcement test` |
| `ci` | GitHub Actions / CI changes | `ci: add gitleaks secret scan to security workflow` |
| `build` | Build system changes | `build(flutter): configure release signing` |
| `style` | Formatting, whitespace (no logic change) | `style(quotes): align column widths in PACK_META` |
| `revert` | Reverts a previous commit | `revert: feat(packs): add pack preview fields` |

---

## Scopes (optional but recommended)

Use a scope to say **where** the change is:

| Scope | Area |
|-------|------|
| `feed` | Feed algorithm, quote fetching |
| `vault` | Vault save/delete/limit |
| `premium` | Premium flow, trial, RevenueCat |
| `challenge` | Daily challenge logic |
| `map` | Philosophy map, radar chart, snapshots |
| `authors` | Author detail, bios |
| `packs` | Content packs, pack explorer |
| `audio` | Ambient audio |
| `admin` | Admin endpoints |
| `insights` | Weekly AI insight |
| `profile` | User profile, onboarding |
| `notifications` | Push notifications |
| `i18n` | Localization (EN/ES strings) |
| `flutter` | Flutter app (when not feature-specific) |
| `backend` | Backend (when not feature-specific) |
| `db` | Database migrations, schema |
| `deps` | Dependencies |
| `hooks` | Git hooks |
| `ci` | GitHub Actions workflows |

---

## Body (optional)

Add a blank line after the first line, then explain **why** (not what — the diff shows what):

```
fix(premium): correct iOS premium_source in /purchase/verify

The field was always set to "play_billing" regardless of the store
reported by the client. This caused iOS purchases to appear as Android
in the audit log, breaking any store-based analytics filtering.
```

---

## Security commits (`sec` type)

Any commit that fixes a security issue **must** use `sec` as the type:

```
sec(admin): replace string equality with crypto.timingSafeEqual
sec(scripts): remove hardcoded Supabase credentials from fetch_es.js
sec(webhooks): add timing-safe verification for RevenueCat secret
```

After a `sec` commit:
1. The pre-commit hook will remind you to check `cloud/workflows/security_workflow.md`
2. Update `cloud/debugging/fix_history.md` with the security fix
3. If credentials were exposed: rotate keys immediately (see security workflow)

---

## Examples — Good vs Bad

```
✅  feat(feed): add semantic reranking for returning users
✅  fix(vault): enforce 20-quote free limit server-side
✅  sec(admin): replace string equality with timingSafeEqual
✅  perf(db): add partial indexes for vault and challenge queries
✅  docs: update SCRUM.md with Sprint 6 QA gate results
✅  chore(deps): add @sentry/node for production error tracking
✅  ci: add gitleaks and jwt scan to GitHub Actions workflow

❌  Fixed the bug                    ← no type, too vague
❌  feat: updated some stuff.         ← trailing period, vague
❌  FEAT(FEED): Add reranking         ← uppercase type/scope
❌  feat(feed): Add diversity cap to prevent the feed from showing too many quotes from the same category in a single session by capping at 60%  ← too long (>100 chars)
❌  fix vault limit bug               ← missing colon
```

---

## Setup on a new machine

```bash
# After cloning the repo:
sh scripts/setup-hooks.sh
```

This installs `pre-commit`, `commit-msg`, and `prepare-commit-msg` hooks into `.git/hooks/`.

> **Note:** Git hooks are not tracked by default (`.git/` is excluded). The hook source files live in `scripts/hooks/` and are installed by the setup script.

---

## Emergency bypass

If a hook is blocking a legitimate commit (false positive):

```bash
git commit --no-verify -m "type(scope): description"
```

**Use sparingly.** Log the reason in the commit body and fix the hook if it's wrong.
