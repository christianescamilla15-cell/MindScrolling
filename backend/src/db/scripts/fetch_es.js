const SUPABASE_URL = "https://rwhvjtfargojxccqblfb.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ3aHZqdGZhcmdvanhjY3FibGZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM2MjQ5NDUsImV4cCI6MjA4OTIwMDk0NX0.cIs2wdnMUmaGr76YQWfwrrK6k0zMqhPoCRbsmmUjyBU";

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
