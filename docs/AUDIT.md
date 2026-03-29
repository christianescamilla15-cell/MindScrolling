# MindScrolling Codebase Audit

**Date:** 2026-03-29
**Auditor:** Automated deep review via Claude Code
**Scope:** Full repository — Flutter app, Fastify backend, CI/CD, docs, tests

---

## 1. Project Overview

MindScrolling is a cross-platform mobile app (Flutter + Fastify + Supabase) that delivers a philosophical quote feed designed to counter doom-scrolling. Users swipe through quotes in four directions, each mapped to a philosophical category (Stoicism, Discipline, Reflection, Philosophy). The app includes a premium monetization layer, ambient audio, daily challenges, a vault system, onboarding, and hidden easter-egg modes (science, coding, quizzes).

**Tech stack:**
- Mobile: Flutter 3.x / Dart (Riverpod + GoRouter)
- Backend: Node.js 20+ / Fastify
- Database: Supabase (PostgreSQL + pgvector)
- CI/CD: 14 GitHub Actions workflows (1,530 lines total)
- Distribution: Google Play Store (version 2.0.0+9)
- Monitoring: Sentry (Flutter + Backend)

**Current state:** Published on Google Play, multi-sprint product with 140+ commits. Active development.

---

## 2. Architecture Assessment

### Folder Structure — Grade: A-

The Flutter app follows a well-organized layered architecture:

```
flutter_app/lib/
  app/            — App shell, router, theme, localization
  core/           — Network, storage, analytics, constants, utils
  data/           — Models, repositories, datasources (local + remote)
  features/       — Feature-scoped modules (feed, onboarding, premium, etc.)
  shared/         — Reusable widgets and extensions
```

**Strengths:**
- Clean separation between `data/`, `core/`, `features/`, and `shared/` layers.
- Feature folders group screen, controller, and widgets together (e.g., `features/feed/feed_screen.dart`, `feed_controller.dart`, `widgets/`).
- Repository pattern with remote/local datasource split is textbook clean architecture.
- Theme tokens (colors, typography, spacings) are centralized under `app/theme/`.

**Weaknesses:**
- Two competing `insight` vs. `insights` feature folders — naming collision suggests incomplete refactor or duplicated concern.
- `features/hidden_modes/` has 10 files that mix screens, controllers, and data (quiz_data.dart) without sub-folders.
- `features/swipe/` (6 files) is architecturally a "core" concern, not a feature — it drives the entire feed UX.
- `features/ambient/` (5 files) could be simplified or merged into a service.

### Backend Structure — Grade: B+

```
backend/src/
  routes/       — 18 route modules
  services/     — 4 service modules
  db/           — Client, seed scripts
  plugins/      — Fastify plugins (1)
  data/         — Static data (author bios)
  utils/        — Validation
```

**Strengths:**
- Clean Fastify plugin registration pattern in `app.js`.
- Routes are well-separated by domain concern (quotes, vault, likes, stats, etc.).
- Sentry integration, rate limiting, helmet, CORS configured properly.
- Sensitive headers are redacted from logs.

**Weaknesses:**
- 18 route files but only 4 services — most business logic likely lives in routes.
- `db/scripts/` has 6 ad-hoc data migration scripts that could be formalized.
- No middleware layer or shared validation beyond `utils/validation.js`.

---

## 3. Code Quality

### Naming Consistency — Grade: A-

- Dart files use `snake_case.dart`, classes use `PascalCase`, providers use `camelCaseProvider` — all standard.
- Backend JS uses `kebab-case.js` for route filenames, `camelCase` for variables — consistent.
- Minor inconsistency: `maybeinjectSoftPaywall` (line 361 of feed_controller.dart) — missing camelCase `I` in `inject`. Should be `maybeInjectSoftPaywall`.

### Duplication — Grade: B

