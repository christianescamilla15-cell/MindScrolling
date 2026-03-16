---
name: MindScrolling - QA context
description: Known bugs, edge cases, and API contract issues identified in the first QA pass (2026-03-15)
type: project
---

First QA review conducted on 2026-03-15 against MindScroll_MVP.jsx and the proposed backend API contract.

**Critical bugs found in current React MVP:**
1. Double setState bug in handleSwipe: setReflections is called twice (once flat, once in functional updater), causing reflections to increment by 2 per swipe instead of 1. Streak logic also reads stale `r` — the inner functional updater receives the value AFTER the first increment, making the modulo check off-by-one.
2. streak and reflections are hardcoded to 3 and 12 at initialization (useState(3), useState(12)) — not real data, no localStorage persistence. These reset to fake values on every page load.
3. `current` counter grows unbounded. At current > Number.MAX_SAFE_INTEGER (theoretical) it would break, but in practice the modulo `current % deck.length` wraps correctly. Not a blocker but the counter display `current + 1 / deck.length` will eventually show wrong progress once current exceeds deck.length.
4. The card counter shows `{current + 1} / {deck.length}` — after swiping all 15 cards, current = 15 and display shows "16 / 15", which is confusing UX.
5. Share button has no handler — onClick is missing entirely. Renders silently broken for users.
6. handleTap (double-tap like) and the like button in the action bar BOTH call onLike(quote.id). A single click on the like button always fires handleTap first (onClick on parent), then e.stopPropagation() on the button — this works correctly because stopPropagation prevents double trigger, but it's fragile and worth documenting.

**API contract issues:**
- POST /quotes/:id/like accepts { action: "like"|"unlike" } but the frontend toggle logic infers state from local Set — the backend receives the intended final action, which is correct. However, there is no GET endpoint to retrieve liked quote IDs on app load, making it impossible to restore like state after the page refresh once localStorage is implemented.
- POST /vault and GET /vault are separate from GET /quotes/feed — but the feed response does not include a `is_saved` or `is_liked` field, so on fresh load the frontend cannot know which cards from the feed are already liked/saved without a second round-trip.
- DELETE /vault/:quote_id — quote_id in path as string, but quote IDs in the current data are integers. Type mismatch risk between JS number and URL string param if not coerced in backend.
- GET /stats streak logic is backend-computed, but frontend also computes streak locally (every 5 reflections). These two sources will diverge immediately unless the frontend stops computing streak and defers entirely to /stats.
- No error response contract defined for any endpoint (no 4xx/5xx shape).
- No rate limiting or abuse protection documented on POST /quotes/:id/like.

**Why:** These issues were found during MVP + localStorage + multilanguage readiness review.
**How to apply:** Reference this in future QA passes to track which issues were fixed vs still open.
