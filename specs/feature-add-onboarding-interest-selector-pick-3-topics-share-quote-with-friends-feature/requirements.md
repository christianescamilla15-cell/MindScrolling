# Feature — Onboarding Interest Selector (3 picks) + Share with Friends

## Objective
1. Enhance onboarding: let users pick UP TO 3 interests (currently only 1)
2. Add 2 new interest options beyond the existing 5
3. Add "Share with a friend" feature: share a quote to another MindScrolling user

## Requirements (EARS Format)

### Ubiquitous
- The system SHALL allow users to select between 1 and 3 interests during onboarding
- The system SHALL display 7 interest options (5 existing + 2 new)
- The system SHALL support both English and Spanish for all new UI

### Event-Driven
- WHEN a user selects a 4th interest, the system SHALL show "Maximum 3 selected"
- WHEN a user shares a quote with a friend, the system SHALL create a shared_quotes record
- WHEN a user opens their feed with pending shared quotes, the system SHALL show them with "Recommended by [friend]" badge

### State-Driven
- WHILE the user has fewer than 1 interest selected, the system SHALL disable the Continue button
- WHILE there are unread shared quotes, the system SHALL show a notification badge

### Unwanted Behavior
- IF the friend doesn't have MindScrolling installed, THEN the system SHALL show "Your friend needs MindScrolling to receive this"
- IF the share fails, THEN the system SHALL show an error and allow retry

## Non-Functional Requirements
- Onboarding selector: smooth animation on selection
- Share: delivery within 5 seconds
- Bilingual: ES + EN for all new strings

## Acceptance Criteria
- [ ] InterestSelector supports multi-select (1-3)
- [ ] 7 options visible (5 existing + 2 new)
- [ ] Selected interests saved to user_preferences with weights
- [ ] Feed algorithm uses multi-interest weights
- [ ] Share button on quote card sends to friend's feed
- [ ] Shared quote appears with "Recommended by [name]" badge
- [ ] All new strings in EN + ES

## Out of Scope
- Push notifications for shared quotes
- Share to non-MindScrolling users (keep existing external share for that)
