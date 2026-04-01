# Tasks — Interest Selector + Share with Friends

## T1: Update InterestSelector to multi-select (max 3)
- Description: Change from String? to Set<String>, add 2 new options, counter, validation
- Owner Agent: Developer (Flutter)
- Dependencies: none
- Validation: can select 1-3, shows counter, blocks 4th
- Risk: low

## T2: Update OnboardingController to save multi-interests
- Description: Save all selected interests to user_preferences with equal weight
- Owner Agent: Developer (Flutter)
- Dependencies: T1
- Validation: user_preferences has rows for each selected category
- Risk: low

## T3: Update feed algorithm for multi-interest weights
- Description: Distribute affinity weight across selected interests instead of single
- Owner Agent: Developer (Backend)
- Dependencies: T2
- Validation: feed shows balanced mix of selected categories
- Risk: medium

## T4: Add i18n strings (EN + ES)
- Description: Add labels for 2 new interests + share feature strings
- Owner Agent: Developer (Flutter)
- Dependencies: none
- Validation: both languages show correct labels
- Risk: low

## T5: Create shared_quotes DB table + migration
- Description: New migration with shared_quotes table + indexes
- Owner Agent: Developer (Backend)
- Dependencies: none
- Validation: migration runs, table exists
- Risk: low

## T6: Create share API endpoints
- Description: POST /api/shares, GET /api/shares/pending, POST /api/shares/:id/seen
- Owner Agent: Developer (Backend)
- Dependencies: T5
- Validation: can create share, retrieve pending, mark seen
- Risk: medium

## T7: Build ShareWithFriendSheet (Flutter)
- Description: Bottom sheet with friend search + share button
- Owner Agent: Developer (Flutter)
- Dependencies: T6
- Validation: long-press quote -> sheet opens -> search friend -> share
- Risk: medium

## T8: Build SharedQuoteBadge + feed injection
- Description: "Recommended by [name]" badge, inject at top of feed
- Owner Agent: Developer (Flutter)
- Dependencies: T6, T7
- Validation: shared quote appears in receiver's feed with badge
- Risk: medium

## T9: End-to-end test
- Description: Full flow: select 3 interests -> feed reflects them -> share quote -> friend sees it
- Owner Agent: Test Agent
- Dependencies: T1-T8
- Validation: all acceptance criteria pass
- Risk: low
