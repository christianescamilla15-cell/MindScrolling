import { supabase } from "../db/client.js";

const PACK_META = {
  stoicism_deep: {
    nameEn: "Stoicism Deep Dive",
    nameEs: "Estoicismo Profundo",
    descEn: "500+ quotes from the greatest Stoic thinkers. Marcus Aurelius, Seneca, Epictetus, and more.",
    descEs: "500+ frases de los más grandes pensadores estoicos. Marco Aurelio, Séneca, Epicteto y más.",
    icon: "shield",
    color: "#14B8A6",
  },
  existentialism: {
    nameEn: "Existentialism",
    nameEs: "Existencialismo",
    descEn: "Explore the meaning of existence through Camus, Sartre, Nietzsche, Kierkegaard, and Dostoevsky.",
    descEs: "Explora el sentido de la existencia con Camus, Sartre, Nietzsche, Kierkegaard y Dostoyevski.",
    icon: "psychology",
    color: "#A78BFA",
  },
  zen_mindfulness: {
    nameEn: "Zen & Mindfulness",
    nameEs: "Zen y Mindfulness",
    descEn: "Ancient wisdom from Buddha, Lao Tzu, Rumi, the Dalai Lama, Alan Watts, and Thich Nhat Hanh.",
    descEs: "Sabiduría ancestral de Buda, Lao Tse, Rumi, el Dalai Lama, Alan Watts y Thich Nhat Hanh.",
    icon: "self_improvement",
    color: "#22C55E",
  },
};

export default async function packsRoutes(fastify) {
  /**
   * GET /packs
   * Returns available content packs with metadata and quote counts.
   * Query: ?lang=en|es
   */
  fastify.get("/", async (request, reply) => {
    const lang = (request.query.lang || "en").slice(0, 2);

    // Get quote counts per pack
    const { data: counts, error } = await supabase
      .from("quotes")
      .select("pack_name")
      .eq("lang", lang)
      .not("pack_name", "is", null);

    if (error) {
      request.log.error({ err: error }, "packs: failed to fetch counts");
      return reply.status(500).send({ error: "Failed to load packs", code: "DB_ERROR" });
    }

    // Count per pack
    const packCounts = {};
    (counts || []).forEach((q) => {
      const p = q.pack_name;
      if (p) packCounts[p] = (packCounts[p] || 0) + 1;
    });

    // Build response
    const packs = Object.entries(PACK_META).map(([id, meta]) => ({
      id,
      name: lang === "es" ? meta.nameEs : meta.nameEn,
      description: lang === "es" ? meta.descEs : meta.descEn,
      icon: meta.icon,
      color: meta.color,
      quote_count: packCounts[id] || 0,
      is_premium: true,
    }));

    return reply.send({ packs });
  });

  /**
   * GET /packs/:id/preview
   * Returns 5 sample quotes from a pack.
   * Query: ?lang=en|es
   */
  fastify.get("/:id/preview", async (request, reply) => {
    const { id } = request.params;
    const lang = (request.query.lang || "en").slice(0, 2);

    if (!PACK_META[id]) {
      return reply.status(404).send({ error: "Pack not found", code: "NOT_FOUND" });
    }

    const { data, error } = await supabase
      .from("quotes")
      .select("id, text, author, category")
      .eq("pack_name", id)
      .eq("lang", lang)
      .limit(5);

    if (error) {
      return reply.status(500).send({ error: "Failed to load preview", code: "DB_ERROR" });
    }

    return reply.send({
      pack: {
        id,
        ...(lang === "es"
          ? { name: PACK_META[id].nameEs, description: PACK_META[id].descEs }
          : { name: PACK_META[id].nameEn, description: PACK_META[id].descEn }),
        color: PACK_META[id].color,
      },
      quotes: data || [],
    });
  });
}
