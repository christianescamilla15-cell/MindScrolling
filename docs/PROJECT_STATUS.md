# MindScrolling — Project Status

> Auto-generated on 2026-04-19

## Overview

| Metric | Value |
|--------|-------|
| App Version | `2.0.0+9` |
| Total Commits | 157 |
| Last Commit | `1a93796 security(mythos): delta scan post-feed-fix · no regressions` |
| Backend Files (JS) | 40 |
| Flutter Files (Dart) | 166 |
| API Route Files | 22 |
| DB Migrations | 66 |

## Architecture

- **Backend**: Fastify + Supabase (hosted on Render)
- **Mobile**: Flutter (Android, Play Store closed beta)
- **Database**: PostgreSQL via Supabase
- **AI**: Claude API for weekly insights
- **Payments**: RevenueCat + Google Play Billing

## API Endpoints: 22 route files

See [API_REFERENCE.md](API_REFERENCE.md) for full details.

## CI/CD Pipelines

| Workflow | Trigger | Purpose |
|---------|---------|--------|
| security-scan | push to main | Secret detection, dependency audit |
| backend-ci | push to backend/ | Syntax check, tests |
| flutter-ci | push to flutter_app/ | Analyze, build APK |
| release | git tag v* | Build AAB/APK, GitHub Release |
