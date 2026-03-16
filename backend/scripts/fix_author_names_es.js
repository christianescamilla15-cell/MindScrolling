/**
 * fix_author_names_es.js
 *
 * Updates author names in Spanish quotes to their proper Spanish equivalents.
 * e.g., "Plato" → "Platón", "Aristotle" → "Aristóteles"
 *
 * Usage:
 *   node scripts/fix_author_names_es.js              # apply fixes
 *   node scripts/fix_author_names_es.js --dry-run    # preview changes
 */

import "dotenv/config";
import { createClient } from "@supabase/supabase-js";

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_ANON_KEY);
const DRY_RUN = process.argv.includes("--dry-run");

// English name → Spanish name mapping for authors commonly translated
const AUTHOR_MAP = {
  // Greek philosophers
  "Plato":                   "Platón",
  "Aristotle":               "Aristóteles",
  "Socrates":                "Sócrates",
  "Heraclitus":              "Heráclito",
  "Democritus":              "Demócrito",
  "Epicurus":                "Epicuro",
  "Epictetus":               "Epicteto",
  "Diogenes":                "Diógenes",
  "Pythagoras":              "Pitágoras",
  "Thales":                  "Tales de Mileto",
  "Xenophon":                "Jenofonte",
  "Plutarch":                "Plutarco",
  "Thucydides":              "Tucídides",
  "Aeschylus":               "Esquilo",
  "Sophocles":               "Sófocles",
  "Euripides":               "Eurípides",

  // Roman philosophers/writers
  "Seneca":                  "Séneca",
  "Marcus Aurelius":         "Marco Aurelio",
  "Cicero":                  "Cicerón",
  "Virgil":                  "Virgilio",
  "Horace":                  "Horacio",
  "Ovid":                    "Ovidio",
  "Lucretius":               "Lucrecio",
  "Tacitus":                 "Tácito",
  "Pliny the Elder":         "Plinio el Viejo",

  // Eastern philosophers
  "Confucius":               "Confucio",
  "Lao Tzu":                 "Lao Tse",
  "Sun Tzu":                 "Sun Tzu",
  "Buddha":                  "Buda",

  // Medieval/Renaissance
  "Saint Augustine":         "San Agustín",
  "St. Augustine":           "San Agustín",
  "Thomas Aquinas":          "Santo Tomás de Aquino",
  "Francis of Assisi":       "San Francisco de Asís",
  "Machiavelli":             "Maquiavelo",
  "Nicolaus Copernicus":     "Nicolás Copérnico",

  // Modern European philosophers
  "René Descartes":          "René Descartes",
  "Immanuel Kant":           "Immanuel Kant",
  "Friedrich Nietzsche":     "Friedrich Nietzsche",
  "Arthur Schopenhauer":     "Arthur Schopenhauer",
  "Georg Wilhelm Friedrich Hegel": "Georg Wilhelm Friedrich Hegel",
  "Baruch Spinoza":          "Baruch Spinoza",
  "Voltaire":                "Voltaire",
  "Jean-Jacques Rousseau":   "Jean-Jacques Rousseau",
  "Blaise Pascal":           "Blaise Pascal",
  "Michel de Montaigne":     "Michel de Montaigne",
  "Søren Kierkegaard":       "Søren Kierkegaard",

  // 20th century thinkers (some have Spanish conventions)
  "Albert Camus":            "Albert Camus",
  "Jean-Paul Sartre":        "Jean-Paul Sartre",
  "Simone de Beauvoir":      "Simone de Beauvoir",
  "Hannah Arendt":           "Hannah Arendt",

  // Historical figures
  "Alexander the Great":     "Alejandro Magno",
  "Julius Caesar":           "Julio César",
  "Christopher Columbus":    "Cristóbal Colón",
  "Joan of Arc":             "Juana de Arco",
  "Charles V":               "Carlos V",
  "Philip II":               "Felipe II",
  "Queen Elizabeth I":        "Reina Isabel I",
  "King Solomon":            "Rey Salomón",

  // Scientists
  "Galileo Galilei":         "Galileo Galilei",
  "Isaac Newton":            "Isaac Newton",
  "Albert Einstein":         "Albert Einstein",
  "Charles Darwin":          "Charles Darwin",
  "Nikola Tesla":            "Nikola Tesla",
  "Leonardo da Vinci":       "Leonardo da Vinci",
  "Marie Curie":             "Marie Curie",
  "Stephen Hawking":         "Stephen Hawking",

  // Writers
  "William Shakespeare":     "William Shakespeare",
  "Victor Hugo":             "Víctor Hugo",
  "Leo Tolstoy":             "León Tolstói",
  "Fyodor Dostoevsky":       "Fiódor Dostoyevski",
  "Homer":                   "Homero",
  "Dante Alighieri":         "Dante Alighieri",
  "Charles Dickens":         "Charles Dickens",
  "Mark Twain":              "Mark Twain",
  "Oscar Wilde":             "Oscar Wilde",
  "George Orwell":           "George Orwell",
  "Franz Kafka":             "Franz Kafka",
  "Herman Hesse":            "Hermann Hesse",
  "Hermann Hesse":           "Hermann Hesse",
  "Antoine de Saint-Exupéry": "Antoine de Saint-Exupéry",
  "Kahlil Gibran":           "Khalil Gibran",
  "Khalil Gibran":           "Khalil Gibran",
  "Paulo Coelho":            "Paulo Coelho",
};

async function main() {
  console.log("Fetching ES quotes...");
  const all = [];
  let from = 0;
  while (true) {
    const { data, error } = await supabase
      .from("quotes")
      .select("id, author")
      .eq("lang", "es")
      .range(from, from + 999);
    if (error) throw error;
    all.push(...data);
    if (data.length < 1000) break;
    from += 1000;
  }

  console.log(`  Found ${all.length} ES quotes`);

  // Find quotes that need author name updates
  const updates = [];
  for (const q of all) {
    const spanishName = AUTHOR_MAP[q.author];
    if (spanishName && spanishName !== q.author) {
      updates.push({ id: q.id, from: q.author, to: spanishName });
    }
  }

  console.log(`  Authors to update: ${updates.length}`);

  if (updates.length === 0) {
    console.log("No author names to update!");
    return;
  }

  // Show unique changes
  const uniqueChanges = [...new Map(updates.map(u => [u.from, u])).values()];
  console.log("\nChanges:");
  uniqueChanges.forEach(u => console.log(`  ${u.from} → ${u.to}`));

  if (DRY_RUN) {
    console.log("\n[DRY RUN] No changes written.");
    return;
  }

  let fixed = 0;
  let errors = 0;

  for (const { id, to } of updates) {
    const { error } = await supabase
      .from("quotes")
      .update({ author: to })
      .eq("id", id);

    if (error) {
      console.error(`  Error updating ${id}: ${error.message}`);
      errors++;
    } else {
      fixed++;
    }
  }

  console.log(`\nDone! Updated: ${fixed} | Errors: ${errors}`);
}

main().catch(e => {
  console.error("Fatal:", e);
  process.exit(1);
});
