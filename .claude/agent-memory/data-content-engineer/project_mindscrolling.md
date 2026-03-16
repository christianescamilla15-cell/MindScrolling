---
name: MindScrolling - Data/Content Engineer context
description: Dataset state, quality pipeline, known attribution corrections, pack structure, and pending deployment tasks
type: project
---

## Current Dataset State (2026-03-16)

| Metric | Value |
|---|---|
| Curated quotes (quotes_core.json) | 298 |
| Distribution | stoicism=79, philosophy=79, discipline=70, reflection=70 |
| Premium | 190 (63.8%) |
| Free | 108 (36.2%) |
| Avg quality score | 0.93 |

## Known Attribution Corrections (applied)

- Index 250: "chips are down" phrase — removed (anachronistic idiom, impossible for Marcus Aurelius)
- Index 85: "It is during our darkest moments..." — removed (not authentic Aristotle)
- Index 77: "Education is the kindling of a flame..." — corrected from Socrates → Plutarch
- Index 264: "Strong minds discuss ideas..." — corrected from Socrates → Eleanor Roosevelt
- Final count dropped from 300 → 298 after audit

## Pipeline Files

- `scripts/prepare_quotes_dataset.py` — Full ETL (download → normalize → validate → classify → score → export)
- `data/quotes_core.json` — 298 curated quotes (source of truth)
- `data/seed_quotes.sql` — SQL INSERT file for Supabase

## HuggingFace Sources Configured

- `Abirate/english_quotes`
- `m-ric/english_historical_quotes`
- `datastax/philosopher-quotes`

## Deployment Checklist

- ✅ quotes_core.json created and audited
- ✅ seed_quotes.sql generated
- ✅ prepare_quotes_dataset.py pipeline written
- ❌ seed_quotes.sql NOT yet imported into Supabase
- ❌ embed_quotes.js NOT yet run (requires 004_ai_feed.sql migration first)

## Reject Criteria

The pipeline rejects: quotes < 20 chars or > 500 chars, quotes without authors, non-English text, spam patterns (buy, click, amazing, secret, hack), duplicates (80-char normalized key).

**Why:** Full dataset audit and pipeline build during Sprint 5.
**How to apply:** Reference before adding quotes or running pipeline to understand current state.
