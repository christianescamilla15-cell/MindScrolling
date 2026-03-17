import "dotenv/config";
import { createClient } from "@supabase/supabase-js";
import Anthropic from "@anthropic-ai/sdk";
import fs from "fs";
import path from "path";

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_ANON_KEY
);

// We use Anthropic's Claude 3 Haiku for cost-effective, high-quality translation
const anthropic = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY
});

// Fallback chain of models in case the account doesn't have access to some
const MODELS = [
  "claude-3-haiku-20240307",
  "claude-3-5-sonnet-20241022",
  "claude-3-5-haiku-20241022",
  "claude-3-sonnet-20240229",
  "claude-3-opus-20240229",
  "claude-2.1",
  "claude-2.0"
];

const BATCH_SIZE = 40;
const OUTPUT_FILE = path.join(process.cwd(), "src/db/quotes_es_translated.json");
const DELAY_MS = 1000;

async function sleep(ms) { 
  return new Promise(r => setTimeout(r, ms)); 
}

async function fetchEnglishQuotes() {
  console.log("🔍 Fetching total English quotes from Supabase...");
  const { count, error: countErr } = await supabase
    .from("quotes")
    .select("*", { count: "exact", head: true })
    .eq("lang", "en");

  if (countErr || !count) {
    console.error("❌ Could not get total count of EN quotes:", countErr);
    return [];
  }

  console.log(`📦 Found ${count} English quotes in database.`);
  let allEn = [];
  let offset = 0;

  while(offset < count) {
    const { data, error } = await supabase
      .from("quotes")
      .select("id, text, author, category, swipe_dir, pack_name, is_premium")
      .eq("lang", "en")
      .order("id") // Ensure deterministic order
      .range(offset, offset + 999);

    if (error) {
           console.error(`❌ DB Error fetching offset ${offset}:`, error.message);
           break;
    }
    if (data) allEn = allEn.concat(data);
    
    process.stdout.write(`\rLoaded ${allEn.length}/${count}`);
    offset += 1000;
  }
  console.log("\n✅ Fetch complete.");
  return allEn;
}

async function run() {
  console.log("🌐 MindScrolling - Spanish Translator - Fallback Logic\n");
  const allEn = await fetchEnglishQuotes();
  if (!allEn.length) return;

  // Load progress if the script was interrupted
  let translatedMap = {};
  let currentTranslated = [];

  if (fs.existsSync(OUTPUT_FILE)) {
    try {
      currentTranslated = JSON.parse(fs.readFileSync(OUTPUT_FILE, "utf-8"));
      currentTranslated.forEach(q => { translatedMap[q.original_id] = true; });
      console.log(`\n💾 Resuming... found ${currentTranslated.length} already translated quotes.`);
    } catch(e) {
      console.error("❌ Error parsing existing output file, starting fresh.");
      currentTranslated = [];
    }
  }

  const pending = allEn.filter(q => !translatedMap[q.id]);
  console.log(`⏳ Remaining to translate: ${pending.length}`);

  if (pending.length === 0) {
    console.log("🎉 All quotes have been translated! Use upload_translated.js to send to Supabase.");
    process.exit(0);
  }

  let currentModelIndex = 0;

  // Process in batches
  for (let i = 0; i < pending.length; i += BATCH_SIZE) {
    const batch = pending.slice(i, i + BATCH_SIZE);
    console.log(`\n🤖 Translating batch [${i} - ${i + batch.length - 1}] of ${pending.length}...`);

    const promptText = `
Translate the following philosophical, motivational or literary quotes into Spanish. 
Keep the tone natural, profound, and respectful of the original meaning. Remember to translate the author's name to Spanish equivalent if they have a recognized historical name in Spanish (e.g. "Marcus Aurelius" -> "Marco Aurelio").

Output EXACTLY AND ONLY a valid JSON array of objects with the exact same order.
Format expected:
[
  { "id": "...", "text": "...", "author": "..." },
  ...
]

INPUT QUOTES:
${JSON.stringify(batch.map(q => ({ id: q.id, text: q.text, author: q.author })), null, 2)}
    `;

    let retries = 5;
    let translatedJson = null;

    while (retries > 0) {
      if (currentModelIndex >= MODELS.length) {
        console.error("🛑 Exhausted all available Anthropic models. Exiting translation early...");
        process.exit(1);
      }
      
      const activeModel = MODELS[currentModelIndex];
      console.log(`   * Prompting model: ${activeModel}`);

      try {
        const msg = await anthropic.messages.create({
          model: activeModel,
          max_tokens: 4000,
          temperature: 0.2, // Low temperature for factual translation
          messages: [{ role: "user", content: promptText }]
        });
        
        const rawContent = msg.content[0].text;
        
        // Use a RegEx to extract the JSON array in case Claude adds intro/outro text
        const match = rawContent.match(/\[\s*\{[\s\S]*\}\s*\]/);
        if (!match) throw new Error("Could not find a valid JSON array in Claude's response");
        
        translatedJson = JSON.parse(match[0]);
        
        // Assert we got back the exact size we asked for
        if (translatedJson.length !== batch.length) {
            console.warn(`⚠️ Warning: Asked for ${batch.length} items but got ${translatedJson.length}. Alignment might break.`);
        }
        
        break; // Success!
      } catch (err) {
        if (err.status === 404 || (err.error && err.error.type === 'not_found_error')) {
            console.error(`   ❌ Model ${activeModel} not found or no access. Switching to next fallback.`);
            currentModelIndex++;
            continue; // Skip the sleep, immediately try the next model
        }
        
        retries--;
        console.error(`   ❌ API error or parse fail (Retries left: ${retries}):`, err.message);
        if (retries === 0) {
          console.error("🛑 Exhausted retries for this batch. Exiting translation early...");
          process.exit(1); 
        }
        await sleep(3000); 
      }
    }

    if (!translatedJson) break;

    // Merge outputs back together and persist
    for (let j = 0; j < batch.length; j++) {
      const orig = batch[j];
      const trans = translatedJson.find(t => t.id === orig.id) || translatedJson[j]; // Fallback by index if id gets lost empty

      if (trans && trans.text) {
        currentTranslated.push({
          original_id: orig.id,
          text: trans.text,
          author: trans.author || orig.author,
          category: orig.category,
          swipe_dir: orig.swipe_dir,
          pack_name: orig.pack_name,
          is_premium: orig.is_premium,
          lang: "es"
        });
      }
    }

    fs.writeFileSync(OUTPUT_FILE, JSON.stringify(currentTranslated, null, 2));
    console.log(`   ✓ Saved progress. We now have ${currentTranslated.length} translated quotes in disk.`);
    
    await sleep(DELAY_MS);
  }

  console.log("\n🎉 Translation loop finished! Run 'node src/db/scripts/upload_translated.js'.");
}

run().catch(console.error);
