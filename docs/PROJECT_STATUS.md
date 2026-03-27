# MindScrolling — Project Status

> Auto-generated on 2026-03-27

## Overview

| Metric | Value |
|--------|-------|
| App Version | `2.0.0+9` |
| Total Commits | 139 |
| Last Commit | `60db18c fix: Remove single-device lock — allow multi-device installation` |
| Backend Files (JS) | 37 |
| Flutter Files (Dart) | 151 |
| API Route Files | 19 |
| DB Migrations | 62 |

## Architecture

- **Backend**: Fastify + Supabase (hosted on Render)
- **Mobile**: Flutter (Android, Play Store closed beta)
- **Database**: PostgreSQL via Supabase
- **AI**: Claude API for weekly insights
- **Payments**: RevenueCat + Google Play Billing

## API Endpoints: 19 route files

See [API_REFERENCE.md](API_REFERENCE.md) for full details.

## CI/CD Pipelines

| Workflow | Trigger | Purpose |
|---------|---------|--------|
| security-scan | push to main | Secret detection, dependency audit |
| backend-ci | push to backend/ | Syntax check, tests |
| flutter-ci | push to flutter_app/ | Analyze, build APK |
| release | git tag v* | Build AAB/APK, GitHub Release |
