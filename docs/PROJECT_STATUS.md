# MindScrolling — Project Status

> Auto-generated on 2026-04-01

## Overview

| Metric | Value |
|--------|-------|
| App Version | `2.0.0+9` |
| Total Commits | 143 |
| Last Commit | `8596fff feat: multi-interest selector (3 picks) + share quotes foundation (Kiro FEATURE)` |
| Backend Files (JS) | 37 |
| Flutter Files (Dart) | 160 |
| API Route Files | 19 |
| DB Migrations | 63 |

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
