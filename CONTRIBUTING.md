# Contributing to MindScrolling

Thank you for your interest in contributing. MindScrolling is a focused product with a clear philosophy — contributions that advance the mission of replacing mindless scrolling with meaningful reflection are welcome.

---

## Project Philosophy

Before contributing, internalize the product principle:

> Every feature must earn its place. We favor depth over breadth, quality over quantity, and clarity over cleverness. If a change doesn't serve the user's intellectual growth, it probably doesn't belong here.

---

## Local Setup

### Prerequisites

- Node.js 20+ (backend)
- Flutter SDK 3.x (mobile)
- A Supabase account (free tier works)
- Git

### Backend

```bash
git clone https://github.com/your-org/mindscrolling.git
cd mindscrolling/backend
npm install
cp ../.env.example .env
# Fill in SUPABASE_URL and SUPABASE_ANON_KEY
npm run dev
```

Run the SQL migration in your Supabase SQL editor:
```
backend/src/db/migrations/001_initial.sql
```

Seed quotes (optional, ~5 min):
```bash
node src/db/seed.js
```

### Flutter App

```bash
cd flutter_app
flutter pub get
flutter doctor        # verify setup
flutter run           # requires connected device or emulator
```

---

## Branch Naming

Use the following conventions:

| Type | Pattern | Example |
|---|---|---|
| Feature | `feat/short-description` | `feat/philosophy-map-delta` |
| Bug fix | `fix/short-description` | `fix/feed-cursor-reset` |
| Refactor | `refactor/short-description` | `refactor/swipe-handler` |
| Docs | `docs/short-description` | `docs/architecture-update` |
| Chore | `chore/short-description` | `chore/update-dependencies` |

Never commit directly to `main`. All changes go through pull requests.

---

## Commit Messages

Follow the [Conventional Commits](https://www.conventionalcommits.org/) standard:

```
<type>(<scope>): <short summary>

[optional body]
[optional footer]
```

Types: `feat` · `fix` · `refactor` · `docs` · `test` · `chore` · `perf`

Scopes: `feed` · `backend` · `flutter` · `db` · `onboarding` · `premium` · `map` · `vault`

**Examples:**
```
feat(feed): add author repeat penalty to scoring algorithm
fix(backend): correct seen_quotes cursor pagination overflow
docs(architecture): update philosophy map flow diagram
refactor(flutter): extract QuoteCard into standalone widget
chore(deps): bump fastify to 4.28.1
```

Keep the summary under 72 characters. Use imperative mood ("add", not "added").

---

## Pull Request Guidelines

1. **One concern per PR.** Don't mix features with refactors.
2. **Link the relevant task** from SCRUM.md or BACKLOG.md in the PR description.
3. **Fill in the PR template** — summary, what changed, how to test.
4. **Keep diffs readable.** Large PRs are hard to review and slow to merge.
5. **Update docs** if your change affects architecture, API contracts, or user-facing behavior.
6. **No breaking changes to the API** without prior discussion in an issue.

### PR Description Template

```markdown
## What
Brief description of the change.

## Why
The motivation or issue it solves.

## How to test
Step-by-step instructions to verify the change.

## Related
- Task ID from SCRUM.md: S5-XX
- Issue: #XX
```

---

## Issue Reporting

When opening an issue:

- **Bug:** Include steps to reproduce, expected vs actual behavior, and device/OS info.
- **Feature request:** Describe the user problem, not just the solution. Explain how it fits the product vision.
- **Performance:** Include profiling data or reproduction steps.

Use the issue labels: `bug` · `enhancement` · `question` · `documentation` · `wont-fix`

---

## Code Style

### Dart / Flutter

- Follow [Effective Dart](https://dart.dev/effective-dart/style) conventions.
- Run `flutter analyze` before committing — zero warnings expected.
- Format with `dart format .` before pushing.
- Prefer `const` constructors wherever possible.
- No `dynamic` types without explicit justification in a comment.
- Widget files stay under ~200 lines. Extract sub-widgets when needed.

### Node.js / Backend

- ES modules (`import/export`) — no CommonJS.
- `async/await` only — no raw `.then()` chains.
- All route handlers validate inputs before touching the database.
- No raw SQL strings in route handlers — use Supabase query builder.
- Error responses always use the format: `{ error: string, code: string }`.

### General

- No commented-out code in committed files.
- No hardcoded secrets, URLs, or credentials.
- No `console.log` in production paths (use structured logging if needed).

---

## Documentation Expectations

- **Architecture changes** → update `ARCHITECTURE.md`.
- **New API endpoints** → update the endpoints table in `README.md` and `ARCHITECTURE.md`.
- **New database tables** → update the schema section in `ARCHITECTURE.md` and add to `001_initial.sql`.
- **New Flutter features** → update the feature list in `SCRUM.md` and `ROADMAP.md`.
- **Sprint completion** → mark tasks ✅ in `SCRUM.md`.

---

## Testing Expectations

### Backend

- Every new route should have at least one manual `curl` test documented in your PR.
- Edge cases to always cover: empty device_id, missing body fields, non-existent resource IDs.
- Verify rate limiting is not broken by new routes.

### Flutter

- New widgets: test with an empty state, a loading state, and an error state.
- Run `flutter test` before opening a PR.
- Test on both iOS and Android if the change touches platform-specific behavior.

---

## Proposing New Features

1. Open an issue with the label `enhancement`.
2. Describe the problem it solves (not just the feature).
3. Reference where it fits in `ROADMAP.md`.
4. Wait for maintainer acknowledgment before building.

Features that contradict the product principle (see top of this doc) will be declined regardless of implementation quality.

---

## Multi-Agent Workflow

This repository includes agent memory and coordination files. When working with the multi-agent structure:

| Agent | Responsibility |
|---|---|
| Product Owner | Product scope, user stories, roadmap alignment |
| API Architect | Backend contracts, endpoint design, database schema |
| Backend Developer | Route implementation, migrations, seeder |
| Flutter / Frontend | Mobile architecture, screens, state management |
| QA Reviewer | Edge cases, regression checks, API consistency |

If your change is architectural (new table, new endpoint contract, new Flutter layer), open a discussion issue tagged `architecture` before implementing.

---

## Backend Changes

- All new routes must be registered in `backend/src/app.js`.
- New tables require a migration added to `backend/src/db/migrations/`.
- The `device_id` plugin is always present — never trust a client-supplied identity beyond what the plugin validates.
- Pagination uses cursors (UUID of last seen item), not page numbers.

## Flutter / Mobile Changes

- New screens must be registered in `flutter_app/lib/app/router.dart`.
- New features live in their own folder under `flutter_app/lib/features/`.
- All network calls go through `ApiClient` — never use `http` directly in a feature.
- State is managed via Riverpod — no `setState` outside of ephemeral local animation state.

## Architecture-Impacting Changes

Changes that affect more than one layer (e.g., new database table + new endpoint + new Flutter screen) require:

1. An `architecture` issue opened first.
2. Updated `ARCHITECTURE.md` included in the same PR.
3. Updated `SCRUM.md` with the relevant sprint task.

---

*MindScrolling is built by people who believe attention is sacred. Contribute accordingly.*
