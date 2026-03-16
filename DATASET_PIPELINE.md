# MindScrolling — Dataset Pipeline Documentation

## Overview

This document describes the complete quote dataset pipeline for MindScrolling: how quotes are sourced, cleaned, classified, scored, and imported into Supabase.

---

## 1. Dataset Sources

### 1.1 Hand-Curated Core (`data/quotes_core.json`)

**300 quotes** hand-selected and verified for attribution accuracy. This is the foundation of the dataset — premium editorial content covering four categories.

### 1.2 HuggingFace Datasets (pipeline-augmented)

| Dataset | URL | Records (raw) | Notes |
|---|---|---|---|
| `Abirate/english_quotes` | https://huggingface.co/datasets/Abirate/english_quotes | ~2,500 | Generic English quotes, keyword-tagged |
| `m-ric/english_historical_quotes` | https://huggingface.co/datasets/m-ric/english_historical_quotes | ~3,000 | Historical figures, better attribution |
| `datastax/philosopher-quotes` | https://huggingface.co/datasets/datastax/philosopher-quotes | ~1,800 | Philosophical focus, pre-categorised |

### 1.3 Previous Data (Quotable.io seed)

The original Supabase seed came from **Quotable.io**, a generic quotes API. Quality issues with that data:

- Mixed content: sports, humor, film, motivational — not philosophically curated
- Keyword-only categorization with no quality scoring
- Many misattributions (especially "Einstein", "Lincoln", "Churchill" quotes)
- Short filler quotes (under 30 chars) mixed with long run-on text
- No premium / pack differentiation
- No language verification

The pipeline replaces this with a verified, scored, tiered dataset.

---

## 2. Current State of the Data

After running the pipeline, the cleaned dataset contains:

| Category | Count | Free | Premium |
|---|---|---|---|
| stoicism | 80 | varies | varies |
| philosophy | 80 | varies | varies |
| discipline | 70 | varies | varies |
| reflection | 70 | varies | varies |
| **Total** | **300** | **~120** | **~180** |

These come entirely from `data/quotes_core.json` (hand-curated). When the HuggingFace pipeline runs successfully, the cleaned output in `data/cleaned_quotes.json` will include additional automatically-processed quotes on top of these 300.

---

## 3. Pipeline Steps

```
HuggingFace datasets
       │
       ▼
[1] Download & parse
       │
       ▼
[2] Normalize (unicode, whitespace, quote marks, author names)
       │
       ▼
[3] Validate (length, author, language, spam)
       │
       ▼
[4] Deduplicate (exact + 80-char normalized key)
       │
       ▼
[5] Classify (keyword scoring → stoicism/philosophy/discipline/reflection)
       │
       ▼
[6] Quality score (0.00–1.00 weighted formula)
       │
       ▼
[7] Premium split (top 40% by score = premium)
       │
       ▼
[8] Pack assignment (category + keyword overrides)
       │
       ▼
[9] Export → cleaned_quotes.json + cleaned_quotes.csv + seed_quotes.sql
```

The script also merges `data/quotes_core.json` (hand-curated quotes carry their own pre-assigned metadata and are not re-scored).

---

## 4. Classification Rules

Classification uses keyword frequency scoring. The category with the highest keyword hit count wins. Ties default to `philosophy`.

### Stoicism keywords
`virtue, wisdom, acceptance, endure, tranquil, fate, marcus, seneca, epictetus, inner, soul, resilience, adversity, courage, character, patience, bear, strength, will, stoic, aurelius, zeno, chrysippus, indifferent, judgement, externals, control, obstacle, duty, reason, equanimity, fortitude, steadfast, rational, meditate, temper, provoke, hardship`

### Philosophy keywords
`truth, knowledge, existence, reality, consciousness, wonder, meaning, purpose, plato, aristotle, socrates, kant, nietzsche, camus, sartre, hegel, reason, logic, being, metaphysics, epistemology, ethics, ontology, dialectic, absolute, sublime, ideal, form, essence, absurd, freedom, authentic, phenomenon, critique, wittgenstein, heidegger, spinoza, leibniz, descartes, empiricism, rationalism, perception, mind, infinite, eternal, universal, particular, substance`

