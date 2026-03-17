import "dotenv/config";
import { createClient } from "@supabase/supabase-js";
import { readFileSync } from "fs";

// Load quotes from frontend file
const quotesFile = readFileSync("../frontend/src/data/quotes_es.js", "utf-8");
const match = quotesFile.match(/const QUOTES_ES = (\[[\s\S]*?\]);/);
if (!match) {
  console.error("Could not parse QUOTES_ES");
  process.exit(1);
}

const QUOTES_ES = eval(match[1]);

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_ANON_KEY
);

async function main() {
  console.log("🌱 MindScrolling Seeder ES — Inserting Spanish quotes\n");
  
  const mappedQuotes = QUOTES_ES.map(q => ({
    text: q.text,
    author: q.author,
    category: q.category,
    lang: q.lang,
    swipe_dir: q.dir
  }));

  const { data, error } = await supabase
    .from("quotes")
    .upsert(mappedQuotes, { onConflict: "text,author", ignoreDuplicates: true })
    .select("id");

  if (error) {
    console.error("❌ Error inserting Spanish quotes:", error.message);
  } else {
    console.log(`✅ Success! Inserted ${data?.length || 0} Spanish quotes.`);
  }
}

main().catch(console.error);
