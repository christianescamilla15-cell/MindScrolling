/**
 * translate_quotes.js
 *
 * Reads all ES quotes that still have English text, translates them using
 * Claude, and updates the rows in Supabase.
 *
 * Usage:
 *   node scripts/translate_quotes.js              # translate all
 *   node scripts/translate_quotes.js --dry-run    # preview without writing
 *   node scripts/translate_quotes.js --batch=25   # custom batch size (default 25)
 */

import "dotenv/config";
import { createClient } from "@supabase/supabase-js";
import Anthropic from "@anthropic-ai/sdk";

// ── Config ────────────────────────────────────────────────────────────────────

const SUPABASE_URL  = process.env.SUPABASE_URL;
const SUPABASE_KEY  = process.env.SUPABASE_ANON_KEY;
const ANTHROPIC_KEY = process.env.ANTHROPIC_API_KEY;

const BATCH_SIZE = parseInt(
  process.argv.find(a => a.startsWith("--batch="))?.split("=")[1] ?? "25",
  10
);
const DRY_RUN = process.argv.includes("--dry-run");

if (!SUPABASE_URL || !SUPABASE_KEY || !ANTHROPIC_KEY) {
  console.error("Missing env vars: SUPABASE_URL, SUPABASE_ANON_KEY, or ANTHROPIC_API_KEY");
  process.exit(1);
}

const supabase  = createClient(SUPABASE_URL, SUPABASE_KEY);
const anthropic = new Anthropic({ apiKey: ANTHROPIC_KEY });

// ── Helpers ───────────────────────────────────────────────────────────────────

async function fetchAllQuotes(lang) {
  const all = [];
  let from = 0;
  const PAGE = 1000;
  while (true) {
    const { data, error } = await supabase
      .from("quotes")
      .select("id, text, author, category, swipe_dir, pack_name, is_premium")
      .eq("lang", lang)
      .range(from, from + PAGE - 1);
    if (error) throw error;
    all.push(...data);
    if (data.length < PAGE) break;
    from += PAGE;
  }
  return all;
}

/**
 * Translate a batch of quotes using Claude.
 * Returns array of { index, text_es }.
 */
async function translateBatch(quotes) {
  const numbered = quotes
    .map((q, i) => `[${i}] "${q.text}" — ${q.author}`)
    .join("\n");

  const response = await anthropic.messages.create({
    model: "claude-sonnet-4-20250514",
    max_tokens: 8192,
    messages: [
      {
        role: "user",
        content: `You are a professional translator specializing in philosophy and classical literature.

Translate each of the following philosophical quotes from English to Spanish.
Keep the original meaning, tone, and philosophical depth.
Use natural, elegant Spanish — not literal word-by-word translation.
For well-known quotes that already have established Spanish translations, use the canonical version.
Do NOT include the author name in the translation — only translate the quote text itself.

Return ONLY a JSON array where each element is: {"i": <index>, "t": "<spanish translation>"}
No extra text, no markdown fences, no explanation. Just the raw JSON array.

Quotes:
${numbered}`,
      },
    ],
  });

  const raw = response.content[0].text.trim();
  const jsonMatch = raw.match(/\[[\s\S]*\]/);
  if (!jsonMatch) {
    console.error("  Could not parse Claude response:", raw.slice(0, 300));
    return [];
  }

  try {
    const parsed = JSON.parse(jsonMatch[0]);
    return parsed.map(item => ({
      index: item.i,
      text_es: item.t,
    }));
  } catch (e) {
    console.error("  JSON parse error:", e.message);
    return [];
  }
}

// ── Main ──────────────────────────────────────────────────────────────────────

