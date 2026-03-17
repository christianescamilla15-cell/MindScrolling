import { supabase } from "../db/client.js";

export default async function authorsRoutes(fastify) {
  /**
   * GET /authors/:name
   * Returns author profile with bio and top quotes.
   * Query: ?lang=en|es
   */
  fastify.get("/:name", async (request, reply) => {
    const { name } = request.params;
    const lang = request.query.lang || "en";

    if (!name) {
      return reply.status(400).send({ error: "Author name required", code: "MISSING_FIELD" });
    }

    const decodedName = decodeURIComponent(name);

    // Get quotes by this author
    const { data: quotes, error } = await supabase
      .from("quotes")
      .select("id, text, category, lang")
      .eq("author", decodedName)
      .eq("lang", lang)
      .order("created_at", { ascending: false })
      .limit(20);

    if (error) {
      return reply.status(500).send({ error: "Failed to fetch author", code: "DB_ERROR" });
    }

    // Count total quotes
    const { count } = await supabase
      .from("quotes")
      .select("*", { count: "exact", head: true })
      .eq("author", decodedName)
      .eq("lang", lang);

    // Category distribution
    const categories = {};
    (quotes || []).forEach((q) => {
      categories[q.category] = (categories[q.category] || 0) + 1;
    });

    // Dominant category
    const dominant = Object.entries(categories)
      .sort(([, a], [, b]) => b - a)[0]?.[0] ?? "philosophy";

    // Generate bio from known authors
    const bio = getAuthorBio(decodedName, lang);

    return reply.send({
      name: decodedName,
      bio,
      total_quotes: count || 0,
      dominant_category: dominant,
      categories,
      top_quotes: (quotes || []).slice(0, 5).map((q) => ({
        id: q.id,
        text: q.text,
        category: q.category,
      })),
    });
  });
}

/**
 * Returns a short bio for known authors. Falls back to a generic description.
 */
function getAuthorBio(name, lang) {
  const bios = {
    en: {
      "Marcus Aurelius": "Roman Emperor (161-180 AD) and Stoic philosopher. His 'Meditations' remain one of the most influential works of philosophy.",
      "Seneca": "Roman Stoic philosopher, statesman, and dramatist. Advisor to Emperor Nero, known for his essays on ethics and morality.",
      "Epictetus": "Born a slave, became one of the most influential Stoic philosophers. His teachings emphasize what is within our control.",
      "Plato": "Athenian philosopher, student of Socrates, teacher of Aristotle. Founded the Academy, the first institution of higher learning in the Western world.",
      "Aristotle": "Greek philosopher and polymath. Student of Plato, tutor of Alexander the Great. His works cover logic, metaphysics, ethics, and politics.",
      "Socrates": "Classical Greek philosopher, considered the founder of Western philosophy. Known for the Socratic method of questioning.",
      "Friedrich Nietzsche": "German philosopher known for challenging traditional morality. Author of 'Thus Spoke Zarathustra' and 'Beyond Good and Evil'.",
      "Albert Einstein": "Theoretical physicist who developed the theory of relativity. Nobel Prize laureate and one of the most influential thinkers of the 20th century.",
      "Confucius": "Chinese philosopher and teacher whose philosophy emphasized personal morality, social relationships, and justice.",
      "Buddha": "Spiritual teacher from ancient India who founded Buddhism. His teachings focus on overcoming suffering through mindfulness and wisdom.",
      "Lao Tzu": "Ancient Chinese philosopher, author of the 'Tao Te Ching', and founder of Taoism.",
      "Albert Camus": "French-Algerian philosopher and author. Nobel Prize winner known for works on absurdism like 'The Stranger' and 'The Myth of Sisyphus'.",
    },
    es: {
      "Marco Aurelio": "Emperador romano (161-180 d.C.) y fil\u00f3sofo estoico. Sus 'Meditaciones' siguen siendo una de las obras filos\u00f3ficas m\u00e1s influyentes.",
      "S\u00e9neca": "Fil\u00f3sofo estoico romano, estadista y dramaturgo. Consejero del emperador Ner\u00f3n, conocido por sus ensayos sobre \u00e9tica y moralidad.",
      "Epicteto": "Nacido esclavo, se convirti\u00f3 en uno de los fil\u00f3sofos estoicos m\u00e1s influyentes. Sus ense\u00f1anzas enfatizan lo que est\u00e1 bajo nuestro control.",
      "Plat\u00f3n": "Fil\u00f3sofo ateniense, disc\u00edpulo de S\u00f3crates y maestro de Arist\u00f3teles. Fund\u00f3 la Academia, la primera instituci\u00f3n de educaci\u00f3n superior del mundo occidental.",
      "Arist\u00f3teles": "Fil\u00f3sofo y polimata griego. Disc\u00edpulo de Plat\u00f3n, tutor de Alejandro Magno. Sus obras abarcan l\u00f3gica, metaf\u00edsica, \u00e9tica y pol\u00edtica.",
      "S\u00f3crates": "Fil\u00f3sofo griego cl\u00e1sico, considerado el fundador de la filosof\u00eda occidental. Conocido por el m\u00e9todo socr\u00e1tico de interrogaci\u00f3n.",
      "Friedrich Nietzsche": "Fil\u00f3sofo alem\u00e1n conocido por desafiar la moralidad tradicional. Autor de 'As\u00ed habl\u00f3 Zaratustra'.",
      "Albert Einstein": "F\u00edsico te\u00f3rico que desarroll\u00f3 la teor\u00eda de la relatividad. Premio Nobel y uno de los pensadores m\u00e1s influyentes del siglo XX.",
      "Confucio": "Fil\u00f3sofo y maestro chino cuya filosof\u00eda enfatizaba la moralidad personal, las relaciones sociales y la justicia.",
      "Buda": "Maestro espiritual de la antigua India que fund\u00f3 el budismo. Sus ense\u00f1anzas se centran en superar el sufrimiento a trav\u00e9s de la atenci\u00f3n plena.",
      "Lao Tse": "Antiguo fil\u00f3sofo chino, autor del 'Tao Te Ching' y fundador del tao\u00edsmo.",
      "Albert Camus": "Fil\u00f3sofo y escritor franco-argelino. Premio Nobel conocido por obras sobre el absurdismo como 'El extranjero' y 'El mito de S\u00edsifo'.",
    },
  };

  const langBios = bios[lang] || bios["en"];
  return langBios[name] || (lang === "es"
    ? `Pensador y autor cuyas ideas han inspirado a generaciones.`
    : `Thinker and author whose ideas have inspired generations.`);
}
