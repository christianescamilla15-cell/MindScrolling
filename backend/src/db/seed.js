/**
 * MindScrolling — Database Seeder v5
 * Source: Quotable.io (SSL bypass — cert expired 2025)
 * Tags: untapped pools — famous-quotes, friendship, competition, sports, technology
 * + keyword-based categorization to distribute across needy categories
 *
 * Run: node src/db/seed.js
 */

// SSL bypass needed because api.quotable.io certificate has expired (2025)
process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";

import "dotenv/config";
import { createClient } from "@supabase/supabase-js";

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_ANON_KEY
);

const TARGET  = 5500;
const PER_CAT = Math.ceil(TARGET / 4); // 1375

const CATEGORIES = ["stoicism", "philosophy", "discipline", "reflection"];

const CAT_TO_DIR = {
  stoicism: "up", philosophy: "down", discipline: "right", reflection: "left",
};

/* ─── Tags to fetch (untapped) with their preferred default category ────────── */
// These tags haven't been used in previous seeder runs.
// We'll pull ALL pages per tag, then distribute across needy categories.

const TAG_POOL = [
  // Smaller/targeted tags first (less likely to be exhausted)
  { tag: "competition",    prefer: "discipline" },
  { tag: "sports",         prefer: "discipline" },
  { tag: "technology",     prefer: "philosophy" },
  { tag: "future",         prefer: "philosophy" },
  { tag: "freedom",        prefer: "stoicism" },
  { tag: "failure",        prefer: "discipline" },
  { tag: "humor",          prefer: "reflection" },
  { tag: "humorous",       prefer: "reflection" },
  { tag: "politics",       prefer: "philosophy" },
  { tag: "film",           prefer: "reflection" },
  { tag: "spirituality",   prefer: "stoicism" },
  { tag: "faith",          prefer: "reflection" },
  { tag: "family",         prefer: "reflection" },
  { tag: "health",         prefer: "discipline" },
  { tag: "imagination",    prefer: "philosophy" },
  { tag: "gratitude",      prefer: "reflection" },
  { tag: "mathematics",    prefer: "philosophy" },
  { tag: "pain",           prefer: "stoicism" },
  { tag: "opportunity",    prefer: "discipline" },
  { tag: "sadness",        prefer: "reflection" },
  { tag: "time",           prefer: "philosophy" },
  { tag: "honor",          prefer: "stoicism" },
  { tag: "ethics",         prefer: "philosophy" },
  { tag: "war",            prefer: "stoicism" },
  // Large pool last (to top up any remaining gaps)
  { tag: "famous-quotes",  prefer: null },
  { tag: "friendship",     prefer: "reflection" },
];

/* ─── Keyword scoring for auto-categorization ──────────────────────────────── */

const KEYWORDS = {
  stoicism: [
    "wisdom", "virtue", "courage", "character", "integrity", "patience",
    "endure", "bear", "accept", "suffer", "duty", "honor", "stoic",
    "marcus", "seneca", "epictetus", "confucius", "lao tzu", "cicero",
    "reason", "fate", "tranquil", "equanim", "inner", "soul",
    "resilience", "adversity", "obstacle", "will", "freedom", "pain",
    "spiritual", "faith", "war", "death",
  ],
  philosophy: [
    "truth", "knowledge", "exist", "reality", "conscious", "universe",
    "wonder", "question", "understand", "logic", "beauty", "justice",
    "meaning", "purpose", "belief", "concept", "ideal", "plato",
    "aristotle", "socrates", "kant", "nietzsche", "descartes", "hume",
    "voltaire", "russell", "spinoza", "locke", "hegel", "camus", "sartre",
    "thought", "idea", "rational", "intellect", "science", "history",
    "art", "culture", "technology", "future", "politics", "imagination",
    "mathematics", "ethic", "time",
  ],
  discipline: [
    "success", "work", "effort", "achieve", "goal", "habit", "persist",
    "hard work", "hustle", "practice", "consistent", "action", "focus",
    "determination", "dedication", "motivation", "win", "champion",
    "leader", "result", "productive", "commit", "excellence", "improve",
    "ambition", "drive", "competition", "sport", "health", "fitness",
    "opportunity", "failure", "lesson", "bounce back", "never give up",
    "sweat", "earn", "deserve", "prepared", "ready",
  ],
  reflection: [
    "life", "love", "happiness", "peace", "joy", "gratitude", "dream",
    "hope", "time", "change", "heart", "smile", "laugh", "friend",
    "family", "moment", "memory", "journey", "emotion", "care",
    "share", "give", "kind", "compassion", "forgive", "heal",
    "light", "beauty", "film", "humor", "sad", "faith",
  ],
};

function categorize(text, author, availableCats, preferCat) {
  // If preferred category is available and no strong competitors, use it
  const lower = (text + " " + author).toLowerCase();
  const scores = {};
  for (const cat of availableCats) {
    let score = 0;
    for (const kw of KEYWORDS[cat]) {
      if (lower.includes(kw)) score++;
    }
    scores[cat] = score;
  }
  // Boost preferred category slightly
  if (preferCat && availableCats.includes(preferCat)) {
    scores[preferCat] = (scores[preferCat] || 0) + 1;
  }
  return availableCats.reduce((a, b) => scores[a] >= scores[b] ? a : b);
}

/* ─── Helpers ───────────────────────────────────────────────────────────────── */

async function sleep(ms) { return new Promise(r => setTimeout(r, ms)); }

async function getDbCounts() {
  const counts = {};
  for (const cat of CATEGORIES) {
    const { count } = await supabase
      .from("quotes")
      .select("*", { count: "exact", head: true })
      .eq("category", cat);
    counts[cat] = count ?? 0;
  }
  return counts;
}