async function main() {
  console.log("Fetching quotes...");
  const enQuotes = await fetchAllQuotes("en");
  const esQuotes = await fetchAllQuotes("es");

  console.log(`  EN quotes: ${enQuotes.length}`);
  console.log(`  ES quotes: ${esQuotes.length}`);

  // Build a set of EN texts to find ES rows that are just untranslated copies
  const enTextSet = new Set(enQuotes.map(q => q.text.trim()));

  // ES quotes that need translation = those whose text matches an EN quote exactly
  const needsTranslation = esQuotes.filter(q => enTextSet.has(q.text.trim()));

  console.log(`  ES quotes needing translation: ${needsTranslation.length}`);

  // Also find EN quotes that don't have ANY ES counterpart
  const enWithoutEs = enQuotes.filter(
    q => !esQuotes.some(es => es.author === q.author && es.category === q.category)
  );

  if (enWithoutEs.length > 0) {
    console.log(`  EN quotes without ES counterpart: ${enWithoutEs.length} (will create new rows)`);
  }

  const totalWork = needsTranslation.length + enWithoutEs.length;
  if (totalWork === 0) {
    console.log("\nAll quotes already translated!");
    return;
  }

  if (DRY_RUN) {
    console.log("\n[DRY RUN] Would translate:");
    needsTranslation.slice(0, 5).forEach(q =>
      console.log(`  UPDATE: "${q.text.slice(0, 60)}..." by ${q.author}`)
    );
    enWithoutEs.slice(0, 5).forEach(q =>
      console.log(`  INSERT: "${q.text.slice(0, 60)}..." by ${q.author}`)
    );
    if (totalWork > 10) console.log(`  ... and ${totalWork - 10} more`);
    return;
  }

  // ── Phase 1: Update existing ES rows that have English text ─────────────────
  let translated = 0;
  let errors = 0;

  if (needsTranslation.length > 0) {
    console.log(`\n── Phase 1: Updating ${needsTranslation.length} existing ES rows ──`);

    for (let i = 0; i < needsTranslation.length; i += BATCH_SIZE) {
      const batch = needsTranslation.slice(i, i + BATCH_SIZE);
      const batchNum = Math.floor(i / BATCH_SIZE) + 1;
      const totalBatches = Math.ceil(needsTranslation.length / BATCH_SIZE);

      process.stdout.write(`  Batch ${batchNum}/${totalBatches} (${batch.length} quotes)... `);

      try {
        const results = await translateBatch(batch);

        for (const { index, text_es } of results) {
          if (index >= batch.length || !text_es) continue;
          const esQuote = batch[index];

          const { error } = await supabase
            .from("quotes")
            .update({ text: text_es })
            .eq("id", esQuote.id);

          if (error) {
            console.error(`\n    Error updating ${esQuote.id}: ${error.message}`);
            errors++;
          } else {
            translated++;
          }
        }

        console.log(`OK (${results.length} translated)`);
      } catch (e) {
        console.log(`ERROR: ${e.message}`);
        errors += batch.length;
      }

      // Rate limit pause
      if (i + BATCH_SIZE < needsTranslation.length) {
        await new Promise(r => setTimeout(r, 1500));
      }
    }
  }

  // ── Phase 2: Create new ES rows for EN quotes without counterpart ──────────
  if (enWithoutEs.length > 0) {
    console.log(`\n── Phase 2: Creating ${enWithoutEs.length} new ES rows ──`);

    for (let i = 0; i < enWithoutEs.length; i += BATCH_SIZE) {
      const batch = enWithoutEs.slice(i, i + BATCH_SIZE);
      const batchNum = Math.floor(i / BATCH_SIZE) + 1;
      const totalBatches = Math.ceil(enWithoutEs.length / BATCH_SIZE);

      process.stdout.write(`  Batch ${batchNum}/${totalBatches} (${batch.length} quotes)... `);

      try {
        const results = await translateBatch(batch);

        for (const { index, text_es } of results) {
          if (index >= batch.length || !text_es) continue;
          const enQuote = batch[index];

          const { error } = await supabase.from("quotes").insert({
            text: text_es,
            author: enQuote.author,
            category: enQuote.category,
            lang: "es",
            swipe_dir: enQuote.swipe_dir,
            pack_name: enQuote.pack_name,
            is_premium: enQuote.is_premium,
          });

          if (error) {
            console.error(`\n    Error inserting: ${error.message}`);
            errors++;
          } else {
            translated++;
          }
        }

        console.log(`OK (${results.length} translated)`);
      } catch (e) {
        console.log(`ERROR: ${e.message}`);
        errors += batch.length;
      }

      if (i + BATCH_SIZE < enWithoutEs.length) {
        await new Promise(r => setTimeout(r, 1500));
      }
    }
  }

  console.log(`\n Done! Translated: ${translated} | Errors: ${errors}`);
}

main().catch(e => {
  console.error("Fatal:", e);
  process.exit(1);
});