- `feed_screen.dart` (908 lines) is the largest single file and contains the screen, header widgets, loading shimmer, error view, and feed limit view — all as private classes in one file. This is not duplication per se, but a single-file-monolith pattern that hinders readability.
- `premium_screen.dart` (593 lines) similarly packs all sub-widgets (hero, badge, trial banner, comparison table, price label, unlock button, status message) into one file.
- Two separate `insight/` and `insights/` feature folders likely share overlapping logic.
- `feed_prefetch.dart` and `feed_prefetch_service.dart` exist alongside `feed_queue.dart` and `feed_queue_manager.dart` — 4 files for what could be 2.

### Complexity — Grade: B

- `FeedScreen._onSwipe()` handles 5+ card types with different logic — a candidate for extraction into a strategy pattern.
- `FeedController.onSwipe()` does haptics, analytics, state updates, item reordering, persistence, and prefetch triggering — 80 lines of mixed concerns.
- The `initState()` of `_FeedScreenState` (lines 66-128) is 60+ lines executing 6+ async operations with nested conditionals.
- The router file (`router.dart`, 220 lines) uses `state.extra as Map<String, dynamic>` casts — fragile and not type-safe.

### Dead Code

- `_BlockedApp` class in `main.dart` (lines 80-124) is defined but never referenced. The device lock check is non-blocking (line 44), so this widget is unreachable.
- The `redirect` function in `router.dart` (lines 38-41) always returns `null` — effectively a no-op.

---

## 4. Visual/UI Assessment — Grade: A

### Theme System

The theme is professionally implemented:

- `AppColors` — 18 named semantic colors, no magic hex values scattered in widgets.
- `AppTypography` — 10+ text styles using two custom fonts (Playfair Display + DM Sans), with a fluid `quoteTextScaled()` method.
- `AppSpacings` — Centralized spacing tokens (xxs through xxl).
- `AppTheme` — Comprehensive MaterialApp theme covering AppBar, Card, BottomNav, NavigationBar, Divider, Text, Input, Buttons, Chip, Dialog, BottomSheet, and SnackBar.
- Splash/ink effects are globally disabled for a clean, minimal aesthetic.

### Consistency

- Dark mode only (intentional design decision) — consistent throughout.
- All screens use the same color vocabulary (stoicism=teal, philosophy=amber, discipline=orange, reflection=purple).
- Rounded corners use `BorderRadius.circular(28)` for cards and `circular(16)` for inputs — mostly consistent.
- Some screens still use raw `Color(0xFF...)` instead of `AppColors` references (e.g., `Color(0xFF1B6B3A)` in `_TrialBanner`, `Color(0xFF1A1A2E)` in `_ComparisonTable`).

### Polish

- Staggered fade-in animations on onboarding (Page 0 and Page 2).
- Loading shimmer with rotating philosophical quotes during cold start.
- Swipe direction overlay with intensity tracking.
- Streak pulse animation.
- Haptic feedback on all interactions (light, medium, heavy, warning).

---

## 5. Testing Assessment — Grade: D

### What Exists

| Test Type | Files | Assertions |
|-----------|-------|-----------|
| Widget test | 1 (`test/widget_test.dart`) | 1 — "app loads" |
| Integration test | 1 (`integration_test/app_test.dart`) | 5 — app launch, swipe directions, bottom nav |
| Backend test | 1 (`tests/pre-release-scenarios.js`) | Scenario-based, requires running server |

### What Is Not Tested

- **Zero unit tests** for any controller, repository, model, or service.
- `FeedController` (444 lines, most critical business logic) has no tests.
- `PremiumController`, `OnboardingController`, `ChallengesController` — untested.
- All 7 repositories — untested.
- All 8 data models — untested.
- Backend routes (18 files) — only the pre-release scenario file, which requires a live server.
- No mocking infrastructure exists.

### CI Testing

- `flutter-ci.yml` and `api-tests.yml` workflows exist, but the actual test coverage they exercise is near zero given the test file contents.

---

## 6. Documentation Assessment — Grade: B+

### README

