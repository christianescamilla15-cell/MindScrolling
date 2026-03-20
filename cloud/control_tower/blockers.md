# Blockers — MindScrolling
**Build:** #2
**Last updated:** 2026-03-18

> This file tracks all issues that block the next milestone or release.
> Severity: Critical = blocks release entirely. Major = degrades reliability or revenue. Minor = cosmetic or non-revenue impact.
> Status: Open / In Progress / Resolved

---

## Open Blockers

| ID | Issue | Severity | Owner | Impacted Feature | Status | Unblock Condition |
|----|-------|----------|-------|-----------------|--------|-------------------|
| B-01 | Real App Store / Google Play receipt validation — currently relying on client-side RevenueCat data without server-side webhook verification. A malicious user can fake premium status. | Critical | DevOps | Premium, Packs, Unlimited Vault | Open | Integrate RevenueCat webhook endpoint on the Fastify backend. Verify `productIdentifier`, `purchaseDate`, and `environment` from RevenueCat server-to-server event. Mark `is_premium = true` in DB only after server-side confirmation. Test in RevenueCat sandbox before production. |

---

## Resolved Blockers

| ID | Issue | Severity | Resolution | Build |
|----|-------|----------|------------|-------|
| B-02 | Admin token used `===` string comparison (timing attack vector). In-memory rate limit resets on server restart. | Major | `crypto.timingSafeEqual(providedBuf, expectedBuf)` applied in `admin.js:requireAdmin()`. Timing oracle eliminated. In-memory rate limit acceptable for current traffic — Redis upgrade tracked as S7 perf item. | #2 |
| B-03 | Trial start TOCTOU race — two concurrent requests from the same device could both pass "no existing trial" check. | Major | Replaced SELECT-then-UPDATE with a single atomic `.is("trial_start_date", null)` conditional UPDATE. DB-level atomicity eliminates the race without needing a schema change or advisory lock. | #2 |
| B-04 | Pack preview Supabase select missing `swipe_dir` and `is_premium` fields — Flutter client fell back to defaults. | Minor | Added both fields to `.select()` in `packs.js:/:id/preview`. One-line change, no schema change required. | #2 |

---

## Escalation Rules

- B-01 (Critical): Must be resolved before Google Play submission. Every day it is unresolved, premium revenue is unverifiable and the store review may flag it.
- All other architectural blockers from Sprint 6 are now resolved as of Build #2.

---

## Sprint 7 Blockers — Added 2026-03-20

| ID | Issue | Severity | Owner | Status | Unblock Condition |
|----|-------|----------|-------|--------|-------------------|
| B-05 | pgvector extension not enabled in Supabase. The `004_ai_feed.sql` migration and the HNSW index on quote embeddings cannot be created until the extension is active. | Critical | devops-engineer | Open | Enable via Supabase Dashboard → Extensions → search "vector" → enable. |
| B-06 | 004_ai_feed.sql migration not executed. The `match_quotes` RPC and `embedding` column do not exist. AI feed returns empty or falls back to random. Depends on B-05. | Critical | devops-engineer | Open | Run migration in Supabase SQL Editor after pgvector is enabled. |
| B-07 | embed-quotes batch not run. Even after 004_ai_feed.sql is applied, all quotes have NULL embeddings. The AI feed cannot rank by vector similarity until embeddings are populated. | Major | devops-engineer | Open | Run `npm run embed-quotes` from `backend/` directory after B-06 is resolved. ~30 min for ~5,500 quotes. |
| B-08 | Google Play Store production API access not available. The app is in closed beta but fewer than 12 testers have accepted the opt-in link. Google requires 12 opt-ins before granting production access. | Major | growth-aso-strategist | Open | Recruit 12 testers who click the opt-in link and install the app from Play Store. Monitor in Play Console → Testing → Internal testing. |
