---
name: MindScrolling - Experience context
description: Current visual/sensory state, design system references, and planned experience work as of Sprint 7 (2026-03-18)
type: project
---

## Design System

- Colors: `flutter_app/lib/app/theme/colors.dart` (AppColors)
- Typography: `flutter_app/lib/app/theme/typography.dart` (AppTypography)
- Category colors via `AppColors.categoryColor(cat)`:
  - stoicism → gold/amber
  - discipline → blue
  - reflection → purple
  - philosophy → green
  - mindfulness/zen → teal
  - existentialism → deep blue/indigo

## Current Visual State

- Background: dark near-black (AppColors.background)
- Surface: AppColors.surfaceVariant for cards/containers
- Border: AppColors.border (subtle)
- Text: AppColors.textPrimary / textSecondary / textMuted
- App identity: calm, philosophical, premium, minimal

## Screens Implemented

- Feed (main swipe feed with 4-direction swipe)
- Vault (saved quotes)
- Author Detail (bio + top quotes)
- Philosophy Map (category score visualization)
- Daily Challenges
- Packs catalog + Pack Preview + Pack Feed (Sprint 7)
- Premium / Paywall screens
- Onboarding
- Settings

## Swipe-Back Navigation (Sprint 7)

SwipeBackWrapper added to: Vault, Author Detail, Philosophy Map. Left-edge swipe (20dp) + velocity>300px/s or offset>100px → context.pop(). Back button preserved on Premium and RedeemCode screens.

## Planned Experience Work (Bloque E)

- Pack-specific themes (ThemeData/PackTheme per pack)
  - stoicism_deep: austere, dark stone, minimal
  - existentialism: deep blues, muted purples, introspective
  - zen_mindfulness: warm, organic, soft greens
- Ambient audio per pack: 3 loops ~60s MP3 bundled in assets (~4.5 MB extra)
- Pack transition animations (entering pack feed should feel like entering a different world)

**Why:** Bloque E deferred post-launch. Experience audit should focus on current screens before adding new layers.
**How to apply:** First audit should cover: feed card design, paywall/premium screen feel, pack preview screen atmosphere, and onboarding first impression.
