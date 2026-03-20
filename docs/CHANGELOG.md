# Changelog

> Auto-generated on 2026-03-20

## Features

- `7a1615b` port WordForge workflow patterns — control tower, automation rules, concurrency, coverage
- `066d7ff` full automation suite — deploy, migrations, bootstrap, QA, notifications
- `00a19b7` complete CI/CD, automation scripts, and dev workflow
- `bd57b62` add zen meditation splash logo and app launcher icon
- `d53f630` real IAP for individual packs (B-01)
- `95eab5a` Sprint 7 — analytics, rating prompt, trial funnel, paywall UX
- `97d9b2d` add Growth/ASO + UX Synthesizer agents, CODEOWNERS, branch protection

## Bug Fixes

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
- `7a6bb57` resolve 4 known v1.0 limitations — swipe, notifications, stats, authors
- `ba7f590` QA Rounds 11-15 — admin double-auth, vault error check, target propagation
- `54d3b8c` QA Round 11 — challenge target propagation, preview contract fix
- `109b799` QA Round 10 — compile error, delta overcount, profile serialization
- `55dcbdb` QA Round 9 — challenge progress desync, profile contract, input validation
- `68a5b65` QA Round 8 — likes error check, author display name, feed stability
- `8096027` QA Round 7 — integration, validation, localization, and offline resilience
- `469df2d` QA Rounds 5 & 6 — security, correctness, and UX hardening
- `9c6be87` QA Round 4 — HIGH backend issues + DB_ERROR → INTERNAL_ERROR global sweep
- `0bb5db8` QA Round 4 — CRITICAL integration, Flutter, and backend issues
- `7d93c91` dev panel guarded by kDebugMode, pack feed double-tap like, Seneca dedup
- `fa3610e` wire analytics call sites, restore() timeout, logAppOpen, packs DB_ERROR codes
- `691671f` deduplicate author_bios.js — remove 26 duplicate/malformed entries
- `c722453` author screen — remove dead _error field, neutral fallback bio string
- `336f590` backend MED/LOW cleanup — remove is_premium leak, hardcoded count, rawBody stub
- `d7684f1` QA round 2 — dangling completers, table scans, author slugs, analytics
- `d9c9654` QA audit — HIGH/MEDIUM/LOW bugs from Sprint 7 review
- `e134cc2` trial countdown always showing 7 days (offline fallback bug)
- `094f81c` 4 bugs from v1.4 tester feedback
- `04a106c` downgrade @fastify/helmet to v11 for Fastify 4 compatibility
- `c8e884e` add missing webhooks.js + fix AllowedSwipeDirection.only top→up

## Documentation

- `84341e5` auto-commit 2 file(s)

## Chores

- `ec2010d` (deps): Bump @anthropic-ai/sdk from 0.36.3 to 0.79.0 in /backend (#7)
- `6ec2dd4` (deps): Bump fastify-plugin from 4.5.1 to 5.1.0 in /backend (#6)
- `06fa71b` (deps): Bump dotenv from 16.6.1 to 17.3.1 in /backend (#5)
- `2746d51` (deps): Bump actions/setup-node from 4 to 6 (#4)
- `71f6776` (deps): Bump actions/configure-pages from 4 to 5 (#1)
- `fb8a3c3` (chore): auto-commit 1 file(s)

