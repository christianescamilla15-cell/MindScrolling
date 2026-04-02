# MindScrolling — Project Status

> Auto-generated on 2026-04-02

## Overview

| Metric | Value |
|--------|-------|
| App Version | `2.0.0+9` |
| Total Commits | 149 |
| Last Commit | `20507da feat: add Stripe Payment Links for all 7 products` |
| Backend Files (JS) | 39 |
| Flutter Files (Dart) | 162 |
| API Route Files | 21 |
| DB Migrations | 65 |

## Architecture

- **Backend**: Fastify + Supabase (hosted on Render)
- **Mobile**: Flutter (Android, Play Store closed beta)
- **Database**: PostgreSQL via Supabase
- **AI**: Claude API for weekly insights
- **Payments**: RevenueCat + Google Play Billing

## API Endpoints: 21 route files

See [API_REFERENCE.md](API_REFERENCE.md) for full details.

## CI/CD Pipelines

| Workflow | Trigger | Purpose |
|---------|---------|--------|
| security-scan | push to main | Secret detection, dependency audit |
| backend-ci | push to backend/ | Syntax check, tests |
| flutter-ci | push to flutter_app/ | Analyze, build APK |
| release | git tag v* | Build AAB/APK, GitHub Release |
