import { supabase } from "../db/client.js";

// Map category names to the score column they influence most
const CATEGORY_SCORE_MAP = {
  stoicism:    "wisdom_score",
  philosophy:  "philosophy_score",
  discipline:  "discipline_score",
  reflection:  "reflection_score",
};

const CATEGORIES = ["stoicism", "philosophy", "discipline", "reflection"];
const BASE_WEIGHT = 5;

export default async function quotesRoutes(fastify) {
  /**
   * GET /quotes/feed
   * Query params: lang (default "en"), cursor (last seen quote id), limit (default 10, max 20)
   */
  fastify.get("/feed", async (request, reply) => {
    const { lang = "en", cursor, limit = 10 } = request.query;
    const deviceId = request.deviceId;
    const take = Math.min(Number(limit), 20);

    // ── 1. Fetch user profile ──────────────────────────────────────────────
    const { data: profile } = await supabase
      .from("user_profiles")
      .select("age_range, interest, goal, preferred_language")
      .eq("device_id", deviceId)
      .maybeSingle();

    const { interest, goal, preferred_language: profileLang } = profile ?? {};

    // ── 2. Fetch user preferences ──────────────────────────────────────────
    const { data: prefs } = await supabase
      .from("user_preferences")
      .select("category, like_count, swipe_count")
      .eq("device_id", deviceId);

    // ── 3. Get last 500 seen quote IDs ─────────────────────────────────────
    const { data: seen } = await supabase
      .from("seen_quotes")
      .select("quote_id")
      .eq("device_id", deviceId)
      .order("seen_at", { ascending: false })
      .limit(500);

    const seenIds = (seen || []).map(r => r.quote_id);

    // ── 4. Build category affinity scores ─────────────────────────────────
    const weights = {};
    (prefs || []).forEach(p => {
      weights[p.category] = p.like_count * 3 + p.swipe_count + BASE_WEIGHT;
    });
    // Fill in missing categories with base weight
    CATEGORIES.forEach(c => {
      if (weights[c] === undefined) weights[c] = BASE_WEIGHT;
    });

    // ── 5. Apply onboarding boosts ─────────────────────────────────────────
    if (profile) {
      // Interest boost
      if (interest === "philosophy")      weights["philosophy"]  = (weights["philosophy"]  ?? BASE_WEIGHT) + 10;
      if (interest === "stoicism")        weights["stoicism"]    = (weights["stoicism"]    ?? BASE_WEIGHT) + 10;
      if (interest === "personal_growth") weights["discipline"]  = (weights["discipline"]  ?? BASE_WEIGHT) + 10;
      if (interest === "mindfulness")     weights["reflection"]  = (weights["reflection"]  ?? BASE_WEIGHT) + 10;
      if (interest === "curiosity") {
        // Spread curiosity bonus across all
        CATEGORIES.forEach(c => { weights[c] = (weights[c] ?? BASE_WEIGHT) + 3; });
      }

      // Goal boosts
      if (goal === "discipline") {
        weights["discipline"] = (weights["discipline"] ?? BASE_WEIGHT) + 8;
      }
      if (goal === "calm_mind" || goal === "mindfulness") {
        weights["stoicism"]   = (weights["stoicism"]   ?? BASE_WEIGHT) + 8;
        weights["reflection"] = (weights["reflection"] ?? BASE_WEIGHT) + 8;
      }
      if (goal === "meaning") {
        weights["philosophy"] = (weights["philosophy"] ?? BASE_WEIGHT) + 8;
      }
    }

    const total = CATEGORIES.reduce((s, c) => s + (weights[c] ?? BASE_WEIGHT), 0);

    // ── 6. Check premium status ────────────────────────────────────────────
    const { data: userRow } = await supabase
      .from("users")
      .select("is_premium")
      .eq("device_id", deviceId)
      .maybeSingle();

    const isPremium = userRow?.is_premium === true;

    // ── 7. Fetch unseen quotes ─────────────────────────────────────────────
    const effectiveLang = profileLang || lang;

    const fetchQuotes = async (excludeIds) => {
      let query = supabase
        .from("quotes")
        .select("*")
        .eq("lang", effectiveLang);

      if (!isPremium) {
        query = query.eq("is_premium", false);
      }
      if (excludeIds.length > 0) {
        query = query.not("id", "in", `(${excludeIds.join(",")})`);
      }
      if (cursor) {
        query = query.gt("id", cursor);
      }
      // Fetch a larger pool so scoring + sorting gives a meaningful result
      return query.limit(take * 5);
    };

    let { data: quotes, error } = await fetchQuotes(seenIds);

    if (error) {
      return reply.status(500).send({ error: "Failed to fetch quotes", code: "DB_ERROR" });
    }

    // Handle edge case: no unseen quotes — clear seen list and restart
    if (!quotes || quotes.length === 0) {
      await supabase.from("seen_quotes").delete().eq("device_id", deviceId);
      const { data: fresh, error: freshErr } = await fetchQuotes([]);
      if (freshErr) {
        return reply.status(500).send({ error: "Failed to fetch quotes", code: "DB_ERROR" });
      }
      quotes = fresh || [];
    }

    if (quotes.length === 0) {
      return reply.send({ data: [], next_cursor: null, has_more: false });
    }

    // ── 8. Get last 3 seen authors to penalise same-author repeats ─────────
    const { data: recentSeen } = await supabase
      .from("seen_quotes")
      .select("quote_id, seen_at, quotes(author)")
      .eq("device_id", deviceId)
      .order("seen_at", { ascending: false })
      .limit(3);

    const recentAuthors = new Set(
      (recentSeen || []).map(r => r.quotes?.author).filter(Boolean)
    );

    // ── 9. Score and sort ─────────────────────────────────────────────────
    const scored = quotes
      .map(q => {
        const categoryWeight = weights[q.category] ?? BASE_WEIGHT;
        const normalised     = total > 0 ? categoryWeight / total : 0;
        let score            = normalised * 0.35;
        score               += Math.random() * 0.05;
        if (recentAuthors.has(q.author)) score -= 0.1;
        return { ...q, _score: score };
      })
      .sort((a, b) => b._score - a._score)
      .slice(0, take);

    // ── 10. Mark as seen ──────────────────────────────────────────────────
    const seenInserts = scored.map(q => ({ device_id: deviceId, quote_id: q.id }));
    await supabase.from("seen_quotes").upsert(seenInserts, { onConflict: "device_id,quote_id" });

    const last = scored[scored.length - 1];
    return reply.send({
      data:        scored.map(({ _score, ...q }) => q),
      next_cursor: last?.id ?? null,
      has_more:    scored.length === take,
    });
  });
}
