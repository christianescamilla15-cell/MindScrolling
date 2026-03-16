#!/usr/bin/env python3
"""
MindScrolling — Philosophical Quotes Dataset Pipeline
======================================================
Downloads quotes from HuggingFace datasets, normalizes, deduplicates,
classifies, scores, and exports to JSON / CSV / SQL.

Usage:
    python scripts/prepare_quotes_dataset.py
    python scripts/prepare_quotes_dataset.py --force   # overwrite existing output
    python scripts/prepare_quotes_dataset.py --dry-run # no file writes

Requirements:
    pip install datasets pandas tqdm
"""

import argparse
import csv
import json
import os
import re
import sys
import unicodedata
from pathlib import Path

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
REPO_ROOT = Path(__file__).resolve().parent.parent
DATA_DIR = REPO_ROOT / "data"
DATA_DIR.mkdir(parents=True, exist_ok=True)

OUT_JSON = DATA_DIR / "cleaned_quotes.json"
OUT_CSV  = DATA_DIR / "cleaned_quotes.csv"
OUT_SQL  = DATA_DIR / "seed_quotes.sql"

# ---------------------------------------------------------------------------
# HuggingFace dataset configs
# ---------------------------------------------------------------------------
HF_DATASETS = [
    {
        "id": "Abirate/english_quotes",
        "split": "train",
        "text_col": "quote",
        "author_col": "author",
        "tag_col": "tags",
    },
    {
        "id": "m-ric/english_historical_quotes",
        "split": "train",
        "text_col": "quote",
        "author_col": "author",
        "tag_col": None,
    },
    {
        "id": "datastax/philosopher-quotes",
        "split": "train",
        "text_col": "quote",
        "author_col": "author",
        "tag_col": "category",
    },
]

# ---------------------------------------------------------------------------
# Classification keyword tables
# ---------------------------------------------------------------------------
KEYWORDS = {
    "stoicism": [
        "virtue", "wisdom", "acceptance", "endure", "tranquil", "fate",
        "marcus", "seneca", "epictetus", "inner", "soul", "resilience",
        "adversity", "courage", "character", "patience", "bear", "strength",
        "will", "stoic", "aurelius", "zeno", "chrysippus", "indifferent",
        "judgement", "externals", "control", "obstacle", "duty", "reason",
        "equanimity", "fortitude", "steadfast", "rational", "empire",
        "meditate", "temper", "provoke", "hardship",
    ],
    "philosophy": [
        "truth", "knowledge", "existence", "reality", "consciousness",
        "wonder", "meaning", "purpose", "plato", "aristotle", "socrates",
        "kant", "nietzsche", "camus", "sartre", "hegel", "reason", "logic",
        "being", "metaphysics", "epistemology", "ethics", "ontology",
        "dialectic", "absolute", "sublime", "ideal", "form", "essence",
        "absurd", "freedom", "authentic", "phenomenon", "critique",
        "wittgenstein", "heidegger", "spinoza", "leibniz", "descartes",
        "empiricism", "rationalism", "perception", "mind", "infinite",
        "eternal", "universal", "particular", "substance",
    ],
    "discipline": [
        "effort", "practice", "habit", "achieve", "goal", "persist",
        "consistency", "action", "focus", "determination", "excellence",
        "improve", "self-mastery", "self-control", "dedication", "work",
        "diligence", "ambition", "persevere", "industrious", "productive",
        "commit", "labor", "craft", "master", "skill", "train",
        "prepare", "deliberate", "repeat", "success", "failure", "rise",
        "overcome", "tenacity", "discipline", "routine", "structure",
        "execute", "hardwork", "grind", "push",
    ],
    "reflection": [
        "life", "love", "happiness", "peace", "joy", "gratitude", "heart",
        "smile", "laugh", "friend", "family", "moment", "journey", "emotion",
        "compassion", "forgive", "heal", "time", "memory", "beauty",
        "wonder", "nature", "silence", "solitude", "dream", "hope",
        "sorrow", "grief", "loss", "accept", "change", "impermanent",
        "gentle", "kind", "tender", "care", "listen", "observe",
        "grow", "age", "death", "birth", "renewal", "season",
    ],
}

