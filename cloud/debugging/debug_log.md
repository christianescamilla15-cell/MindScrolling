# Debug Log — MindScrolling
**Last updated:** 2026-03-18

> This log tracks all active bugs and architectural blockers.
> Format: ID | Description | Severity | Status | Assigned | First seen | Last updated
> Severity: Critical / High / Medium / Low / Blocker
> Status: Open / In Progress / Resolved / Accepted

---

## Log Format

Each entry uses this structure:

```
### [ID] — [Short description]
**Severity:** [level]
**Status:** [Open / In Progress / Resolved / Accepted]
**Assigned:** [Agent]
**First seen:** [YYYY-MM-DD]
**Last updated:** [YYYY-MM-DD]
**Description:** [Full description of the issue]
**Reproduction steps:** [How to reproduce]
**Resolution:** [What was done to fix, or why it was accepted]
```

---

## Active Blockers (post-Sprint 6 QA)

### B-01 — Real App Store / Google Play receipt validation missing
**Severity:** Critical (Blocker)
**Status:** Open
**Assigned:** DevOps
**First seen:** 2026-03-18
**Last updated:** 2026-03-18
**Description:** The Fastify backend marks `is_premium = true` based on client-reported data from RevenueCat. There is no server-to-server webhook from RevenueCat that verifies the purchase with Apple or Google servers before granting premium. A user who knows the API shape can fake a premium grant request.
**Reproduction steps:** POST to the premium unlock endpoint with a crafted device ID and no actual purchase. Observe that premium may be granted without real payment verification.
**Resolution:** Pending. Unblock condition: Integrate RevenueCat webhook on the Fastify backend. Only grant `is_premium = true` after server-side receipt verification. Test in RevenueCat sandbox.

---

### B-02 — Admin endpoint rate-limit non-persistent + timing-unsafe token comparison
**Severity:** Major (Blocker)
**Status:** Open
**Assigned:** Backend Implementer
**First seen:** 2026-03-18
**Last updated:** 2026-03-18
**Description:** The admin rate-limit uses an in-memory counter that is reset on every server restart. On Railway, servers restart on deploy, which means the rate-limit has zero effect in practice. Additionally, the admin token comparison uses string equality (`===`) which is vulnerable to timing attacks.
**Reproduction steps:** Restart the backend server. Immediately send rate-limited requests to an admin endpoint. Observe that the counter starts from zero and prior requests are not counted.
**Resolution:** Pending. Unblock condition: Replace in-memory counter with a Redis-backed (or database-backed) rate limiter. Replace `===` with `crypto.timingSafeEqual()` for admin token comparison.

---

### B-03 — TOCTOU race condition in trial start
**Severity:** Major (Blocker)
**Status:** Open
**Assigned:** Backend Implementer
**First seen:** 2026-03-18
**Last updated:** 2026-03-18
**Description:** The trial start endpoint checks for an existing trial record, then inserts a new one if none exists. Under concurrent requests (two simultaneous calls from the same device), both can pass the "no existing trial" check before either has committed the insert, resulting in two trial records for the same device.
**Reproduction steps:** Send two simultaneous POST requests to the trial start endpoint from the same device ID. In a race window, both may succeed and create duplicate records.
**Resolution:** Pending. Unblock condition: Add a DB-level UNIQUE constraint on `device_id` in the trials table, or use a PostgreSQL advisory lock (`pg_advisory_xact_lock`) to serialize trial starts per device.

---

### B-04 — Pack preview select missing swipe_dir and is_premium fields
**Severity:** Minor (Blocker)
**Status:** Open
**Assigned:** Backend Implementer
**First seen:** 2026-03-18
**Last updated:** 2026-03-18
**Description:** The Supabase query in the pack preview route handler does not select `swipe_dir` or `is_premium` from the packs table. The Flutter client receives a pack preview object without these fields and falls back to display defaults (category unlabeled, lock state incorrect).
**Reproduction steps:** Call the pack preview endpoint. Inspect the response JSON. `swipe_dir` and `is_premium` fields are absent.
**Resolution:** Pending. Unblock condition: Add both fields to the `.select()` call in the pack preview Supabase query. No schema migration required.

---

## Resolved Issues (post-Sprint 6 QA)

All CRIT/HIGH/MED/LOW application-level bugs from the Sprint 6 QA gate are resolved. See `cloud/debugging/fix_history.md` for the complete fix record.

_No active application bugs as of 2026-03-18._