### Discipline keywords
`effort, practice, habit, achieve, goal, persist, consistency, action, focus, determination, excellence, improve, self-mastery, self-control, dedication, work, diligence, ambition, persevere, industrious, productive, commit, labor, craft, master, skill, train, prepare, deliberate, repeat, success, failure, rise, overcome, tenacity, discipline, routine, structure, execute`

### Reflection keywords
`life, love, happiness, peace, joy, gratitude, heart, smile, laugh, friend, family, moment, journey, emotion, compassion, forgive, heal, time, memory, beauty, wonder, nature, silence, solitude, dream, hope, sorrow, grief, loss, accept, change, impermanent, gentle, kind, tender, care, listen, observe, grow, age, death, birth, renewal, season`

---

## 5. Quality Scoring Model

Scores are on a 0.00–1.00 scale. The formula:

| Component | Weight | Condition |
|---|---|---|
| Base score | +0.50 | Always |
| Credible author | +0.20 | Author is in the ~100-name curated list |
| Optimal length | +0.10 | Text is 50–280 characters |
| Keyword density | +0.10 | Text contains ≥2 classification keywords |
| Complete sentence | +0.05 | Text ends with `.`, `!`, or `?` |
| Spam penalty | −0.20 | Contains URL, hashtag, `!!`, social handle, or sales language |

**Maximum possible score:** 0.95 (via formula; hand-curated quotes may be set to 0.96–0.98)

**Score ranges in practice:**
- `0.85–0.98` — Famous philosophers / widely-cited thinkers (hand-curated)
- `0.75–0.85` — Notable thinkers, lesser-known but credible
- `0.60–0.74` — Credible pipeline quotes without bonus conditions
- `< 0.60` — Likely filtered out or downranked

---

## 6. Premium Split Logic

For pipeline-processed (non-curated) quotes:
- Sort all quotes descending by `quality_score`
- Top **40%** → `is_premium = true`
- Remaining **60%** → `is_premium = false`, `pack_name = "free"`

For hand-curated quotes (`quotes_core.json`):
- First 120 quotes in the file (highest editorial quality, broadly accessible) → `is_premium = false`
- Remaining 180 → `is_premium = true`

---

## 7. Pack Assignment Strategy

Pack names group thematically related quotes for potential in-app purchase bundles.

| Pack | Assigned when |
|---|---|
| `stoicism_pack` | `category = stoicism` AND `is_premium = true` |
| `existential_pack` | `category = philosophy` AND text contains nietzsche/camus/sartre/absurd/existential/authentic/condemned/meaningless/anguish |
| `philosophy_pack` | `category = philosophy` AND `is_premium = true` (non-existential) |
| `discipline_pack` | `category = discipline` AND `is_premium = true` |
| `life_reflections_pack` | `category = reflection` AND `is_premium = true` |
| `mindfulness_pack` | Any category, if text contains: mindful, breath, present moment, awareness, meditat, stillness, witness — overrides all other packs |
| `free` | `is_premium = false` (overrides all pack assignments) |

The `mindfulness_pack` override has highest priority. Free-tier quotes always get `pack_name = "free"` regardless of category.

---

## 8. How to Run the Pipeline

### Prerequisites

```bash
pip install datasets pandas tqdm
```

### First run

```bash
cd /path/to/MindScrolling
python scripts/prepare_quotes_dataset.py
```

### Force re-run (overwrite existing output)

```bash
python scripts/prepare_quotes_dataset.py --force
```

### Dry run (no file writes, just see stats)

```bash
python scripts/prepare_quotes_dataset.py --dry-run
```

### Output files

| File | Description |
|---|---|
| `data/cleaned_quotes.json` | All processed quotes as JSON array |
| `data/cleaned_quotes.csv` | Same data as CSV (pipe-delimited tags) |
| `data/seed_quotes.sql` | SQL INSERT statements ready for Supabase |

The pipeline is **resume-safe**: if output files already exist, it will skip regeneration unless `--force` is passed.

---

## 9. How to Import into Supabase