- `README.md` (109 lines) — clear overview, product thesis, tech stack table, architecture diagram, repo structure, how-to-run instructions, and roadmap. Well written.

### Architecture Docs

- `ARCHITECTURE.md` — detailed 3-tier diagram, product architecture, Sprint 8 versioned.
- `API_CONTRACT.md`, `API_CONTRACT_BLOCK_B.md` — API specifications.
- `FEED_ALGORITHM.md` — recommendation engine documentation.
- `DATASET_PIPELINE.md` — data pipeline docs.
- `SCALABILITY.md`, `SECURITY.md` — operational docs.
- `SCRUM.md`, `BACKLOG.md`, `ROADMAP.md` — project management docs.
- `COMMIT_CONVENTION.md`, `CONTRIBUTING.md` — developer docs.

**16 markdown files at root level** — thorough for a solo project.

### Inline Documentation

- Doc comments exist on key classes (`FeedController`, `BootstrapScreen`, `PremiumScreen`) but are sparse on individual methods.
- `AppSpacings` has good doc comments explaining usage.
- Most private widgets have zero doc comments.
- Localization system (`app_strings.dart`, `strings_en.dart`, `strings_es.dart`) provides bilingual support.

---

## 7. Strengths

1. **Clean architecture** — Feature-based folder structure with proper layer separation (data/domain/presentation) is better than 90% of solo Flutter projects.
2. **Comprehensive theme system** — Centralized colors, typography, and spacings with a fully configured MaterialApp theme. Professional-grade visual consistency.
3. **Feature richness** — 20+ distinct features (feed, vault, challenges, philosophy map, packs, premium, onboarding, hidden modes, ambient audio, insights, profile, settings, donations, practice console, share/export, author detail, similar quotes, redeem codes).
4. **Localization** — Full EN/ES bilingual support with a custom string system.
5. **CI/CD maturity** — 14 GitHub Actions workflows covering CI, deployment, security scanning, health checks, release, and documentation.
6. **Backend security** — Helmet, CORS, rate limiting, device-ID authentication, Sentry error tracking, and log redaction.
7. **Monetization architecture** — Clean separation of premium state, purchase service, receipt validation, and soft paywall injection.
8. **Feed algorithm** — Behavioral weighting with pgvector similarity, prefetch/queue system, and directional reordering.

---

## 8. Weaknesses

1. **Near-zero test coverage** — 2 test files with 6 trivial assertions across 28,000+ lines of Dart and 7,500+ lines of JavaScript. This is the single biggest risk.
2. **God files** — `feed_screen.dart` (908 lines) and `premium_screen.dart` (593 lines) pack multiple widget classes into single files, reducing navigability.
3. **Business logic in UI** — `FeedScreen.initState()` orchestrates 6+ async operations. `FeedScreen.build()` has `ref.listen` blocks that handle challenge sync, refinement injection, paywall injection, and rating prompts — all interleaved with UI code.
4. **Dead code** — `_BlockedApp` in main.dart, no-op `redirect` in router.dart.
5. **Naming inconsistency** — `maybeinjectSoftPaywall` (lowercase i), two separate `insight/` vs `insights/` feature folders.
6. **Magic values in UI** — Several screens use raw hex colors (`Color(0xFF1B6B3A)`, `Color(0xFF1A1A2E)`) instead of `AppColors` tokens.
7. **Type-unsafe routing** — `state.extra as Map<String, dynamic>` in router.dart is fragile; a typo in a key silently fails.
8. **No error boundaries** — Empty `catch (_) {}` blocks in feed_screen.dart (lines 100, 126) swallow errors silently.
9. **SharedPreferences sprawl** — Magic string keys (`mindscroll_hint_shown`, `mindscroll_audio_autostart`, etc.) are scattered across multiple files with no centralized key registry.
10. **Backend route bloat** — 18 route files but only 4 services. Business logic likely lives in route handlers rather than testable service classes.

---

## 9. Priority Improvements (Ordered by Impact)

### P0 — Critical (do first)

