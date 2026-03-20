# MindScrolling — Project Status

> Auto-generated on 2026-03-20

## Overview

| Metric | Value |
|--------|-------|
| App Version | `1.2.1+8` |
| Total Commits | 95 |
| Last Commit | `6cc8763 feat(security): single-device lock — APK restricted to one physical device` |
| Backend Files (JS) | 34 |
| Flutter Files (Dart) | 128 |
| API Route Files | 17 |
| DB Migrations | 22 |

## Architecture

- **Backend**: Fastify + Supabase (hosted on Render)
- **Mobile**: Flutter (Android, Play Store closed beta)
- **Database**: PostgreSQL via Supabase
- **AI**: Claude API for weekly insights
- **Payments**: RevenueCat + Google Play Billing

## API Endpoints: 17 route files

See [API_REFERENCE.md](API_REFERENCE.md) for full details.

## CI/CD Pipelines

| Workflow | Trigger | Purpose |
|---------|---------|--------|
| security-scan | push to main | Secret detection, dependency audit |
| backend-ci | push to backend/ | Syntax check, tests |
| flutter-ci | push to flutter_app/ | Analyze, build APK |
| release | git tag v* | Build AAB/APK, GitHub Release |
