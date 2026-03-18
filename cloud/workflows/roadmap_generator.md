# Roadmap Generator — MindScrolling
**Last updated:** 2026-03-18

This document defines how to generate a 4–8 week product roadmap from the current product state. The roadmap generator is used at sprint close and when a new milestone is reached.

---

## Core Strategy Rules

1. **One milestone per roadmap block.** Each week has a single, named milestone outcome. Not a list of tasks — an outcome. "Backend deployed to Railway production" is a milestone. "Work on backend stuff" is not.
2. **Earlier weeks are more detailed.** Weeks 1–2 should have specific tasks and acceptance criteria. Weeks 5–8 should have directional goals only — details are filled in at planning time.
3. **Never show a feature week before a stability week if score < 90.** The roadmap must reflect the actual product state, not the aspirational one.
4. **Revenue milestones must have a verification step.** "Premium working" is not a milestone. "RevenueCat sandbox test PASS, first real purchase confirmed" is.
5. **Every roadmap must include a date for the next Control Tower review.** The roadmap is not static — it is reviewed and updated at each sprint close.

---

## MindScrolling-Specific Focus Areas

When generating the roadmap, weight these areas in order:

| Priority | Area | Why |
|----------|------|-----|
| P0 | Stability + Blocker Resolution | Cannot ship with B-01..B-04 open |
| P0 | Production Deployment | Railway backend is the actual product; localhost is not |
| P0 | Google Play Launch | Primary revenue channel |
| P1 | Retention Loop | Daily challenge, notifications, streak milestones |
| P1 | iOS App Store | Second revenue channel; LATAM iOS is meaningful |
| P1 | Analytics | Blind production ops is not acceptable post-launch |
| P2 | Content Depth | Packs, author deep-dives, Stoicism Deep Dive |
| P2 | Growth Features | Widget, vault collections, sharing |
| P3 | Scale | Feed performance, pgvector, embedding index |

---

## Week-by-Week Structure Template

```
## [Date Range] Roadmap — [Generated on: YYYY-MM-DD]
**Score at generation:** [N]/100
**Open blockers:** [B-0N, ...]
**Current QA level:** [highest passing]

---

### Week 1: [Milestone Name]
**Outcome:** [One sentence — what is true at the end of this week that wasn't before]
**Primary task(s):**
- [Task with owner and acceptance criterion]
- [Task with owner and acceptance criterion]
**QA gate:** [Micro / Feature / Integration / Release]
**Success signal:** [How we know this week succeeded]

### Week 2: [Milestone Name]
**Outcome:** [One sentence]
**Primary task(s):**
- [Task with owner]
**QA gate:** [level]
**Success signal:** [signal]

### Week 3: [Milestone Name]
**Outcome:** [One sentence — directional]
**Primary focus:** [Area]

### Week 4: [Milestone Name]
**Outcome:** [One sentence — directional]
**Primary focus:** [Area]

### Weeks 5–8: [Directional Goal]
**Direction:** [Area + expected milestone]
[These are filled in at sprint close for weeks 3–4]

---

**Next roadmap review:** [YYYY-MM-DD — typically at next sprint close]
```

---

## Current Roadmap (2026-03-18 to 2026-05-13)

**Score at generation:** 82/100
**Open blockers:** B-01 (Critical), B-02 (Major), B-03 (Major), B-04 (Minor)
**Current QA level:** Integration QA — PASS

---

### Week 1 (2026-03-18 – 2026-03-25): Production Ready + Blockers Resolved
**Outcome:** Backend on Railway, B-02 and B-03 resolved, B-01 in progress.
**Primary task(s):**
- Deploy backend to Railway production — DevOps (S7-04). Accept: `/health` returns 200 on Railway URL.
- Resolve B-02: Redis rate-limit + timingSafeEqual — Backend Implementer. Accept: admin endpoint returns 429 after N requests; token comparison uses crypto.timingSafeEqual.
- Resolve B-03: UNIQUE constraint or advisory lock on trial start — Backend Implementer. Accept: 100 concurrent trial-start requests for same device ID produce exactly 1 trial record.
**QA gate:** Integration QA (after B-02/B-03 changes)
**Success signal:** Production backend live; B-02 and B-03 show "Resolved" in blockers.md.

### Week 2 (2026-03-25 – 2026-04-01): RevenueCat Integration + Release QA
**Outcome:** B-01 resolved; RevenueCat sandbox test PASS; Release QA complete; score >= 90.
**Primary task(s):**
- Resolve B-01: RevenueCat webhook endpoint on Fastify — DevOps + Backend Implementer (S7-07). Accept: sandbox purchase triggers webhook, `is_premium = true` set server-side.
- Crash-free baseline on 3 physical Android devices — Flutter Mobile Engineer (S7-09). Accept: 30 min normal usage, 0 crashes on Samsung Galaxy A, Pixel, and one other.
- Run Release QA — QA Agent. Accept: all Release QA checks PASS.
**QA gate:** Release QA
**Success signal:** score_history.md shows >= 90; release_status.md shows READY.

### Week 3 (2026-04-01 – 2026-04-08): Google Play Submission + Post-Launch Analytics
**Outcome:** App submitted to Google Play; error logging and conversion analytics active.
**Primary focus:** DevOps (Play submission S7-06), Backend Implementer (Sentry S7-13, analytics events S7-15)

### Week 4 (2026-04-08 – 2026-04-15): Retention Loop Hardening
**Outcome:** Daily push notifications live; Philosophy Map weekly snapshot notification active; onboarding funnel tracked.
**Primary focus:** Flutter Mobile Engineer + Backend Implementer (S7-11, S7-12, S7-16)

### Weeks 5–6 (2026-04-15 – 2026-04-29): Content Depth Sprint
**Direction:** Stoicism Deep Dive pack (S8-06), content pack browser UI (S8-10), author deep-dive cards (S8-11). Target: first premium content pack live in production.

### Weeks 7–8 (2026-04-29 – 2026-05-13): iOS Launch + Price Optimization
**Direction:** iOS App Store submission (S8-14), price localization audit (S7-17), evaluation of $4.99 → $6.99 post-packs (S8-12).

---

**Next roadmap review:** 2026-04-01 (after Week 2 milestone — Release QA outcome)
