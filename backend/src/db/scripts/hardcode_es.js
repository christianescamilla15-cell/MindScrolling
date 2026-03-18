import "dotenv/config";
import { createClient } from "@supabase/supabase-js";

const SUPABASE_URL      = process.env.SUPABASE_URL;
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY;
if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  console.error("Missing SUPABASE_URL or SUPABASE_ANON_KEY in backend/.env");
  process.exit(1);
}

const QUOTES_ES = [
  { text: "La felicidad de tu vida depende de la calidad de tus pensamientos.",                          author: "Marco Aurelio",       category: "stoicism",   lang: "es", dir: "left" },
  { text: "Sufrimos más en la imaginación que en la realidad.",                                           author: "Séneca",              category: "stoicism",   lang: "es", dir: "left" },
  { text: "No busques que los acontecimientos sucedan como quieres; desea que sucedan como son.", author: "Epicteto",    category: "stoicism",   lang: "es", dir: "left" },
  { text: "Solo sé que no sé nada.",                                                                      author: "Sócrates",            category: "philosophy", lang: "es", dir: "up" },
  { text: "La duda es el origen de la sabiduría.",                                                        author: "René Descartes",      category: "philosophy", lang: "es", dir: "up" },
  { text: "La disciplina es el puente entre las metas y los logros.",                                     author: "Jim Rohn",            category: "discipline", lang: "es", dir: "right" },
  { text: "Lo que pensamos, en eso nos convertimos.",                                                     author: "Buda",                category: "reflection", lang: "es", dir: "down" }
];

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

async function main() {
  console.log("Checking for Spanish quotes...");
  const { count } = await supabase.from("quotes").select("*", { count: "exact", head: true }).eq("lang", "es");
  
  if (count === 0) {
    console.log("No Spanish quotes found. Inserting sample...");
    const { error } = await supabase.from("quotes").upsert(QUOTES_ES, { onConflict: "text,author", ignoreDuplicates: true });
    if (error) console.error("Error inserting:", error.message);
    else console.log("Successfully inserted sample Spanish quotes.");
  } else {
    console.log(`Found ${count} Spanish quotes. Database is already seeded for 'es'.`);
  }
  process.exit(0);
}

main().catch(console.error);
