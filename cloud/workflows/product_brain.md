# AI Product Brain — MindScrolling
**Last updated:** 2026-03-18

The Product Brain is the prioritization and decision framework used to decide what to build next. It converts the current product state into a ranked list of actions, using a consistent scoring model that prevents scope creep and keeps the product focused on what matters most at each stage.

---

## Prioritization Model

Every candidate feature or fix is scored on 6 dimensions:

```
Priority Score = (User Impact + Retention + Revenue + Strategic Fit) - (Technical Risk + Complexity)
```

### Dimension definitions

| Dimension | What it measures | Scale |
|-----------|-----------------|-------|
| User Impact | How many users are affected. A bug affecting all users scores higher than one affecting 5% of users. | 0–3 |
| Retention | Does this keep users coming back daily? (Streak, challenge, notifications score high. UI polish scores low.) | 0–3 |
| Revenue | Does this unblock or directly improve monetization? | 0–3 |
| Strategic Fit | Does this align with MindScrolling's core identity: anti-doom-scrolling, philosophical depth, no-account, no-ads? | 0–2 |
| Technical Risk | How likely is this to introduce bugs, regressions, or architectural debt? | 0–3 (subtract) |
| Complexity | How long does this take? High complexity = lower score because opportunity cost is high. | 0–3 (subtract) |

Maximum possible score: 11. Minimum: -6. Typical release-blocking fix: 8–10. Typical polish item: 2–4.

---

## MindScrolling Priority Order

When scores are tied or the model is ambiguous, apply this fixed priority order:

1. **Stability** — If the app crashes, is unresponsive, or has a data loss bug, nothing else matters.
2. **Localization** — MindScrolling's primary markets include LATAM (ES). A broken Spanish experience cuts the accessible user base in half.
3. **Core habit loop** — Feed → Swipe → Streak → Daily Challenge. If any part of this loop is broken, retention collapses.
4. **Premium** — Revenue is existential. If the premium gate is broken or receipt validation is absent, the business cannot function.
5. **Growth** — Notifications, share, streak milestones. These drive organic growth and re-engagement.
6. **Features** — Content packs, author bios, export, map snapshots. These add depth but do not fix the foundation.

This order is not negotiable for any sprint where the Build Quality Score is below 90.

---

## Output Format

When the Product Brain produces a prioritization, the output must follow this format:

```
## Product Brain Output — [date]

### Current state summary
- Score: [N]/100
- Open blockers: [list]
- QA level: [highest passing level]

### Ranked candidates

| Rank | Item | User Impact | Retention | Revenue | Strategic Fit | Risk | Complexity | Score | Recommendation |
|------|------|-------------|-----------|---------|--------------|------|------------|-------|---------------|
| 1 | [item] | [0-3] | [0-3] | [0-3] | [0-2] | [0-3] | [0-3] | [total] | DO NOW |
| 2 | [item] | ... | ... | ... | ... | ... | ... | ... | DO NEXT |
| ... | | | | | | | | | |

### Sprint recommendation
[1–2 sentence summary of what the next sprint should focus on, based on this ranking]
```

---

## Special Rules

### Rule 1: Never recommend new features when score < 85
If the Build Quality Score is below 85, the Product Brain must not recommend new feature development. All capacity goes to stabilization, blocker resolution, and score improvement.

### Rule 2: Never recommend a feature that breaks the core identity
MindScrolling is: no accounts, no ads, no social, philosophical depth, anti-addiction. Any recommendation that introduces user accounts, social comparison, engagement gamification (streaks as manipulation, not acknowledgment), or advertising is automatically deprioritized to rank last.

### Rule 3: ES content parity is a baseline, not a feature
Any recommendation that creates a gap between EN and ES content quality is rejected. ES is not a "nice to have" — it is a primary market. EN-only features must include ES support or be blocked.

### Rule 4: Revenue before polish
A P0 monetization fix (B-01 receipt validation) always outranks a P2 UI polish item, regardless of how small the P0 fix appears to be.

### Rule 5: Validate with BACKLOG.md
Every recommendation must be traceable to an item in BACKLOG.md. If the candidate is not in BACKLOG.md, add it before recommending it. The backlog is the canonical list of approved work items.

---

## Current Product State (as of 2026-03-18)

- Score: 82/100 (Stable, not Release Ready)
- Phase: Sprint 7 — Google Play Launch Hardening
- Open blockers: B-01 (Critical), B-02 (Major), B-03 (Major), B-04 (Minor)
- Highest QA level: Integration QA (PASS)
- Pending: Release QA, production deployment, RevenueCat sandbox test

**Product Brain recommendation for Sprint 7:**
Resolve B-01, B-02, B-03 first. These are the only items that move the score to >= 90 and unblock Release QA. No new features until the score crosses 90 and Release QA completes.
