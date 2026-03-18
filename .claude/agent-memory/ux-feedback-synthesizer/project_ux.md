---
name: MindScrolling - UX Research context
description: Current UX state, known friction points, and research baseline as of Sprint 7 (2026-03-18)
type: project
---

## UX Baseline (post-Sprint 7)

### Core Loop
- 4-direction swipe feed: UP=stoicism, RIGHT=discipline, LEFT=reflection, DOWN=philosophy
- Reflection card every 5 real swipes, auto-dismiss 4s, vertical swipe to dismiss
- 20 swipes/day limit (client-side) — no visual countdown yet
- Vault: saved quotes, swipe-back navigation (left edge)

### Onboarding
- Fields collected: age_range, interest, goal, preferred_language
- Status: implemented, conversion rate unknown (no analytics yet)

### Pack Experience (new Sprint 7)
- Pack catalog → preview (5 or 15 quotes) → paywall ($2.99 or $4.99) or feed
- Paywall shows both CTAs: pack price + Inside price
- Soft paywall injected at swipe 100 during trial (non-blocking card)

### Known UX Decisions Made
- Swipe-back replaces X/back buttons on: Vault, Author Detail, Philosophy Map
- Back button preserved on: Premium screen, RedeemCode (avoid accidental exit during purchase)
- Reflection card: does NOT count toward 20-swipe limit (fixed Sprint 7)
- Pack navigation: entitled users go directly to feed (no double-hop fixed Sprint 7)

### Known Friction Points (from QA Sprint 7)
- Trial 1,000-quote limit not yet enforced — users may not know their trial status clearly
- No visual indicator of daily swipe count remaining
- Rating prompt: not yet implemented

### Research Status
- Human tester batch: pending (testers receiving build soon)
- Play Store reviews: N/A (not yet launched)
- Analytics baseline: none yet (pre-launch)

**Why:** UX research phase begins with first tester batch. Synthesizer activates once feedback flows in.
**How to apply:** First report should synthesize onboarding and core loop feedback from testers. Second focus: pack experience UX (new in Sprint 7, untested by users).
