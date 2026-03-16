---
name: MindScrolling - QA context
description: Known bugs, API contract issues, documentation inconsistencies, and edge cases from QA audits on 2026-03-15
type: project
---

## QA Audit 1 (2026-03-15) — React MVP + API contract

**Critical bugs found in MindScroll_MVP.jsx:**
1. Double setState: setReflections called twice in handleSwipe, increments by 2 per swipe.
2. useState(3) and useState(12) hardcoded — streak and reflections reset to fake values on reload.
3. Card counter shows "16/15" after last swipe.
4. Share button had no onClick handler — silently broken.
5. Streak modulo reads stale value after first increment — off-by-one.

**API contract issues:**
- No GET endpoint for liked quote IDs — like state unrestorable on reload.
- Feed response lacks is_saved / is_liked fields — extra round-trip needed.
- DELETE /vault/:quote_id — type mismatch risk (string path vs integer ID).
- Dual streak calculation (frontend + backend) will diverge.
- No error response contract (no 4xx/5xx shape).
- No rate limiting documented on POST /quotes/:id/like.

---

## QA Audit 2 (2026-03-15) — Full documentation audit

### CRITICAL: Swipe direction conflict across documents

The authoritative mappings differ across files:

| Source | LEFT | RIGHT | UP | DOWN |
|---|---|---|---|---|
| seed.js (line 27) | stoicism | discipline | philosophy | reflection |
| README.md diagram | stoicism | discipline | philosophy | reflection |
| ARCHITECTURE.md section 2 | stoicism | discipline | philosophy | reflection |
| SCRUM.md Sprint 5 table | stoicism | discipline | philosophy | reflection |
| **feed_constants.dart (actual code)** | **reflection** | **discipline** | **stoicism** | **philosophy** |

The Flutter app code (feed_constants.dart) is INVERTED from all documentation for LEFT (stoicism vs reflection) and DOWN/UP (philosophy vs stoicism). This is the highest-severity finding.

### Other critical findings:
- MindScroll_MVP.jsx is listed in .gitignore (line 173) — the MVP source file is excluded from tracking. If this is intentional it should be documented; if not, it's a data-loss risk.
- tags_temp.json is listed in .gitignore (line 171) — also excluded from tracking, exists on disk.
- `frontend/` directory exists on disk (not a legacy directory) — README and ARCHITECTURE only reference `frontend_legacy/`. The active `frontend/` is completely undocumented.
- `cloud/`, `Agent Memory/`, and `Agents/` directories referenced in no docs — confirmed non-existent on disk (not an issue, just confirmed).
- BACKLOG.md is stale: still shows Sprint 0/1/2 as future planning with "decisions to resolve before Sprint 1" — all of these were resolved in Sprints 0–4. Document predates the current Sprint 5 state.
- BACKLOG.md does not reflect Sprint 3, 4, or 5 work at all.

### Medium findings:
- pubspec.yaml font family is "Playfair" — README and ARCHITECTURE say "Playfair Display". Minor inconsistency (family name alias only).
- pubspec.yaml declares 14 dependencies (http, flutter_riverpod, riverpod_annotation, shared_preferences, flutter_secure_storage, uuid, go_router, flutter_card_swiper, share_plus, url_launcher, screenshot, image_gallery_saver, flutter_localizations, intl, shimmer = 15 total). ROADMAP.md Phase 3 claims "14 dependencies" — actual count is 15.
- SCRUM.md Sprint 4 period is "2026-03-15 al 2026-04-18" — same start date as Sprint 3 ("2026-04-05 al 2026-04-18"). Sprint 4 start date is wrong.
- README.md env table lists PREMIUM_BASE_PRICE_USD but .env.example does not include RATE_LIMIT_MAX / RATE_LIMIT_WINDOW_MS — README table omits these two variables that are in .env.example.
- ARCHITECTURE.md scoring formula coefficients sum to 0.75 (0.35+0.15+0.10+0.10+0.05) — missing 0.25. The formula is incomplete or the weights don't sum to 1.0.
- SCRUM.md feed composition: "60%/20%/10%/10%" for batch of 20 = 12/4/2/2 quotes. ARCHITECTURE.md says "12/4/2/2" (consistent numerically) but labels them differently: "dominant/secondary/exploration/special". Minor label discrepancy.
- .gitignore line 29: package-lock.json is ignored — this is non-standard for a Node.js project and will make reproducible installs harder for contributors.
- .gitignore line 173: MindScroll_MVP.jsx ignored — but README.md refers to it as an existing deliverable.
- CONTRIBUTING.md line 28: clone URL is `https://github.com/your-org/mindscrolling.git` — placeholder not replaced.
- ROADMAP.md Phase 2 deliverables list references `frontend/src/components/` — but the structure is now `frontend_legacy/`.
- SCRUM.md Sprint 4 file structure references `frontend/` not `frontend_legacy/`.
- No API_CONTRACT.md file exists — BACKLOG.md S2-05 required it as an acceptance criterion.

**Why:** Full documentation audit of all 9 files on 2026-03-15.
**How to apply:** Reference in future QA passes to track resolution status per finding.