### Option A — SQL Editor (recommended for initial seed)

1. Open your Supabase project
2. Go to **SQL Editor**
3. Open `data/seed_quotes.sql`
4. Review the `TRUNCATE` line at the top — uncomment it only if you want to clear existing data
5. Click **Run**
6. Verify with the `SELECT` at the bottom of the file

### Option B — Supabase CLI

```bash
supabase db push --db-url "postgresql://..." < data/seed_quotes.sql
```

### Option C — psql

```bash
psql "$DATABASE_URL" < data/seed_quotes.sql
```

### Verification query

After importing, run this in the SQL Editor to confirm counts:

```sql
SELECT category,
       COUNT(*) AS count,
       COUNT(*) FILTER (WHERE is_premium = false) AS free_count,
       COUNT(*) FILTER (WHERE is_premium = true)  AS premium_count
FROM quotes
GROUP BY category
ORDER BY category;
```

Expected result (core seed only):

| category | count | free_count | premium_count |
|---|---|---|---|
| discipline | 70 | varies | varies |
| philosophy | 80 | varies | varies |
| reflection | 70 | varies | varies |
| stoicism | 80 | varies | varies |

---

## 10. Statistics

### Hand-curated core dataset (`quotes_core.json`)

**2 quotes removed** during attribution audit (1 Marcus Aurelius with anachronistic "chips are down" idiom, 1 Aristotle misattribution). 2 authors corrected (Socrates → Plutarch, Socrates → Eleanor Roosevelt).

| Metric | Value |
|---|---|
| Total quotes (after audit) | 298 |
| Stoicism | 79 |
| Philosophy | 79 |
| Discipline | 70 |
| Reflection | 70 |
| Free tier | 108 |
| Premium tier | 190 |
| Quality score range | 0.82–0.98 |
| Authors represented | ~80 |
| Languages | English only |

### Primary authors by category

**Stoicism:** Marcus Aurelius, Seneca, Epictetus, Zeno of Citium, Chrysippus, Cleanthes, Epicurus, Heraclitus

**Philosophy:** Plato, Aristotle, Socrates, Kant, Nietzsche, Camus, Sartre, Descartes, Spinoza, Pascal, Russell, Wittgenstein, Hegel, Einstein

**Discipline:** Confucius, Lao Tzu, Benjamin Franklin, Thoreau, Emerson, Goethe, Bruce Lee, Churchill, Roosevelt, Edison, Mandela

**Reflection:** Rumi, Viktor Frankl, Carl Jung, Gandhi, Maya Angelou, Dostoevsky, Oscar Wilde, Kierkegaard, Hugo, Tolstoy

### HuggingFace pipeline (approximate, depends on dataset availability)

| Stage | Records |
|---|---|
| Raw downloaded | ~7,300 |
| After validation | ~5,800 |
| After deduplication | ~4,200 |
| Final (with curated merged) | ~4,500 |

Exact numbers vary by run and dataset availability. Run with `--dry-run` to see stats without writing files.

---

## 11. Swipe Direction Reference

| Category | Swipe direction | Rationale |
|---|---|---|
| stoicism | up | Uplifting, rising above circumstances |
| discipline | right | Moving forward, taking action |
| reflection | left | Looking inward, stepping back |
| philosophy | down | Going deep, descending into thought |

---

## 12. Schema Reference

```sql
CREATE TABLE quotes (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  text       TEXT NOT NULL,
  author     VARCHAR(150) NOT NULL,
  category   VARCHAR(50) NOT NULL CHECK (category IN ('stoicism','philosophy','discipline','reflection')),
  lang       CHAR(2) NOT NULL DEFAULT 'en',
  swipe_dir  VARCHAR(10) NOT NULL CHECK (swipe_dir IN ('left','right','up','down')),
  pack_name  VARCHAR(50) NOT NULL DEFAULT 'free',
  is_premium BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);
```

Note: `quality_score`, `source`, and `tags` fields from the JSON are pipeline-only metadata. They are not stored in Supabase (not in the schema). They are used during processing to determine `is_premium` and `pack_name` before export.
