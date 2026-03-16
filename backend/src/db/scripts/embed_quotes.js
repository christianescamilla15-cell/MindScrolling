/**
 * embed_quotes.js — One-time batch embedding script
 *
 * Generates Voyage AI embeddings for all quotes that have embedding = NULL.
 * Resume-safe: skips already-embedded quotes.
 * Run once after migration 004, then whenever new quotes are seeded.
 *
 * Usage:
 *   node src/db/scripts/embed_quotes.js
 *
 * Environment required:
 *   SUPABASE_URL, SUPABASE_ANON_KEY, VOYAGE_API_KEY
 */

import "dotenv/config";
import { createClient }      from "@supabase/supabase-js";
import { generateEmbeddingBatch } from "../services/embeddings.js";

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_ANON_KEY
);

const BATCH_SIZE    = 100;   // Voyage AI max per request
const DELAY_MS      = 300;   // Polite delay between batches (avoid rate limit)

function sleep(ms) { return new Promise(r => setTimeout(r, ms)); }

async function run() {
  console.log("🔍  Fetching unembedded quotes...");

  // Count total work
  const { count } = await supabase
    .from("quotes")
    .select("*", { count: "exact", head: true })
    .is("embedding", null);

  if (!count || count === 0) {
    console.log("✅  All quotes already embedded.");
    return;
  }

  console.log(`📦  Found ${count} quotes to embed (batch size: ${BATCH_SIZE})`);

  let processed = 0;
  let offset    = 0;

  while (true) {
    // Fetch next batch of unembedded quotes
    const { data: quotes, error } = await supabase
      .from("quotes")
      .select("id, text, author, category")
      .is("embedding", null)
      .range(offset, offset + BATCH_SIZE - 1);

    if (error) { console.error("DB error:", error.message); break; }
    if (!quotes || quotes.length === 0) break;

    // Build embedding inputs (enrich text with author and category for better retrieval)
    const texts = quotes.map(
      q => `${q.text} — ${q.author} [${q.category}]`
    );

    let embeddings;
    try {
      embeddings = await generateEmbeddingBatch(texts);
    } catch (err) {
      console.error(`⚠️  Embedding batch failed (offset ${offset}):`, err.message);
      console.log("   Retrying in 5 s...");
      await sleep(5000);
      continue;   // retry same batch
    }

    // Write embeddings back to DB in bulk
    const updates = quotes.map((q, i) => ({
      id:        q.id,
      embedding: embeddings[i],
    }));

    const { error: upsertErr } = await supabase
      .from("quotes")
      .upsert(updates, { onConflict: "id" });

    if (upsertErr) {
      console.error(`⚠️  DB upsert failed (offset ${offset}):`, upsertErr.message);
    } else {
      processed += quotes.length;
      const pct  = ((processed / count) * 100).toFixed(1);
      console.log(`   ✓  ${processed}/${count} (${pct}%)`);
    }

    offset += quotes.length;
    if (quotes.length < BATCH_SIZE) break;   // last batch

    await sleep(DELAY_MS);
  }

  console.log(`\n🎉  Done — ${processed} quotes embedded.`);
}

run().catch(err => {
  console.error("Fatal error:", err);
  process.exit(1);
});
