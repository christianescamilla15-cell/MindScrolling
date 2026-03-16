/**
 * import_hf_quotes.js
 *
 * Imports cleaned quotes from data/cleaned_quotes.json into Supabase.
 * Skips duplicates based on (text, author) unique constraint.
 *
 * Usage:
 *   node scripts/import_hf_quotes.js              # import all
 *   node scripts/import_hf_quotes.js --limit=5500 # import up to N quotes
 *   node scripts/import_hf_quotes.js --dry-run    # preview without writing
 */

import "dotenv/config";
import { createClient } from "@supabase/supabase-js";
import { readFileSync } from "fs";
import { resolve } from "path";

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_ANON_KEY);

const DRY_RUN = process.argv.includes("--dry-run");
const LIMIT   = parseInt(
  process.argv.find(a => a.startsWith("--limit="))?.split("=")[1] ?? "0",
  10
);
const CHUNK = 200;

async function main() {
  const jsonPath = resolve(process.cwd(), "..", "data", "cleaned_quotes.json");
  console.log(`Reading ${jsonPath}...`);

  let quotes = JSON.parse(readFileSync(jsonPath, "utf8"));
  console.log(`  Loaded: ${quotes.length} quotes`);

  // Sort by quality_score descending so we import the best ones first
  quotes.sort((a, b) => (b.quality_score ?? 0) - (a.quality_score ?? 0));

  if (LIMIT > 0) {
    quotes = quotes.slice(0, LIMIT);
    console.log(`  Limited to: ${quotes.length} (top quality)`);
  }

  // Check current DB count
  const { count: currentCount } = await supabase
    .from("quotes")
    .select("*", { count: "exact", head: true })
    .eq("lang", "en");
  console.log(`  Current EN quotes in DB: ${currentCount}`);

  // Prepare rows for insertion (EN only — ES translation runs separately)
  const rows = quotes.map(q => ({
    text:       q.text,
    author:     q.author,
    category:   q.category,
    lang:       "en",
    swipe_dir:  q.swipe_dir || "up",
    pack_name:  q.pack_name || "free",
    is_premium: q.is_premium || false,
  }));

  if (DRY_RUN) {
    console.log(`\n[DRY RUN] Would insert ${rows.length} quotes.`);
    console.log("Sample:");
    rows.slice(0, 3).forEach(r =>
      console.log(`  [${r.category}] ${r.author}: "${r.text.slice(0, 60)}..."`)
    );
    return;
  }

  console.log(`\nInserting ${rows.length} quotes in chunks of ${CHUNK}...`);

  let inserted = 0;
  let skipped = 0;

  for (let i = 0; i < rows.length; i += CHUNK) {
    const chunk = rows.slice(i, i + CHUNK);

    const { data, error } = await supabase
      .from("quotes")
      .upsert(chunk, { onConflict: "text,author", ignoreDuplicates: true })
      .select("id");

    if (error) {
      console.error(`  Chunk ${i}: ${error.message}`);
      skipped += chunk.length;
    } else {
      const newCount = data?.length ?? 0;
      inserted += newCount;
      skipped += chunk.length - newCount;
    }

    const pct = Math.round(((i + chunk.length) / rows.length) * 100);
    process.stdout.write(`\r  Progress: ${i + chunk.length}/${rows.length} (${pct}%) | Inserted: ${inserted} | Skipped: ${skipped}   `);
  }

  console.log(`\n\nDone! Inserted: ${inserted} | Skipped (duplicates): ${skipped}`);

  // Final count
  const { count: finalCount } = await supabase
    .from("quotes")
    .select("*", { count: "exact", head: true })
    .eq("lang", "en");
  console.log(`Final EN quotes in DB: ${finalCount}`);
}

main().catch(e => {
  console.error("Fatal:", e);
  process.exit(1);
});
