---
name: MindScrolling - Content context
description: Catalog state, distribution data, and curation decisions as of Sprint 7 (2026-03-18)
type: project
---

## Catalog State (post-Sprint 7)

- Total quotes: ~13K+ bilingual (EN + ES)
- Authors: 432 in `authors` table
- Languages: EN and ES (parity goal)

## Pack Distribution (after assign_pack_quotes.sql)

| Pack | EN quotes | ES quotes |
|---|---|---|
| stoicism_deep | 554 | 500 |
| existentialism | 529 | 500 |
| zen_mindfulness | 583 | 500 |
| free (main feed) | remaining | remaining |

## Preview Curation (after curate_preview_quotes.sql)

15 quotes per pack per lang designated as previews (rank 1-15):
- Rank 1-5: shown to Free users (best hooks)
- Rank 6-15: shown to Trial users only
- All 6 combinations verified: 15 total / 5 free / 10 trial

## Author Expansion Queue

35 authors with ≤3 quotes flagged in `data/authors_needs_quotes.json`. These need content expansion before launch. Priority authors TBD by curator audit.

## Known Duplicate Authors

- Cheng Yen (possible duplicate entries)
- Sam Keen (possible duplicate entries)
- Etty Hillesum (possible duplicate entries)

## Bio Quality

22 bios rewritten in Sprint 7 via `scripts/update_author_bios.sql`. Remaining generic bios (estimated 100+) still need audit.

## Curation Principles Established

1. No motivational slogans dressed as philosophy
2. Correct attribution required (flag uncertain quotes)
3. Emotionally resonant — creates a moment of pause
4. No awkward machine-translation artifacts in ES
5. Balance: no current >15% of any pack except where thematically justified

**Why:** Content is the core product. Quality curation directly affects retention and conversion.
**How to apply:** First curation audit should focus on preview quotes (rank 1-5 per pack per lang) — those are the conversion-critical quotes shown to Free users.
