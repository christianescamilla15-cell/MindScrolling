import "dotenv/config";
import { createClient } from "@supabase/supabase-js";

const SUPABASE_URL             = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
  console.error("Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY in backend/.env");
  process.exit(1);
}

const QUOTES_ES = [
  { text: "La felicidad de tu vida depende de la calidad de tus pensamientos.",                          author: "Marco Aurelio",       category: "stoicism",   lang: "es", swipe_dir: "up" },
  { text: "Sufrimos más en la imaginación que en la realidad.",                                           author: "Séneca",              category: "stoicism",   lang: "es", swipe_dir: "up" },
  { text: "No busques que los acontecimientos sucedan como quieres; desea que sucedan como son.", author: "Epicteto",    category: "stoicism",   lang: "es", swipe_dir: "up" },
  { text: "Solo sé que no sé nada.",                                                                      author: "Sócrates",            category: "philosophy", lang: "es", swipe_dir: "down" },
  { text: "La duda es el origen de la sabiduría.",                                                        author: "René Descartes",      category: "philosophy", lang: "es", swipe_dir: "down" },
  { text: "La disciplina es el puente entre las metas y los logros.",                                     author: "Jim Rohn",            category: "discipline", lang: "es", swipe_dir: "right" },
  { text: "Lo que pensamos, en eso nos convertimos.",                                                     author: "Buda",                category: "reflection", lang: "es", swipe_dir: "left" }
];

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

async function main() {
  console.log("Checking for Spanish quotes...");
  const { count } = await supabase.from("quotes").select("*", { count: "exact", head: true }).eq("lang", "es");
  
  if (count === 0) {
    console.log("No Spanish quotes found. Inserting sample...");
    const { error } = await supabase.from("quotes").upsert(QUOTES_ES, { onConflict: "text,author", ignoreDuplicates: true });
    if (error) {
      console.error("Error inserting:", error.message);
      process.exit(1);
    }
    console.log("Successfully inserted sample Spanish quotes.");
  } else {
    console.log(`Found ${count} Spanish quotes. Database is already seeded for 'es'.`);
  }
  process.exit(0);
}

main().catch(console.error);
