---
name: MindScrolling - Flutter Mobile Engineer context
description: Flutter app architecture, Sprint 5 scope, design system, known issues, and integration points with backend
type: project
---

## App Architecture

State management: Riverpod 2.x with `@riverpod` annotations
Navigation: GoRouter
HTTP: ApiClient in `core/network/` (auto-injects X-Device-ID)
Storage: shared_preferences (general) + flutter_secure_storage (device ID)

## Features Implemented (as of Sprint 5)

- Feed screen with flutter_card_swiper (swipe up/right/left/down)
- Vault screen (saved quotes)
- Philosophy Map screen (radar chart by category)
- Daily challenges screen
- Onboarding flow (3 screens)
- Settings (language toggle EN/ES)
- Profile screen (stats)
- Premium screen (RevenueCat stub + comparison table)
- Donations screen (url_launcher)

## Pending: Insights Screen

`GET /insights/weekly` endpoint exists but the Flutter `features/insights/` screen has not been implemented yet. Needs: weekly AI insight card UI, loading/empty/error states, integration with ApiClient.

## Canonical Swipe Directions (NEVER CHANGE)

```dart
static const Map<String, String> directionToCategory = {
  swipeUp:    'stoicism',    // ↑
  swipeRight: 'discipline',  // →
  swipeLeft:  'reflection',  // ←
  swipeDown:  'philosophy',  // ↓
};
```

## Design System

- Background: #14141E
- Card: #1C1C28
- stoicism: #C9A84C (gold)
- discipline: #4CAF7D (green)
- reflection: #7B9FE0 (blue)
- philosophy: #B97FD1 (purple)
- Fonts: Playfair Display (quotes) + DM Sans (UI)

## API Integration Points

Feed uses `algorithm` field in response to know if it's "hybrid" or "behavioural" mode. Backend now returns this field from `GET /quotes/feed`. Flutter should display differently or log this for analytics.

## Known Issues

- Swipe direction mapping conflict documented: feed_constants.dart (code) was INVERTED vs old seed.js/docs. feed_constants.dart values are the ground truth — docs have been corrected.
- pubspec.yaml font family declared as "Playfair" (not "Playfair Display") — functionally the same but worth noting.

**Why:** Full Flutter architecture review during Sprint 5 agent system build.
**How to apply:** Reference when implementing new screens or debugging integration issues.
