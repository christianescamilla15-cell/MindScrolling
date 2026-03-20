# MindScrolling — Claude Code Project Rules

## Project Structure
- `backend/` — Fastify API server (Node.js 20+, Supabase PostgreSQL)
- `flutter_app/` — Flutter mobile app (Android + iOS)
- `scripts/` — Automation scripts (docs, hooks, dataset)
- `docs/` — Auto-generated documentation
- `.github/workflows/` — CI/CD pipelines

## Backend Rules
- All routes in `backend/src/routes/` — one file per resource
- Shared utilities in `backend/src/utils/validation.js` (UUID_RE, authorSlug, normalizeLang)
- Every endpoint requires `x-device-id` header validation
- Use `request.deviceId` after validation plugin runs
- Database: Supabase client via `request.server.supabase`
- Error responses: `{ error: 'message' }` with appropriate HTTP status

## Flutter Rules
- State management: Riverpod with code generation
- Navigation: GoRouter
- API calls: `ApiClient` from `core/services/api_client.dart`
- All user-facing strings must be localized (AppLocalizations)
- Models in `data/models/`, providers in `data/providers/`
- Screens in `features/<feature>/`

## Coding Standards
- No fire-and-forget async — always await or handle errors
- Always check `mounted` before `setState` or navigation in async callbacks
- Use `.maybeSingle()` instead of `.single()` for Supabase queries that may return 0 rows
- Normalize language codes: `normalizeLang(lang)` → 'en' | 'es'
- Validate UUIDs with `UUID_RE.test(id)` before database queries

## CI/CD
- Push to main auto-triggers: security-scan, backend-ci, flutter-ci, auto-docs
- Tag `v*` triggers release build (AAB + APK + GitHub Release)
- Render auto-deploys backend on push to main

## Deployment
- Backend: https://mindscrolling.onrender.com
- Database: Supabase (rwhvjtfargojxccqblfb)
- Play Store: com.mindscrolling.app (closed beta)

## Common Commands
```bash
# Backend
cd backend && npm run dev          # Dev server
cd backend && npm test             # Run tests

# Flutter
cd flutter_app
C:\flutter\flutter\bin\flutter.bat pub get
C:\flutter\flutter\bin\flutter.bat build apk --release
C:\flutter\flutter\bin\flutter.bat build appbundle --release

# Docs
node scripts/generate-docs.js

# Version bump (always increment +N)
# Edit flutter_app/pubspec.yaml → version: X.Y.Z+N
```
