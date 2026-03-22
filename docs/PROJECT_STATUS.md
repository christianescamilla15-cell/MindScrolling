# MindScrolling — Project Status

> Auto-generated on 2026-03-22

## Overview

| Metric | Value |
|--------|-------|
| App Version | `1.2.1+8` |
| Total Commits | 121 |
| Last Commit | `d3a1ecd fix: resolve 10 pending items — security + UX + localization` |
| Backend Files (JS) | 36 |
| Flutter Files (Dart) | 147 |
| API Route Files | 18 |
| DB Migrations | 28 |

## Architecture

- **Backend**: Fastify + Supabase (hosted on Render)
- **Mobile**: Flutter (Android, Play Store closed beta)
- **Database**: PostgreSQL via Supabase
- **AI**: Claude API for weekly insights
- **Payments**: RevenueCat + Google Play Billing

## API Endpoints: 18 route files

See [API_REFERENCE.md](API_REFERENCE.md) for full details.

## CI/CD Pipelines

| Workflow | Trigger | Purpose |
|---------|---------|--------|
| security-scan | push to main | Secret detection, dependency audit |
| backend-ci | push to backend/ | Syntax check, tests |
| flutter-ci | push to flutter_app/ | Analyze, build APK |
| release | git tag v* | Build AAB/APK, GitHub Release |