# ---------------------------------------------------------------------------
# Mindfulness override keywords
# ---------------------------------------------------------------------------
MINDFULNESS_KEYWORDS = [
    "mindful", "breath", "present moment", "awareness", "meditat",
    "stillness", "observe", "witness", "now",
]

# ---------------------------------------------------------------------------
# Existential pack override keywords
# ---------------------------------------------------------------------------
EXISTENTIAL_KEYWORDS = [
    "nietzsche", "camus", "sartre", "absurd", "existential", "nausea",
    "freedom", "authentic", "condemned", "meaningless", "abyss",
    "anguish", "facticity", "transcendence",
]

# ---------------------------------------------------------------------------
# Curated credible authors (≈100) — +0.20 quality bonus
# ---------------------------------------------------------------------------
CREDIBLE_AUTHORS = {
    # Stoics
    "marcus aurelius", "seneca", "epictetus", "zeno of citium", "zeno",
    "chrysippus", "cleanthes", "cato", "marcus tullius cicero", "cicero",
    # Classical philosophers
    "plato", "aristotle", "socrates", "heraclitus", "thales",
    "anaximander", "pythagoras", "democritus", "parmenides", "xenophanes",
    # Modern philosophers
    "immanuel kant", "kant", "georg wilhelm friedrich hegel", "hegel",
    "friedrich nietzsche", "nietzsche", "arthur schopenhauer", "schopenhauer",
    "rene descartes", "descartes", "baruch spinoza", "spinoza",
    "gottfried leibniz", "leibniz", "david hume", "hume",
    "john locke", "locke", "francis bacon", "bacon",
    "blaise pascal", "pascal", "voltaire", "jean-paul sartre", "sartre",
    "albert camus", "camus", "simone de beauvoir", "de beauvoir",
    "martin heidegger", "heidegger", "edmund husserl", "husserl",
    "ludwig wittgenstein", "wittgenstein", "bertrand russell", "russell",
    "william james", "james", "john dewey", "dewey",
    "ralph waldo emerson", "emerson", "henry david thoreau", "thoreau",
    # Eastern / world philosophers
    "confucius", "lao tzu", "laozi", "zhuangzi", "sun tzu",
    "buddha", "siddhartha gautama", "nagarjuna",
    "al-ghazali", "ibn rushd", "averroes", "avicenna",
    # Existentialists / phenomenologists
    "soren kierkegaard", "kierkegaard", "karl jaspers", "jaspers",
    "merleau-ponty", "paul ricoeur", "ricoeur",
    # Literary / philosophical writers
    "fyodor dostoevsky", "dostoevsky", "leo tolstoy", "tolstoy",
    "michel de montaigne", "montaigne", "blaise pascal",
    "viktor frankl", "frankl", "rainer maria rilke", "rilke",
    "kahlil gibran", "gibran", "virginia woolf", "woolf",
    "anton chekhov", "chekhov", "marcel proust", "proust",
    "albert einstein", "einstein", "carl jung", "jung",
    "sigmund freud", "freud", "alan watts", "watts",
    "joseph campbell", "campbell",
    # Enlightenment / early modern
    "thomas jefferson", "benjamin franklin", "franklin",
    "john stuart mill", "mill", "jeremy bentham", "bentham",
    "mary wollstonecraft", "wollstonecraft",
    "friedrich schiller", "schiller", "goethe",
    # Contemporary credible
    "hannah arendt", "arendt", "simone weil", "weil",
    "albert schweitzer", "schweitzer",
}

