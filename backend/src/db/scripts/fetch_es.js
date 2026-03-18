import { config } from "dotenv";
config({ path: new URL("../../../.env", import.meta.url).pathname });

import { createClient } from "@supabase/supabase-js";

const SUPABASE_URL              = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
  console.error("Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY in backend/.env");
  process.exit(1);
}

// Author names match the authors table (English) for correct slug lookups
const QUOTES_ES = [
  { text: "La felicidad de tu vida depende de la calidad de tus pensamientos.",                   author: "Marcus Aurelius", category: "stoicism",   lang: "es", swipe_dir: "up"    },
  { text: "Sufrimos más en la imaginación que en la realidad.",                                    author: "Seneca",          category: "stoicism",   lang: "es", swipe_dir: "up"    },
  { text: "No busques que los acontecimientos sucedan como quieres; desea que sucedan como son.", author: "Epictetus",       category: "stoicism",   lang: "es", swipe_dir: "up"    },
  { text: "Solo sé que no sé nada.",                                                               author: "Socrates",        category: "philosophy", lang: "es", swipe_dir: "down"  },
  { text: "La duda es el origen de la sabiduría.",                                                 author: "René Descartes",  category: "philosophy", lang: "es", swipe_dir: "down"  },
  { text: "La disciplina es el puente entre las metas y los logros.",                              author: "Jim Rohn",        category: "discipline", lang: "es", swipe_dir: "right" },
  { text: "Lo que pensamos, en eso nos convertimos.",                                              author: "Buddha",          category: "reflection", lang: "es", swipe_dir: "left"  },
];

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

async function main() {
  console.log("Checking ES quotes...");
  const { count, error: countErr } = await supabase
    .from("quotes")
    .select("*", { count: "exact", head: true })
    .eq("lang", "es");

  if (countErr) {
    console.error("Error checking ES quotes:", countErr.message);
    process.exit(1);
  }

  if (count && count > 0) {
    console.log(`Found ${count} ES quotes. Database already seeded.`);
    process.exit(0);
  }

  console.log("No ES quotes found. Inserting sample...");
  const { error: insertErr } = await supabase
    .from("quotes")
    .upsert(QUOTES_ES, { onConflict: "text,author", ignoreDuplicates: true });

  if (insertErr) {
    console.error("Error inserting ES quotes:", insertErr.message);
    process.exit(1);
  }

  console.log("Successfully inserted sample Spanish quotes.");
  process.exit(0);
}

main().catch((err) => {
  console.error("Unexpected error:", err);
  process.exit(1);
});
