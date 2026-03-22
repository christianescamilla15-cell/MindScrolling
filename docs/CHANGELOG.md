# Changelog

> Auto-generated on 2026-03-22

## Features

- `9b6b704` 8 personalization features — semantic matching across full app
- `b30f032` hybrid semantic matching for Insight + idempotent migration v2
- `34bc1fc` Phase 8 — Coding hidden mode with practice console
- `ec6d8ae` Phase 7 — Science hidden mode with 4 branches
- `832d7f2` Phase 6 — quiz gating for hidden modes (10 questions, >=8 to unlock)
- `6e8b4e0` Phase 5 — hidden mode intent detection + unlock suggestion
- `e01768d` Phase 4 — Insight emotional input + personalized quote matching
- `38abe35` Phase 3 — dual purchase flow (real IAP + simulated dev mode)
- `483b14b` Phase 2 — 3 new packs (Renaissance Mind, Classical Foundations, Modern Human Condition)
- `597e3da` Phase 1 — content model refactor for multi-mode expansion
- `6cc8763` (security): single-device lock — APK restricted to one physical device
- `bbfb10e` (ci): automated API integration test suite — 36 endpoints, runs on deploy + every 6h
- `7a1615b` port WordForge workflow patterns — control tower, automation rules, concurrency, coverage
- `066d7ff` full automation suite — deploy, migrations, bootstrap, QA, notifications
- `00a19b7` complete CI/CD, automation scripts, and dev workflow
- `bd57b62` add zen meditation splash logo and app launcher icon

## Bug Fixes

- `972a56a` resolve 4 CRITICAL + 3 HIGH from stress test audit
- `b53a6d4` API contract gaps — icons, preview fields, generated_at
- `bcfca64` algorithm audit — fix match_quotes RPC + real preference affinity
- `46f199b` (security): resolve 2 CRITICAL + 3 HIGH + 2 MEDIUM from deep audit
- `f5a66fa` resolve 3 CRITICAL + 5 HIGH + 4 MEDIUM from QA audit
- `71107dd` (security): resolve 3 HIGH + 4 MEDIUM from security audit
- `b11ef51` resolve 3 HIGH + 4 MEDIUM bugs from SCRUM feature audit
- `eddda84` (ci): api-test handles rate limiting with retry + fix JSON body encoding
- `3620d50` (backend): revert authorSlug to underscore separator — matches DB slugs
- `586871e` resolve 4 bugs from QA audit — race condition, slug separator, CORS, docs
- `ba3187e` (ci): resolve all CI failures + add self-healing ci-doctor workflow
- `490356a` (ci): keystore filename matches key.properties (mindscrolling-release.jks)
- `9253ccb` profile reflections reads correct key, router param renamed to :slug
- `dacba9d` authorSlug handles ø/ð/þ/ł/ß/æ, vault sends author_slug, Kierkegaard dedup
- `f611118` ES author names match authors table for correct bio lookups
- `513213c` challenge progress cache date-scoped, listener guard, comment clarity
- `34f8540` daily challenge — real-time progress + language reload
- `4b7e258` ambient audio — loop mode on resume, error state sync
- `4e11c70` ambient music now loops — await setLoopMode before play
- `ed81374` restore discipline, reflection, philosophy to free feed
- `411b0c4` remove discipline from stoicism_deep pack assignment
- `62ba1d8` post-build QA — trial consistency, vault trial bypass, platform guard
- `54c7f1a` build errors — zonedSchedule param, ChallengeRepository import
- `0ece7bc` tier-level QA — trial feed, purchase safety, feature gates, webhook validation
- `bcecb66` QA Final Round — match_quotes pack leak, IAP receipt safety, error handling

## Documentation

- `fc6c4a1` add PENDING_HUMAN_TASKS for post-expansion deployment
- `84341e5` auto-commit 2 file(s)

## Chores

- `8bdce47` Phase 0 baseline — fix unused import warning, update docs
- `ec2010d` (deps): Bump @anthropic-ai/sdk from 0.36.3 to 0.79.0 in /backend (#7)
- `6ec2dd4` (deps): Bump fastify-plugin from 4.5.1 to 5.1.0 in /backend (#6)
- `06fa71b` (deps): Bump dotenv from 16.6.1 to 17.3.1 in /backend (#5)
- `2746d51` (deps): Bump actions/setup-node from 4 to 6 (#4)
- `71f6776` (deps): Bump actions/configure-pages from 4 to 5 (#1)
- `fb8a3c3` (chore): auto-commit 1 file(s)