# ---------------------------------------------------------------------------
# Spam / garbage patterns
# ---------------------------------------------------------------------------
SPAM_PATTERNS = [
    re.compile(r"https?://", re.I),          # URLs
    re.compile(r"#\w+"),                      # hashtags
    re.compile(r"!{2,}"),                     # multiple exclamation marks
    re.compile(r"\b(subscribe|follow|like|share|click|buy|sale|discount)\b", re.I),
    re.compile(r"@\w+"),                      # social media mentions
    re.compile(r"\d{4,}"),                    # long numbers (phone/id spam)
]

# ---------------------------------------------------------------------------
# Swipe direction map
# ---------------------------------------------------------------------------
SWIPE_DIR = {
    "stoicism":   "up",
    "discipline": "right",
    "reflection": "left",
    "philosophy": "down",
}

# ---------------------------------------------------------------------------
# Pack assignment
# ---------------------------------------------------------------------------
def assign_pack(category: str, text_lower: str, is_premium: bool) -> str:
    # Mindfulness override (highest priority)
    for kw in MINDFULNESS_KEYWORDS:
        if kw in text_lower:
            return "mindfulness_pack"

    # Category-based assignment
    if category == "stoicism":
        pack = "stoicism_pack"
    elif category == "philosophy":
        # Check existential sub-pack
        for kw in EXISTENTIAL_KEYWORDS:
            if kw in text_lower:
                return "existential_pack"
        pack = "philosophy_pack"
    elif category == "discipline":
        pack = "discipline_pack"
    else:  # reflection
        pack = "life_reflections_pack"

    # Free-tier override
    if not is_premium:
        return "free"

    return pack

# ---------------------------------------------------------------------------
# Quality scoring
# ---------------------------------------------------------------------------
def quality_score(text: str, author: str) -> float:
    score = 0.50
    text_stripped = text.strip()
    author_lower = author.lower().strip()

    # +0.20 credible author
    if author_lower in CREDIBLE_AUTHORS:
        score += 0.20

    # +0.10 optimal length
    if 50 <= len(text_stripped) <= 280:
        score += 0.10

    # +0.10 keyword density (≥2 classification keywords)
    all_kw = [kw for kws in KEYWORDS.values() for kw in kws]
    text_lower = text_stripped.lower()
    hit_count = sum(1 for kw in all_kw if kw in text_lower)
    if hit_count >= 2:
        score += 0.10

    # +0.05 ends with complete sentence
    if text_stripped.endswith((".", "!", "?")):
        score += 0.05

    # -0.20 spam
    for pat in SPAM_PATTERNS:
        if pat.search(text_stripped):
            score -= 0.20
            break

    return round(min(max(score, 0.0), 1.0), 2)

# ---------------------------------------------------------------------------
# Classification
# ---------------------------------------------------------------------------
def classify(text: str) -> str:
    text_lower = text.lower()
    scores = {cat: 0 for cat in KEYWORDS}
    for cat, kws in KEYWORDS.items():
        for kw in kws:
            if kw in text_lower:
                scores[cat] += 1
    # Return highest-scoring category; default to philosophy
    best = max(scores, key=lambda c: scores[c])
    if scores[best] == 0:
        return "philosophy"
    return best

# ---------------------------------------------------------------------------
# Language detection (simple heuristic)
# ---------------------------------------------------------------------------
def is_english(text: str) -> bool:
    """Reject if >30% of characters are non-ASCII."""
    if not text:
        return False
    non_ascii = sum(1 for c in text if ord(c) > 127)
    return (non_ascii / len(text)) <= 0.30

# ---------------------------------------------------------------------------
# Normalisation helpers
# ---------------------------------------------------------------------------
def normalize_text(text: str) -> str:
    """Strip, collapse whitespace, normalize unicode quotes."""
    text = unicodedata.normalize("NFKC", text)
    text = re.sub(r"[\u2018\u2019]", "'", text)
    text = re.sub(r"[\u201c\u201d]", '"', text)
    text = re.sub(r"\s+", " ", text).strip()
    # Remove enclosing quotation marks if present
    if (text.startswith('"') and text.endswith('"')) or \
       (text.startswith("'") and text.endswith("'")):
        text = text[1:-1].strip()
    return text

