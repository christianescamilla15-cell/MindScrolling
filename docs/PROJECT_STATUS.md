# MindScrolling — Project Status

> Auto-generated on 2026-03-22

## Overview

| Metric | Value |
|--------|-------|
| App Version | `1.2.1+8` |
| Total Commits | 114 |
| Last Commit | `17603a3 fix: resolve all pending audit items — security, UX, algorithm` |
| Backend Files (JS) | 35 |
| Flutter Files (Dart) | 146 |
| API Route Files | 18 |
| DB Migrations | 27 |

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
