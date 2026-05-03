# Changelog

> Auto-generated on 2026-05-03

## Features

- `50c59de` (web): /packs catalog page — Bloque B MVP (catalog only)
- `0c5dec2` (users): add /users/search + /users/:device_id discovery endpoints
- `1f142c0` (push): server-side Web Push delivery + subscription persistence
- `7caef4d` (web): category landing pages — /categories/[cat] (Fase 3d)
- `ecaedc5` (web): dynamic OG images for quotes + authors — Fase 3c
- `9c54dcc` (web): sitemap + robots + JSON-LD Schema.org — Fase 3b
- `52fb200` (web): SEO landing pages — /quotes/[id] + /authors/[slug] (Fase 3a)
- `9691bd2` (web): Web Push client wiring + Notifications toggle — Fase 2c (2 complete)
- `6f96a7c` (web): social feed + QOTD + streak — Fase 2b
- `b3870d7` (web): Stripe Checkout web flow — Fase 2a
- `887761e` (web): /vault + /map routes — Fase 1d-ii (1d complete)
- `8b7ca1c` (web): /onboarding route + client gate — Fase 1d-i
- `85b6e7f` (web): convert App + 6 components to TSX — Fase 1c-iv (1c complete)
- `a5ec77b` (web): TypeScript api layer — Fase 1c-iii
- `acc6d77` (web): TypeScript constants + i18n + data fixtures — Fase 1c-ii
- `1ba30ce` (web): types module + convert utils to TypeScript — Fase 1c-i
- `d8b5936` (web): refactor 6 overlay components to Tailwind — Fase 1b-iv (1b complete)
- `18aa1ca` (web): refactor QuoteCard + VaultSheet to Tailwind — Fase 1b-iii
- `382b1a9` (web): refactor App shell to Tailwind — Fase 1b-ii
- `d8d024e` (web): design tokens + next/font + global keyframes — Fase 1b-i
- `7d139a6` (web): port frontend/ shell to Next.js — Fase 1a (verbatim copy)
- `a3fabb1` (web): scaffold Next.js 16 webapp — Fase 0 of mobile→web migration
- `25f10b5` (frontend): add React Router v7 + URL-based overlay routing
- `8eb22ee` social feed screen + Android home widget (quote of the day)
- `41d3675` Firebase + FCM push notifications setup
- `6527add` social feed, streak tracking, and quote of the day
- `20507da` add Stripe Payment Links for all 7 products
- `15064c9` Stripe checkout integration + RLS security policies
- `95ce2ee` multi-interest onboarding + share with friends (T2-T8)
- `8596fff` multi-interest selector (3 picks) + share quotes foundation (Kiro FEATURE)

## Bug Fixes

- `2524a7f` (users): drop longest_streak column dependency + surface DB error code
- `4aab1ec` (web): bump low-contrast text + allow zoom for WCAG/Lighthouse a11y
- `1d9f71c` (web): trim NEXT_PUBLIC_SITE_URL to survive Vercel env stdin newlines
- `fa9e035` (web): set metadataBase in root layout — Fase 3 polish
- `2645e5f` (feed): fall back to category queries when RPC retry fails
- `79b4ee0` separate directions (4) from goals (7) in onboarding
- `95a98c0` support multi-interest selection in feed algorithm
- `2ea0e42` add missing AppStringsToastResolver import in feed_screen
- `60db18c` Remove single-device lock — allow multi-device installation

## Refactoring

- `f99ddab` P0 code quality improvements — split god files, add tests, cleanup

## Documentation

- `a0b9c25` (roadmap): reflect 2026-04-19 pivot from Google Play to Next.js webapp
- `e1ce2be` update README with engineering-grade structure
- `e122d44` Play Store listing + ASO optimization guide

## Chores

- `733cedd` ignore AI tooling output + local-only IDE/deploy state
- `2607a95` (cleanup): remove dead frontend scaffolds (legacy + 2 mockups)
- `fc278a2` (security): wire aios + mythos + nemesis stack into MindScrolling
- `8637437` (security): add .gitignore, SECURITY.md and .env.example
- `45a6c37` bump version to 2.0.0+9 for Play Store release

## Other Changes

- `1a93796` security(mythos): delta scan post-feed-fix · no regressions
- `a11c994` security(mythos): first scan of backend · 0 crit, 0 high, 28 medium, 25 info