1. **Add unit tests for FeedController** — Most critical business logic file. Cover swipe counting, streak logic, vault limits, paywall injection, prefetch triggers.
2. **Add unit tests for PremiumController** — Purchase flow, trial expiry, restore logic.
3. **Extract FeedScreen business logic into a FeedOrchestrator** — Move the 6 `ref.listen` blocks out of `build()` into a dedicated class or UseCase layer.

### P1 — High Value

4. **Split feed_screen.dart** — Extract `_LoadingShimmer`, `_ErrorView`, `_FeedLimitView`, `_Header`, `_StatChip`, `_FreeSwipeChip` into `features/feed/widgets/`.
5. **Split premium_screen.dart** — Extract comparison table, hero section, trial banner, price label, etc. into `features/premium/widgets/`.
6. **Create a SharedPreferences key registry** — Centralize all `mindscroll_*` keys in a single `PrefsKeys` class in `core/constants/`.
7. **Resolve insight vs insights duplication** — Audit both folders, merge or rename.
8. **Remove dead code** — Delete `_BlockedApp`, clean up no-op redirect.

### P2 — Medium Value

9. **Add type-safe route extras** — Replace `state.extra as Map<String, dynamic>` with typed data classes.
10. **Consolidate magic colors** — Add `AppColors.trialGreen`, `AppColors.tableBackground`, etc. for the 4-5 raw hex values found in UI code.
11. **Backend service extraction** — Move business logic from route handlers into service classes for testability.
12. **Backend test suite** — Add proper unit tests with mocked Supabase client.
13. **Move `features/swipe/` to `core/swipe/`** — It is a cross-cutting concern, not a feature.

### P3 — Nice to Have

14. **Add doc comments to all public APIs** — Especially controllers and repositories.
15. **Formalize DB migration scripts** — Replace ad-hoc `scripts/` with a migration runner.
16. **Add a golden test suite** — Snapshot tests for key screens (feed, onboarding, premium).

---

## 10. File Count and Structure Summary

| Category | Count | Lines |
|----------|-------|-------|
| Dart source files (`flutter_app/lib/`) | 151 | 28,431 |
| Backend JS source files (`backend/src/`) | 37 | 7,582 |
| CI/CD workflow files (`.github/workflows/`) | 14 | 1,530 |
| Root-level markdown docs | 16 | — |
| Docs folder files (`docs/`) | 7 | — |
| Flutter test files | 2 | 75 |
| Backend test files | 1 | ~200 |
| **Total source files** | **188+** | **~36,000+** |

### Feature Breakdown (Flutter `features/` folder)

| Feature | Files |
|---------|-------|
| feed | 14 (screen, controller, state, prefetch, queue, 9 widgets) |
| onboarding | 6 (screen, controller, 4 widgets) |
| premium | 5 (screen, controller, purchase service, simulated service, redeem) |
| packs | 5 (3 screens, purchase service, paywall card widget) |
| hidden_modes | 10 (4 screens, controller, detector, feed, quiz data, practice, suggestion) |
| swipe | 6 (controller, detector, direction, dispatcher, feedback, gesture handler) |
| ambient | 5 (button, controller, service, sheet, tracks) |
| philosophy_map | 5 (screen, controller, 3 widgets) |
| settings | 2 (screen, controller) |
| profile | 3 (screen, controller, author affinity widget) |
| vault | 2 (screen, controller) |
| challenges | 2 (screen, controller) |
| insights | 2 (screen, controller) |
| insight | 3 (controller, panel, emotional theme) |
| practice | 4 (console screen, detail screen, model, controller) |
| bootstrap | 2 (screen, controller) |
| share_export | 1 (service) |
| authors | 1 (detail screen) |
| donations | 1 (screen) |

### Backend Route Coverage

18 route modules: quotes, vault, likes, stats, profile, swipes, challenges, map, premium, insights, mind-profile, admin, authors, packs, webhooks, analytics, device-lock, insight, exercises.

---

*End of audit.*
