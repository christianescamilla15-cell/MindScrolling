import { config } from "dotenv";
config({ path: new URL("../../../.env", import.meta.url).pathname });

const SUPABASE_URL     = process.env.SUPABASE_URL;
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY;
if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  console.error("Missing SUPABASE_URL or SUPABASE_ANON_KEY in backend/.env");
  process.exit(1);
}

const QUOTES_ES = [
  { text: "La felicidad de tu vida depende de la calidad de tus pensamientos.",                          author: "Marco Aurelio",       category: "stoicism",   lang: "es", swipe_dir: "left" },
  { text: "Sufrimos más en la imaginación que en la realidad.",                                           author: "Séneca",              category: "stoicism",   lang: "es", swipe_dir: "left" },
  { text: "No busques que los acontecimientos sucedan como quieres; desea que sucedan como son.", author: "Epicteto",    category: "stoicism",   lang: "es", swipe_dir: "left" },
  { text: "Solo sé que no sé nada.",                                                                      author: "Sócrates",            category: "philosophy", lang: "es", swipe_dir: "up" },
  { text: "La duda es el origen de la sabiduría.",                                                        author: "René Descartes",      category: "philosophy", lang: "es", swipe_dir: "up" },
  { text: "La disciplina es el puente entre las metas y los logros.",                                     author: "Jim Rohn",            category: "discipline", lang: "es", swipe_dir: "right" },
  { text: "Lo que pensamos, en eso nos convertimos.",                                                     author: "Buda",                category: "reflection", lang: "es", swipe_dir: "down" }
];

async function main() {
  console.log("Checking ES quotes...");
  const getRes = await fetch(`${SUPABASE_URL}/rest/v1/quotes?lang=eq.es&select=id`, {
    headers: {
      "apikey": SUPABASE_ANON_KEY,
      "Authorization": `Bearer ${SUPABASE_ANON_KEY}`
    }
  });
  const data = await getRes.json();
  if (data && data.length > 0) {
    console.log(`Found ${data.length} ES quotes.`);
    return;
  }

  console.log("Inserting ES quotes via fetch...");
  const postRes = await fetch(`${SUPABASE_URL}/rest/v1/quotes`, {
    method: "POST",
    headers: {
      "apikey": SUPABASE_ANON_KEY,
      "Authorization": `Bearer ${SUPABASE_ANON_KEY}`,
      "Content-Type": "application/json",
      "Prefer": "resolution=ignore-duplicates"
    },
    body: JSON.stringify(QUOTES_ES)
  });
  console.log("Insert status:", postRes.status, await postRes.text());
}
main();
