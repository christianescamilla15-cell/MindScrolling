# Fix History — MindScrolling
**Last updated:** 2026-03-18

All fixes applied during the Sprint 6 QA gate correction session.

---

| Fix ID | Description | Severity | Agent | Build | Status |
|--------|-------------|----------|-------|-------|--------|
| CRIT-01 | Challenge completion was enforced client-side only. Moved 8-swipe check to server-side in `challenges.js`. A client could previously mark a challenge complete with fewer than 8 swipes by calling the endpoint directly. | Critical | Backend Implementer | Build #1 | Resolved |
| CRIT-02 | Vault 20-quote limit was enforced client-side only. Added server-side count check before insert in `vault.js`. Free-tier users could bypass the limit by calling the vault endpoint directly. | Critical | Backend Implementer | Build #1 | Resolved |
| CRIT-03 | Premium gate was enforced client-side only. Added `is_premium` check in backend route handlers for premium-gated features (packs, unlimited vault, export image). | Critical | Backend Implementer | Build #1 | Resolved |
| HIGH-01 | Philosophy Map returned wrong field names (snake_case vs camelCase mismatch). Flutter client received zero-values on all radar chart axes despite valid swipe history. Fixed field name mapping in `map.js` route. | High | Backend Implementer | Build #1 | Resolved |
| HIGH-02 | Weekly insight cache was keyed by device ID only. Switching app language from ES to EN served the cached Spanish insight. Cache key now includes `lang` parameter. | High | Backend Implementer | Build #1 | Resolved |
| HIGH-03 | Feed category distribution was skewed for new users. A missing weight normalization step allowed a single high-affinity category to dominate the first fetch. Added category balance enforcement in feed query. | High | Backend Implementer | Build #1 | Resolved |
| HIGH-04 | 433 author bios were missing from the database. Added 433 EN + 433 ES bios across all tracked authors via `backend/src/routes/authors.js` and data file. | High | Data Engineer | Build #1 | Resolved |
| HIGH-05 | Trial start silently failed for first-time users under an edge case where the device had no prior profile record. Added profile upsert before trial insert. | High | Backend Implementer | Build #1 | Resolved |
| MED-01 | Haptic feedback was firing on UP, RIGHT, LEFT swipe directions but not DOWN. Fixed haptic trigger in the swipe controller's DOWN direction handler in Flutter. | Medium | Flutter Mobile Engineer | Build #1 | Resolved |
| MED-02 | Notification toggle state reset to ON after every app restart. Toggle value was being read from a non-persisted in-memory provider on startup instead of from SharedPreferences. Fixed initialization in the notifications provider. | Medium | Flutter Mobile Engineer | Build #1 | Resolved |
| MED-03 | Packs Explorer screen rendered blank pack cards due to field name mismatch between the Supabase query response and the Flutter PackModel. Fixed field name binding in `PackModel.fromJson()`. | Medium | Flutter Mobile Engineer | Build #1 | Resolved |
| MED-04 | Author bio retry logic was absent. On first-fetch failure the bio screen displayed an empty card permanently. Added retry-on-error in the author bio remote datasource with exponential backoff (max 2 retries). | Medium | Flutter Mobile Engineer | Build #1 | Resolved |
| MED-05 | Challenge completion was firing multiple times if the user continued swiping after the 8th swipe. Added a `completed` guard in the challenge progress handler to prevent re-triggering. | Medium | Backend Implementer | Build #1 | Resolved |
| LOW-01 | Streak milestone card (7-day, 30-day) was reappearing on every app launch after being dismissed. Dismissal state was not being written to SharedPreferences. Fixed by persisting `milestone_seen_{n}` key on dismiss. | Low | Flutter Mobile Engineer | Build #1 | Resolved |
| LOW-02 | Vault export was incorrectly gated behind premium. The `.txt` export was intended as a free feature (per BACKLOG.md S7-18) but a copy-paste error in the export route added a premium check. Removed the premium gate from `.txt` export. | Low | Backend Implementer | Build #1 | Resolved |
| DOCS-01 | ARCHITECTURE.md scoring formula weights summed to 0.75, not 1.0. Fixed weight values in the scoring section to sum to 1.0. | Low | Documentation Writer | Build #1 | Resolved |
| I18N-01 | Weekly insight language was not updating after a language switch due to a stale cache. Resolved by HIGH-02 (cache keyed by lang). | Low | Backend Implementer | Build #1 | Resolved |