def normalize_author(author: str) -> str:
    if not author:
        return ""
    author = unicodedata.normalize("NFKC", author)
    author = re.sub(r"\s+", " ", author).strip()
    # Remove trailing parenthetical (birth/death years etc.)
    author = re.sub(r"\s*\(.*?\)\s*$", "", author).strip()
    return author

def dedup_key(text: str) -> str:
    """Normalised key using first 80 chars (lowercased, alphanumeric only)."""
    cleaned = re.sub(r"[^a-z0-9]", "", text.lower())
    return cleaned[:80]

# ---------------------------------------------------------------------------
# Validation
# ---------------------------------------------------------------------------
def is_valid(text: str, author: str) -> tuple[bool, str]:
    if not text or len(text) < 20:
        return False, "too short"
    if len(text) > 500:
        return False, "too long"
    if not author or len(author.strip()) < 2:
        return False, "missing author"
    if not is_english(text):
        return False, "non-english"
    for pat in SPAM_PATTERNS:
        if pat.search(text):
            return False, "spam pattern"
    return True, "ok"

# ---------------------------------------------------------------------------
# Load one HuggingFace dataset
# ---------------------------------------------------------------------------
def load_hf_dataset(cfg: dict) -> list[dict]:
    try:
        from datasets import load_dataset  # type: ignore
    except ImportError:
        print("  [WARN] 'datasets' package not installed. Run: pip install datasets")
        return []

    print(f"  Downloading {cfg['id']} ...")
    try:
        ds = load_dataset(cfg["id"], split=cfg["split"], trust_remote_code=True)
    except Exception as exc:
        print(f"  [WARN] Could not load {cfg['id']}: {exc}")
        return []

    records = []
    for row in ds:
        text   = normalize_text(str(row.get(cfg["text_col"])   or ""))
        author = normalize_author(str(row.get(cfg["author_col"]) or ""))
        tags   = []
        if cfg["tag_col"] and cfg["tag_col"] in row:
            raw_tags = row[cfg["tag_col"]]
            if isinstance(raw_tags, list):
                tags = [str(t) for t in raw_tags]
            elif isinstance(raw_tags, str):
                tags = [raw_tags]
        records.append({"text": text, "author": author, "tags": tags, "source_dataset": cfg["id"]})

    print(f"    → {len(records)} raw records loaded.")
    return records

