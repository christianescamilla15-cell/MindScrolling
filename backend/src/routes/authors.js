import { supabase } from "../db/client.js";

export default async function authorsRoutes(fastify) {
  /**
   * GET /authors
   * Returns all authors ordered by name.
   * Query: ?lang=en|es
   */
  fastify.get("/", async (request, reply) => {
    const lang = request.query.lang || "en";
    const bioCol = lang === "es" ? "bio_es" : "bio_en";

    const { data, error } = await supabase
      .from("authors")
      .select(`slug, name, ${bioCol}, quote_count`)
      .order("name", { ascending: true });

    if (error) {
      fastify.log.error({ err: error }, "GET /authors — DB error");
      return reply.status(500).send({ error: "Failed to fetch authors", code: "DB_ERROR" });
    }

    return reply.send(
      (data || []).map((a) => ({
        slug: a.slug,
        name: a.name,
        bio: a[bioCol] || null,
        quote_count: a.quote_count,
      }))
    );
  });

  /**
   * GET /authors/:slug
   * Returns author profile (bio + top quotes) by slug.
   * Query: ?lang=en|es
   *
   * Response shape is backward-compatible with the previous /:name endpoint.
   * Flutter still receives: { name, bio, total_quotes, dominant_category, categories, top_quotes }
   */
  fastify.get("/:slug", async (request, reply) => {
    const { slug } = request.params;
    const lang = request.query.lang || "en";
    const bioCol = lang === "es" ? "bio_es" : "bio_en";

    if (!slug) {
      return reply.status(400).send({ error: "Author slug required", code: "MISSING_FIELD" });
    }

    // Fetch author row and their quotes in parallel
    const [authorResult, quotesResult] = await Promise.all([
      supabase
        .from("authors")
        .select(`slug, name, ${bioCol}, quote_count`)
        .eq("slug", slug)
        .single(),

      supabase
        .from("quotes")
        .select("id, text, category, lang, author")
        .eq("lang", lang)
        .order("created_at", { ascending: false })
        .limit(20),
    ]);

    if (authorResult.error || !authorResult.data) {
      if (authorResult.error?.code === "PGRST116") {
        return reply.status(404).send({ error: "Author not found", code: "NOT_FOUND" });
      }
      fastify.log.error({ err: authorResult.error, slug }, "GET /authors/:slug — author fetch error");
      return reply.status(500).send({ error: "Failed to fetch author", code: "DB_ERROR" });
    }

    if (quotesResult.error) {
      fastify.log.error({ err: quotesResult.error, slug }, "GET /authors/:slug — quotes fetch error");
      return reply.status(500).send({ error: "Failed to fetch author quotes", code: "DB_ERROR" });
    }

    const author = authorResult.data;

    // Filter quotes to this author (quotes table uses name, not slug)
    const authorQuotes = (quotesResult.data || []).filter(
      (q) => q.author === author.name
    );

    // Category distribution
    const categories = {};
    authorQuotes.forEach((q) => {
      categories[q.category] = (categories[q.category] || 0) + 1;
    });

    // Dominant category
    const dominant =
      Object.entries(categories).sort(([, a], [, b]) => b - a)[0]?.[0] ??
      "philosophy";

    const fallbackBio =
      lang === "es"
        ? "Pensador y autor cuyas ideas han inspirado a generaciones."
        : "Thinker and author whose ideas have inspired generations.";

    return reply.send({
      slug: author.slug,
      name: author.name,
      bio: author[bioCol] || fallbackBio,
      total_quotes: author.quote_count,
      dominant_category: dominant,
      categories,
      top_quotes: authorQuotes.slice(0, 5).map((q) => ({
        id: q.id,
        text: q.text,
        category: q.category,
      })),
    });
  });
}
