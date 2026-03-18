# Release Status — MindScrolling
**Build:** #1
**Last updated:** 2026-03-18

---

## Current Status

```
BLOCKED — NOT READY FOR RELEASE
```

---

## Why this build cannot be released

### Reason 1: Score below threshold
- Current score: 82/100
- Required score: 90/100
- Gap: 8 points
- The score cannot reach 90 without resolving B-01..B-04 and completing Release QA.

### Reason 2: B-01 — Critical blocker unresolved
- Real App Store / Google Play receipt validation is not implemented.
- Premium purchases are not confirmed server-side.
- Releasing without this means revenue is unverifiable and premium status can be spoofed.
- This is the single most important technical fix before launch.

### Reason 3: B-02 — Admin endpoint security
- Admin rate-limiter does not survive server restarts (in-memory only).
- Admin token comparison is vulnerable to timing attacks.
- Not acceptable in a production environment exposed to the internet.

### Reason 4: B-03 — Trial race condition
- Concurrent trial-start requests can insert duplicate trial records.
- Under any load, this produces corrupted premium state.
- Must be fixed with a DB-level constraint or advisory lock.

### Reason 5: Release QA not completed
- Release QA requires production backend deployment (Railway — S7-04).
- Release QA requires RevenueCat + Play Billing sandbox test (S7-07).
- Release QA requires crash-free baseline on 3 physical Android devices (S7-09).
- Release QA requires trial expiry UX test (S7-10).
- None of these have been run yet.

---

## What remains before release

| Item | Owner | Priority |
|------|-------|----------|
| Resolve B-01 (RevenueCat webhook) | DevOps | P0 |
| Resolve B-02 (admin rate-limit + timing-safe) | Backend Implementer | P0 |
| Resolve B-03 (TOCTOU trial race) | Backend Implementer | P0 |
| Resolve B-04 (pack preview fields) | Backend Implementer | P1 |
| Deploy backend to Railway production (S7-04) | DevOps | P0 |
| Validate RevenueCat + Play Billing sandbox (S7-07) | Backend Implementer | P0 |
| Restore purchases flow Android (S7-08) | Flutter Mobile Engineer | P0 |
| Crash-free baseline on 3 Android devices (S7-09) | Flutter Mobile Engineer | P0 |
| Trial expiry UX test (S7-10) | QA Agent | P0 |
| Run Release QA end-to-end | QA Agent | P0 |
| Google Play Store submission (S7-06) | DevOps | P0 |

---

## Go/No-Go Rule

Release is approved ONLY when ALL of the following are simultaneously true:

1. Build Quality Score >= 90/100
2. Zero Critical open blockers
3. Zero Major open blockers (or all explicitly accepted with documented risk)
4. Release QA: PASS
5. Crash-free baseline collected on at least 3 physical Android devices
6. B-01 (receipt validation) confirmed working in RevenueCat sandbox
7. Google Play store submission checklist complete

This decision is owned jointly by: Documentation Writer (score + docs), QA Agent (QA levels), Product Owner (business go/no-go).
