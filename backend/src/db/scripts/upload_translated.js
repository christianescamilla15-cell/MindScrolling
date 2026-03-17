import "dotenv/config";
import { createClient } from "@supabase/supabase-js";
import fs from "fs";
import path from "path";

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_ANON_KEY
);

const INPUT_FILE = path.join(process.cwd(), "src/db/quotes_es_translated.json");
const BATCH_SIZE = 200;

async function sleep(ms) { return new Promise(r => setTimeout(r, ms)); }

async function run() {
  console.log("☁️  MindScrolling - Supabase Upload ES Quotes\n");

  if (!fs.existsSync(INPUT_FILE)) {
    console.error(`❌ Could not find translation JSON file: ${INPUT_FILE}`);
    console.error("Please run the translate_quotes.js script first.");
    process.exit(1);
  }

  const quotesJson = JSON.parse(fs.readFileSync(INPUT_FILE, "utf-8"));
  console.log(`📦 Found ${quotesJson.length} translated quotes to upload.`);

  // Drop "original_id" since the DB schema just expects "text, author, lang..." etc.
  const payload = quotesJson.map(q => {
    const { original_id, ...rest } = q;
    return rest;
  });

  let totalInserted = 0;

  for (let i = 0; i < payload.length; i += BATCH_SIZE) {
    const chunk = payload.slice(i, i + BATCH_SIZE);
    
    process.stdout.write(`\r🚀 Uploading batch ${i}/${payload.length}...`);

    const { data, error } = await supabase
      .from("quotes")
      .upsert(chunk, { onConflict: "text,author", ignoreDuplicates: true })
      .select("id");

    if (error) {
      console.error(`\n❌ Error uploading chunk starting at index ${i}:`, error.message);
      // We will continue sending the rest so it doesn't break
    } else {
      totalInserted += (data?.length || 0);
    }
  }

  console.log(`\n\n✅ Upload finished! Inserted exactly ${totalInserted} new Spanish quotes to the database.`);
}

run().catch(err => {
  console.error("\n❌ Fatal Error:", err);
  process.exit(1);
});
