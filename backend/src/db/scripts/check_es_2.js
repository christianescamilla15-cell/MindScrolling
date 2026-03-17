import "dotenv/config";
import { createClient } from "@supabase/supabase-js";

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_ANON_KEY
);

async function check() {
  const { count, error } = await supabase
    .from("quotes")
    .select("*", { count: "exact", head: true })
    .eq("lang", "es");

  if (error) {
    console.error("Error:", error.message);
  } else {
    console.log("Spanish quote count:", count);
  }
}
check();
