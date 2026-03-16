---
name: MindScrolling - Documentation Writer context
description: Documentation debt, known inconsistencies, Sprint 5 docs to update, canonical sources of truth
type: project
---

## Documentation Debt (as of 2026-03-15 audit)

### CRITICAL
- Swipe direction conflict: seed.js/README/ARCHITECTURE say UP=philosophy, but **feed_constants.dart says UP=stoicism**. Dart code is ground truth. All docs need updating to match: UP=stoicism, RIGHT=discipline, LEFT=reflection, DOWN=philosophy.
- API_CONTRACT.md was missing entirely (may have been created in Sprint 5 — verify).

### HIGH
- `frontend/` directory exists on disk but is undocumented everywhere (README + ARCHITECTURE only mention `frontend_legacy/`)
- BACKLOG.md is stale — still shows Sprint 0/1/2 as future planning; Sprints 3/4/5 not reflected
- ARCHITECTURE.md scoring formula weights sum to 0.75, not 1.0 (formula incomplete)

### MEDIUM
- CONTRIBUTING.md clone URL is still placeholder: `https://github.com/your-org/mindscrolling.git`
- SCRUM.md Sprint 4 start date is wrong (same as Sprint 3)

### LOW
- ROADMAP.md references `frontend/src/components/` (should be `frontend_legacy/`)

## Sprint 5 Documentation Tasks

After Sprint 5 closes, documentation-writer must update:
1. SCRUM.md — Sprint 5 entry with all completed stories
2. BACKLOG.md — Mark Sprint 5 stories complete, add Sprint 6 backlog
3. API_CONTRACT.md — Add `/insights/weekly` endpoint spec
4. ARCHITECTURE.md — Add AI feed section (Voyage AI, pgvector, EMA vectors, dual-mode)
5. FEED_ALGORITHM.md — Verify in sync with actual implementation in quotes.js
6. README.md — Update swipe direction table + add AI feed section

## Canonical Sources of Truth

| Topic | Authoritative Source |
|---|---|
| Swipe directions | feed_constants.dart (UP=stoicism, RIGHT=discipline, LEFT=reflection, DOWN=philosophy) |
| API contracts | API_CONTRACT.md |
| Feed algorithm | FEED_ALGORITHM.md + quotes.js |
| DB schema | migrations 001→002→003→004 |

**Why:** Full documentation audit on 2026-03-15 revealed multiple conflicts.
**How to apply:** Start any doc update by checking this list for known debt.