# ---------------------------------------------------------------------------
# Full pipeline
# ---------------------------------------------------------------------------
def run_pipeline(force: bool = False, dry_run: bool = False) -> None:
    print("=" * 60)
    print("MindScrolling — Quotes Dataset Pipeline")
    print("=" * 60)

    # Resume-safety check
    if not force and OUT_JSON.exists():
        print(f"\n[INFO] Output files already exist. Pass --force to regenerate.")
        print(f"  {OUT_JSON}")
        print(f"  {OUT_CSV}")
        print(f"  {OUT_SQL}")
        return

    # ------------------------------------------------------------------
    # 1. Download from HuggingFace
    # ------------------------------------------------------------------
    print("\n[STEP 1] Downloading datasets from HuggingFace...")
    all_raw: list[dict] = []
    for cfg in HF_DATASETS:
        records = load_hf_dataset(cfg)
        all_raw.extend(records)
    print(f"\n  Total raw records: {len(all_raw)}")

    # If no HF data (e.g., package missing), we continue with empty to still
    # process and export the seed from quotes_core.json if it exists.
    core_path = DATA_DIR / "quotes_core.json"
    if core_path.exists():
        print(f"\n  Loading hand-curated quotes from {core_path} ...")
        with open(core_path, encoding="utf-8") as f:
            core_data = json.load(f)
        for entry in core_data:
            all_raw.append({
                "text":           normalize_text(entry.get("text", "")),
                "author":         normalize_author(entry.get("author", "")),
                "tags":           entry.get("tags", []),
                "source_dataset": "quotes_core",
                "_core_override": entry,  # carry full curated metadata
            })
        print(f"  → {len(core_data)} curated quotes added.")

    # ------------------------------------------------------------------
    # 2. Normalize & validate
    # ------------------------------------------------------------------
    print("\n[STEP 2] Normalizing and validating records...")
    valid_records: list[dict] = []
    stats_invalid = {"too short": 0, "too long": 0, "missing author": 0,
                     "non-english": 0, "spam pattern": 0}

    for raw in all_raw:
        text   = raw["text"]
        author = raw["author"]

        ok, reason = is_valid(text, author)
        if not ok:
            stats_invalid[reason] = stats_invalid.get(reason, 0) + 1
            continue
        valid_records.append(raw)

    print(f"  Valid: {len(valid_records)}  |  Rejected: {sum(stats_invalid.values())}")
    for reason, count in stats_invalid.items():
        if count:
            print(f"    - {reason}: {count}")

    # ------------------------------------------------------------------
    # 3. Deduplicate
    # ------------------------------------------------------------------
    print("\n[STEP 3] Deduplicating...")
    seen_keys: set[str] = set()
    deduped: list[dict] = []

    for rec in valid_records:
        key = dedup_key(rec["text"])
        if key in seen_keys:
            continue
        seen_keys.add(key)
        deduped.append(rec)

    print(f"  After dedup: {len(deduped)}  (removed {len(valid_records) - len(deduped)} duplicates)")

    # ------------------------------------------------------------------
    # 4. Classify, score, assign packs
    # ------------------------------------------------------------------
    print("\n[STEP 4] Classifying, scoring, assigning packs...")
    processed: list[dict] = []

    for rec in deduped:
        text   = rec["text"]
        author = rec["author"]

        # If this came from the hand-curated core, trust its metadata
        if "_core_override" in rec:
            core = rec["_core_override"]
            category  = core.get("category", classify(text))
            qs        = float(core.get("quality_score", quality_score(text, author)))
            is_prem   = bool(core.get("is_premium", False))
            pack      = core.get("pack_name", assign_pack(category, text.lower(), is_prem))
            swipe     = core.get("swipe_dir", SWIPE_DIR.get(category, "down"))
            source    = core.get("source", "")
            tags      = core.get("tags", [])
        else:
            category  = classify(text)
            qs        = quality_score(text, author)
            is_prem   = None  # assigned after sorting
            pack      = None
            swipe     = SWIPE_DIR.get(category, "down")
            source    = rec.get("source_dataset", "")
            tags      = rec.get("tags", [])

        processed.append({
            "text":           text,
            "author":         author,
            "source":         source,
            "category":       category,
            "tags":           tags,
            "lang":           "en",
            "quality_score":  qs,
            "is_premium":     is_prem,
            "pack_name":      pack,
            "swipe_dir":      swipe,
        })

    # ------------------------------------------------------------------
    # 5. Assign is_premium for non-curated records (top 40% = premium)
    # ------------------------------------------------------------------
    print("\n[STEP 5] Assigning premium tiers...")
    non_curated = [r for r in processed if r["is_premium"] is None]
    non_curated.sort(key=lambda r: r["quality_score"], reverse=True)
    cutoff = int(len(non_curated) * 0.40)
    for i, rec in enumerate(non_curated):
        rec["is_premium"] = (i < cutoff)
        rec["pack_name"]  = assign_pack(rec["category"], rec["text"].lower(), rec["is_premium"])

    print(f"  Premium (top 40%): {cutoff}  |  Free: {len(non_curated) - cutoff}")

    # Merge back
    final: list[dict] = processed  # already mutated in-place

    # ------------------------------------------------------------------
    # 6. Summary stats
    # ------------------------------------------------------------------
    cat_counts = {c: 0 for c in KEYWORDS}
    pack_counts: dict[str, int] = {}
    prem_count = 0

    for rec in final:
        cat_counts[rec["category"]] = cat_counts.get(rec["category"], 0) + 1
        pack_counts[rec["pack_name"]] = pack_counts.get(rec["pack_name"], 0) + 1
        if rec["is_premium"]:
            prem_count += 1

    print("\n[SUMMARY]")
    print(f"  Total final quotes: {len(final)}")
    print(f"  Premium: {prem_count}  |  Free: {len(final) - prem_count}")
    print("\n  By category:")
    for cat, count in sorted(cat_counts.items(), key=lambda x: -x[1]):
        print(f"    {cat:<15} {count}")
    print("\n  By pack:")
    for pack, count in sorted(pack_counts.items(), key=lambda x: -x[1]):
        print(f"    {pack:<25} {count}")

    if dry_run:
        print("\n[DRY RUN] No files written.")
        return

    # ------------------------------------------------------------------
    # 7. Export JSON
    # ------------------------------------------------------------------
    print(f"\n[STEP 6] Writing {OUT_JSON} ...")
    with open(OUT_JSON, "w", encoding="utf-8") as f:
        json.dump(final, f, ensure_ascii=False, indent=2)
    print(f"  Written {len(final)} records.")

    # ------------------------------------------------------------------
    # 8. Export CSV
    # ------------------------------------------------------------------
    print(f"\n[STEP 7] Writing {OUT_CSV} ...")
    fieldnames = ["text", "author", "source", "category", "tags", "lang",
                  "quality_score", "is_premium", "pack_name", "swipe_dir"]
    with open(OUT_CSV, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames, extrasaction="ignore")
        writer.writeheader()
        for rec in final:
            row = dict(rec)
            row["tags"] = "|".join(rec.get("tags", []))
            writer.writerow(row)
    print(f"  Written {len(final)} rows.")

    # ------------------------------------------------------------------
    # 9. Export SQL
    # ------------------------------------------------------------------
    print(f"\n[STEP 8] Writing {OUT_SQL} ...")

    def sql_escape(s: str) -> str:
        return s.replace("'", "''")

    lines = [
        "-- MindScrolling — Cleaned Philosophical Quotes Seed",
        f"-- Generated by scripts/prepare_quotes_dataset.py",
        f"-- Total records: {len(final)}",
        "-- Run in Supabase SQL Editor",
        "",
        "BEGIN;",
        "",
        "-- TRUNCATE quotes; -- Uncomment to clear existing data first",
        "",
        "INSERT INTO quotes (text, author, category, lang, swipe_dir, pack_name, is_premium) VALUES",
    ]

    value_rows = []
    for rec in final:
        text      = sql_escape(rec["text"])
        author    = sql_escape(rec["author"])
        category  = rec["category"]
        lang      = rec["lang"]
        swipe_dir = rec["swipe_dir"]
        pack_name = rec["pack_name"]
        is_prem   = "true" if rec["is_premium"] else "false"
        value_rows.append(
            f"  ('{text}', '{author}', '{category}', '{lang}', '{swipe_dir}', '{pack_name}', {is_prem})"
        )

    lines.append(",\n".join(value_rows) + ";")
    lines += [
        "",
        "COMMIT;",
        "",
        "-- Verification",
        "SELECT category,",
        "       COUNT(*) AS count,",
        "       COUNT(*) FILTER (WHERE is_premium = false) AS free_count",
        "FROM quotes",
        "GROUP BY category",
        "ORDER BY category;",
    ]

    with open(OUT_SQL, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))
    print(f"  Written {len(final)} INSERT rows.")

    print("\n[DONE] Pipeline complete.")
    print(f"  {OUT_JSON}")
    print(f"  {OUT_CSV}")
    print(f"  {OUT_SQL}")


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="MindScrolling quotes pipeline")
    parser.add_argument("--force",   action="store_true", help="Overwrite existing output files")
    parser.add_argument("--dry-run", action="store_true", help="Run pipeline without writing files")
    args = parser.parse_args()

    run_pipeline(force=args.force, dry_run=args.dry_run)
