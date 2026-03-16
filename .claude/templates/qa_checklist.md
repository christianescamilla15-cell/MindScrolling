# QA Checklist

## Instructions

Use this checklist for every QA review pass. Not all items apply to every change — mark N/A for items that are not relevant to the current review.

---

## Architecture Consistency

- [ ] Changes respect module ownership boundaries
- [ ] No agent modified another agent's domain without coordination
- [ ] New code follows existing patterns and conventions
- [ ] No circular dependencies introduced

## Backend Contract Consistency

- [ ] API endpoints match API_CONTRACT.md
- [ ] Request/response payloads match documented shapes
- [ ] Error responses follow established format
- [ ] No breaking changes to existing endpoints without versioning
- [ ] Database queries use parameterized inputs (no SQL injection)

## Flutter Integration

- [ ] Flutter calls correct API endpoints
- [ ] Flutter handles API error responses gracefully
- [ ] Navigation works correctly (push/pop/go)
- [ ] Back button returns to expected screen
- [ ] State management updates correctly after API calls
- [ ] No unhandled exceptions in debug console

## Localization Coverage

- [ ] All user-facing strings available in EN
- [ ] All user-facing strings available in ES
- [ ] Language detection works on first launch
- [ ] Language toggle in Settings triggers feed reload
- [ ] Author names display correctly per language
- [ ] No hardcoded English strings in Flutter widgets

## Premium Gating

- [ ] Premium features are gated correctly
- [ ] Free users cannot access premium content
- [ ] Premium plan name: "MindScrolling Inside"
- [ ] Premium price: $4.99 USD
- [ ] Premium state persists across app restarts

## Feed Integrity

- [ ] Feed loads on first launch
- [ ] Feed respects selected language
- [ ] Feed displays quotes with text, author, category
- [ ] Swipe directions register correctly
- [ ] Like/unlike toggles correctly
- [ ] Vault save works
- [ ] Feed prefetches when approaching end of buffer
- [ ] Diversity cap prevents category dominance

## Navigation

- [ ] Feed → Vault → back = returns to Feed
- [ ] Feed → Map → back = returns to Feed
- [ ] Feed → Insights → back = returns to Feed
- [ ] Feed → Settings → back = returns to Feed
- [ ] Onboarding → Feed transition works
- [ ] No black screens on any navigation path

## Ambient Audio

- [ ] Audio plays correctly in background
- [ ] Audio survives app lifecycle (pause/resume)
- [ ] Audio does not play when disabled in settings
- [ ] No audio memory leaks on extended use
- [ ] Audio does not block UI thread
- [ ] Audio assets are reasonably sized (not bloating app)

## Onboarding

- [ ] Onboarding displays on first launch
- [ ] Age range selection works
- [ ] Interest selection tiles render correctly (no blank tiles)
- [ ] Goal selection works
- [ ] Language selector detects device locale
- [ ] Language selection persists after onboarding completes
- [ ] Onboarding navigates to feed on completion
- [ ] Onboarding does not show again after completion
- [ ] Reset onboarding in Settings triggers re-show on restart

## Donations

- [ ] Donation screen accessible from Settings
- [ ] Donation links/buttons function correctly
- [ ] No crashes on donation flow

## Performance

- [ ] No visible jank during swipe transitions
- [ ] Feed loads within acceptable time
- [ ] No excessive network requests
- [ ] No memory warnings in debug console
- [ ] App size is reasonable
- [ ] Supabase queries return within 500ms
- [ ] No N+1 query patterns in backend routes

## Data Integrity

- [ ] EN quotes load from Supabase (not bundled)
- [ ] ES quotes load from Supabase (not bundled)
- [ ] Author names correct per language (Platón not Plato in ES)
- [ ] Categories distribute correctly (no single-category feed)
- [ ] Quote text is not empty or truncated

## Documentation

- [ ] README.md reflects current state
- [ ] API_CONTRACT.md matches implemented endpoints
- [ ] ARCHITECTURE.md reflects current architecture
- [ ] SCRUM.md updated with completed work

---

## Review Result

```
Reviewer: <agent name>
Date: <date>
Review Type: First Pass | Final Validation
Result: PASS | FAIL
Blocking Issues: none | <list>
Non-Blocking Issues: none | <list>
```