/* ─── Fetch all pages for one Quotable tag ──────────────────────────────────── */

async function fetchAllPages(tag) {
  const quotes = [];
  let page = 1;
  let totalPages = 999;

  while (page <= totalPages) {
    let res, data;
    try {
      res = await fetch(
        `https://api.quotable.io/quotes?tags=${encodeURIComponent(tag)}&page=${page}&limit=150&sortBy=dateAdded&order=asc`,
        { headers: { "User-Agent": "MindScrolling-Seeder/5.0" } }
      );
      if (!res.ok) {
        if (res.status === 429) {
          process.stdout.write(`\n  ⏳ Rate limited on "${tag}". Waiting 10s...\n`);
          await sleep(10000);
          continue;
        }
        break;
      }
      data = await res.json();
    } catch {
      break;
    }

    const results = data.results ?? [];
    if (results.length === 0) break;

    for (const q of results) {
      const text   = (q.content || "").trim();
      const author = (q.author  || "").trim();
      if (!text || !author || text.length < 15 || text.length > 500) continue;
      quotes.push({ text, author });
    }

    totalPages = data.totalPages ?? 1;
    process.stdout.write(
      `\r  [${tag.padEnd(16)}] page ${String(page).padStart(3)}/${totalPages} | collected: ${quotes.length}   `
    );

    if (page >= totalPages) break;
    page++;
    await sleep(400);
  }

  return quotes;
}

/* ─── Dedup within batch ────────────────────────────────────────────────────── */

function dedup(quotes) {
  const seen = new Set();
  return quotes.filter(q => {
    const key = q.text.slice(0, 80).toLowerCase().replace(/\s+/g, " ");
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  });
}

/* ─── Insert into Supabase ──────────────────────────────────────────────────── */

async function insertBatch(quotes) {
  const CHUNK = 200;
  let total = 0;
  for (let i = 0; i < quotes.length; i += CHUNK) {
    const chunk = quotes.slice(i, i + CHUNK);
    const { data, error } = await supabase
      .from("quotes")
      .upsert(chunk, { onConflict: "text,author", ignoreDuplicates: true })
      .select("id");
    if (error) {
      console.warn(`\n  ⚠ Chunk ${i}: ${error.message}`);
    } else {
      total += (data?.length ?? 0);
    }
    process.stdout.write(`\r  Inserting ${i + chunk.length}/${quotes.length}   `);
  }
  return total;
}

/* ─── Main ──────────────────────────────────────────────────────────────────── */

async function main() {
  console.log("🌱 MindScrolling Seeder v5 — Quotable.io untapped tags\n");

  let counts = await getDbCounts();
  const startTotal = CATEGORIES.reduce((s, c) => s + counts[c], 0);
  console.log(`📊 Current DB: ${startTotal} quotes`);
  CATEGORIES.forEach(c =>
    console.log(`   ${c.padEnd(12)}: ${counts[c]}/${PER_CAT} (need ${Math.max(0, PER_CAT - counts[c])} more)`)
  );

  if (!CATEGORIES.some(c => counts[c] < PER_CAT)) {
    console.log("\n✅ Target already reached. Nothing to do.");
    return;
  }

  console.log("\n📚 Fetching untapped Quotable.io tags...\n");

  let totalInserted = 0;
  const allBatched = [];

  for (const { tag, prefer } of TAG_POOL) {
    // Re-check if all categories are full
    const needy = CATEGORIES.filter(c => counts[c] < PER_CAT);
    if (needy.length === 0) break;

    process.stdout.write(`\n  Fetching tag: "${tag}"...\n`);
    const raw = await fetchAllPages(tag);

    if (raw.length === 0) {
      console.log(`  → 0 quotes from "${tag}"`);
      continue;
    }

    // Distribute quotes across needy categories
    const batch = [];
    for (const q of raw) {
      const remaining = CATEGORIES.filter(c => counts[c] < PER_CAT);
      if (remaining.length === 0) break;
      const cat = categorize(q.text, q.author, remaining, prefer);
      if (counts[cat] < PER_CAT) {
        batch.push({
          text:      q.text,
          author:    q.author,
          category:  cat,
          lang:      "en",
          swipe_dir: CAT_TO_DIR[cat],
        });
        counts[cat]++;
      }
    }

    const unique = dedup(batch);
    console.log(`\n  → categorized ${unique.length} from "${tag}"`);

    if (unique.length > 0) {
      const inserted = await insertBatch(unique);
      totalInserted += inserted;
      console.log(`\n  → inserted ${inserted} new`);
      allBatched.push(...unique);
      // Re-sync from DB to correct optimistic count drift
      counts = await getDbCounts();
    }

    // Show running counts
    CATEGORIES.forEach(c =>
      process.stdout.write(`  ${c}: ${counts[c]}/${PER_CAT}  `)
    );
    console.log();
  }

  // Final sync from DB
  const finalCounts = await getDbCounts();
  const { count: finalTotal } = await supabase
    .from("quotes")
    .select("*", { count: "exact", head: true });

  console.log(`\n✅ Done! Total in DB: ${finalTotal} | New insertions: ${totalInserted}`);
  CATEGORIES.forEach(c =>
    console.log(`   ${c.padEnd(12)}: ${finalCounts[c]}/${PER_CAT} ${finalCounts[c] >= PER_CAT ? "✓" : `(need ${PER_CAT - finalCounts[c]} more)`}`)
  );
}

main().catch(err => {
  console.error("\n❌ Error:", err.message);
  process.exit(1);
});
