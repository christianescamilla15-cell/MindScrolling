# Changelog

> Auto-generated on 2026-04-02

## Features

- `8eb22ee` social feed screen + Android home widget (quote of the day)
- `41d3675` Firebase + FCM push notifications setup
- `6527add` social feed, streak tracking, and quote of the day
- `20507da` add Stripe Payment Links for all 7 products
- `15064c9` Stripe checkout integration + RLS security policies
- `95ce2ee` multi-interest onboarding + share with friends (T2-T8)
- `8596fff` multi-interest selector (3 picks) + share quotes foundation (Kiro FEATURE)
- `57364ee` add 50 Rust exercises + fix exercise DB schema
- `9348ebb` 1,250 programming exercises across 13 languages
- `f25f8ff` programming exercises system — backend + Flutter + DB schema
- `ae57e6c` complete ES quote generation — 4,265+ hidden mode quotes total
- `e3f24d4` 2,265 EN quotes + 250 ES quotes for hidden modes + variable quiz
- `e519986` variable quiz pool (100 questions) + hidden mode content seed
- `c8b56aa` triple-buffer feed + prefetch fixes + dev mode in release
- `e4898f7` 8-step feature tour — premium onboarding overlay
- `9b6b704` 8 personalization features — semantic matching across full app
- `b30f032` hybrid semantic matching for Insight + idempotent migration v2
- `34bc1fc` Phase 8 — Coding hidden mode with practice console
- `ec6d8ae` Phase 7 — Science hidden mode with 4 branches

## Bug Fixes

- `79b4ee0` separate directions (4) from goals (7) in onboarding
- `95a98c0` support multi-interest selection in feed algorithm
- `2ea0e42` add missing AppStringsToastResolver import in feed_screen
- `60db18c` Remove single-device lock — allow multi-device installation
- `a7f9633` hidden mode feeds now query is_hidden_mode=true directly
- `1b5b861` 7 fixes from hard test audit (2 CRIT + 5 HIGH)
- `78ba0f1` dev panel works in release builds — remove kDebugMode guard on override
- `d75a21d` add hintCount to ExerciseModel placeholder in router
- `b56e80e` UX audit — autocorrect, hint gate, nav, quiz close, localization
- `0840332` 3 CRIT + 4 HIGH from feed stress test audit
- `d1650c2` regression HIGH-02 kDebugMode guard + MED-01 onboarding localization
- `463516d` 4 CRITICAL exercise controller bugs — API contract alignment
- `94af8cd` (security): 3 HIGH exercise vulnerabilities + RC production guard
- `83a1d6a` correct SQL syntax in Java/PHP/C# exercise files
- `d3a1ecd` resolve 10 pending items — security + UX + localization
- `50fdf6c` (security): 2 CRITICAL purchase flow fixes + rate limits
- `75b2b8c` data model round-trip bugs + localization fallback
- `23cb38a` 3 CRITICAL tour bugs — flag timing, exception handling, back button
- `bf7bb50` CRIT swipe_dir mapping + insight scope bug
- `17603a3` resolve all pending audit items — security, UX, algorithm
- `972a56a` resolve 4 CRITICAL + 3 HIGH from stress test audit
- `b53a6d4` API contract gaps — icons, preview fields, generated_at
- `bcfca64` algorithm audit — fix match_quotes RPC + real preference affinity
- `46f199b` (security): resolve 2 CRITICAL + 3 HIGH + 2 MEDIUM from deep audit
- `f5a66fa` resolve 3 CRITICAL + 5 HIGH + 4 MEDIUM from QA audit
- `71107dd` (security): resolve 3 HIGH + 4 MEDIUM from security audit

## Refactoring

- `f99ddab` P0 code quality improvements — split god files, add tests, cleanup

## Documentation

- `e1ce2be` update README with engineering-grade structure
- `e122d44` Play Store listing + ASO optimization guide
- `fc6c4a1` add PENDING_HUMAN_TASKS for post-expansion deployment

## Chores

- `45a6c37` bump version to 2.0.0+9 for Play Store release

