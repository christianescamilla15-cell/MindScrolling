import { supabase }              from "../db/client.js";
import { getPreferenceVector }   from "../services/embeddings.js";
import { authorSlug, normalizeLang, UUID_RE } from "../utils/validation.js";

// ─── Constants ────────────────────────────────────────────────────────────────

const CATEGORIES       = ["stoicism", "philosophy", "discipline", "reflection"];
const BASE_WEIGHT      = 5;
const POOL_MULTIPLIER  = 8;        // fetch pool_size = take × 8 for scoring diversity
const MAX_CAT_FRACTION = 0.60;     // no single category exceeds 60% of the feed
const DWELL_TARGET_MS  = 4000;     // avg dwell at which engagement signal maxes out (4 s)
const AUTHOR_PENALTY   = 0.15;     // score deduction for same author as last 3 seen

// Onboarding boosts (added on top of behavioural weights)
const INTEREST_BOOST = {
  philosophy:      { philosophy:   10 },
  stoicism:        { stoicism:     10 },
  personal_growth: { discipline:   10 },
  mindfulness:     { reflection:   10 },
  curiosity:       { stoicism: 3, philosophy: 3, discipline: 3, reflection: 3 },
};
const GOAL_BOOST = {
  discipline:        { discipline:  8 },
  calm_mind:         { stoicism:    8, reflection: 8 },
  mindfulness:       { stoicism:    8, reflection: 8 },
  meaning:           { philosophy:  8 },
  emotional_clarity: { reflection:  8 },
};

// ─── Preference model helpers ──────────────────────────────────────────────────

/**
 * Build per-category affinity weights from behavioural signals.
 *
 *   raw = like_count × 3 + vault_count × 5 + swipe_count − skip_count × 2 + BASE_WEIGHT
 *
 * Onboarding boosts applied on top if profile exists.
 * Returns normalised map { category → 0-1 } and raw map { category → raw_weight }.
 */
function buildWeights(prefs, profile) {
  const raw = {};

  (prefs || []).forEach(p => {
    raw[p.category] =
      (p.like_count  ?? 0) * 3 +
      (p.vault_count ?? 0) * 5 +
      (p.swipe_count ?? 0)     -
      (p.skip_count  ?? 0) * 2 +
      BASE_WEIGHT;
  });

  CATEGORIES.forEach(c => { raw[c] ??= BASE_WEIGHT; });

  if (profile?.interest) {
    Object.entries(INTEREST_BOOST[profile.interest] ?? {}).forEach(([cat, delta]) => {
      raw[cat] = (raw[cat] ?? BASE_WEIGHT) + delta;
    });
  }
  if (profile?.goal) {
    Object.entries(GOAL_BOOST[profile.goal] ?? {}).forEach(([cat, delta]) => {
      raw[cat] = (raw[cat] ?? BASE_WEIGHT) + delta;
    });
  }

  const total      = CATEGORIES.reduce((s, c) => s + raw[c], 0);
  const normalised = {};
  CATEGORIES.forEach(c => { normalised[c] = total > 0 ? raw[c] / total : 0; });

  return { raw, normalised };
}

/**
 * Normalised dwell signal per category: 0–1 where 1 = avg dwell ≥ DWELL_TARGET_MS.
 */
function buildDwellSignals(prefs) {
  const signals = {};
  (prefs || []).forEach(p => {
    signals[p.category] = p.swipe_count > 0
      ? Math.min(1, (p.total_dwell_ms ?? 0) / (p.swipe_count * DWELL_TARGET_MS))
      : 0;
  });
  return signals;
}

// ─── Scoring functions ────────────────────────────────────────────────────────

/**
 * Hybrid score — used when the device has a semantic preference vector.
 *
 *   score = semantic_similarity × 0.45
 *         + category_affinity   × 0.30
 *         + dwell_signal        × 0.10
 *         + noise               × 0.10
 *         + challenge_boost     × 0.05
 *         − author_penalty (flat −0.15)
 *
 * Weights sum to 1.0 (semantic + affinity + dwell + noise + challenge = 1.0).
 */
function hybridScore(quote, { normalised, dwellSignals, recentAuthors, challengeCategory }) {
  const similarity = quote._similarity       ?? 0;
  const affinity   = normalised[quote.category] ?? 0;
  const dwell      = dwellSignals[quote.category] ?? 0;
  const noise      = Math.random();
  const challenge  = quote.category === challengeCategory ? 1 : 0;
  const penalty    = recentAuthors.has(quote.author) ? AUTHOR_PENALTY : 0;

  return similarity * 0.45 + affinity * 0.30 + dwell * 0.10 + noise * 0.10 + challenge * 0.05 - penalty;
}

/**
 * Behavioural score — fallback for new users without a preference vector.
 *
 *   score = category_affinity × 0.50
 *         + dwell_signal      × 0.20
 *         + noise             × 0.15
 *         + challenge_boost   × 0.10
 *         − author_penalty (flat −0.15)
 */
function behaviouralScore(quote, { normalised, dwellSignals, recentAuthors, challengeCategory }) {
  const affinity  = normalised[quote.category]   ?? 0;
  const dwell     = dwellSignals[quote.category] ?? 0;
  const noise     = Math.random();
  const challenge = quote.category === challengeCategory ? 1 : 0;
  const penalty   = recentAuthors.has(quote.author) ? AUTHOR_PENALTY : 0;

  return affinity * 0.50 + dwell * 0.20 + noise * 0.15 + challenge * 0.10 - penalty;
}

/**
 * Diversity cap: no category fills more than MAX_CAT_FRACTION of the batch.
 * Falls back to overflow items if diversity leaves empty slots.
 */
function applyDiversityCap(scored, take) {
  const cap      = Math.ceil(take * MAX_CAT_FRACTION);
  const catCounts = {};
  const selected  = [];
  const overflow  = [];

  for (const q of scored) {
    const count = catCounts[q.category] ?? 0;
    if (count < cap) {
      selected.push(q);
      catCounts[q.category] = count + 1;
    } else {
      overflow.push(q);
    }
    if (selected.length === take) break;
  }

  if (selected.length < take) {
    for (const q of overflow) {
      selected.push(q);
      if (selected.length === take) break;
    }
  }

  return selected;
}

// ─── Route ────────────────────────────────────────────────────────────────────

export default async function quotesRoutes(fastify) {
  /**
   * GET /quotes/feed
   * Query params:
   *   lang   — "en" | "es"       (default "en")
   *   limit  — 1–20              (default 20)
   *   cursor — opaque string     (kept for client compatibility; not used server-side)
   */
  fastify.get("/feed", async (request, reply) => {
    const { lang = "en", limit = 20, content_type = null, sub_category = null } = request.query;
    const { deviceId }  = request;
    const take          = Math.min(Math.max(Number(limit) || 20, 1), 20);
    const poolSize      = take * POOL_MULTIPLIER;

    // ── Parallel fetch: profile + preferences + premium + challenge + pref vector ──
    const [
      { data: profile },
      { data: prefs   },
      { data: userRow },
      { data: today   },
      prefVector,
    ] = await Promise.all([
      supabase
        .from("user_profiles")
        .select("age_range, interest, goal, preferred_language")
        .eq("device_id", deviceId)
        .maybeSingle(),

      supabase
        .from("user_preferences")
        .select("category, like_count, vault_count, swipe_count, skip_count, total_dwell_ms")
        .eq("device_id", deviceId),

      supabase
        .from("users")
        .select("is_premium, trial_start_date, trial_end_date")
        .eq("device_id", deviceId)
        .maybeSingle(),

      supabase
        .from("daily_challenges")
        .select("category")
        .eq("active_date", new Date().toISOString().slice(0, 10))
        .maybeSingle(),

      getPreferenceVector(deviceId),   // null for new users
    ]);

    const isTrialActive     = userRow?.trial_end_date && Date.now() < new Date(userRow.trial_end_date).getTime();
    const isPremium         = userRow?.is_premium === true || isTrialActive;
    const effectiveLang     = lang === "es" ? "es" : "en";
    const challengeCategory = today?.category ?? null;

    // ── Build scoring inputs ───────────────────────────────────────────────────
    const { normalised, raw: rawWeights } = buildWeights(prefs, profile);
    const dwellSignals                    = buildDwellSignals(prefs);

    // ── Fetch candidates: semantic (with vector) or behavioural (without) ─────
    let candidates;
    let rpcErr;
    const hasVector = Array.isArray(prefVector) && prefVector.length > 0;

    if (hasVector) {
      // Semantic retrieval: ANN search ordered by cosine similarity
      ({ data: candidates, error: rpcErr } = await supabase.rpc("match_quotes", {
        query_embedding: prefVector,
        p_device_id:     deviceId,
        p_lang:          effectiveLang,
        p_is_premium:    isPremium,
        p_pool_size:     poolSize,
      }));
    } else {
      // Behavioural retrieval: category-filtered unseen quotes
      ({ data: candidates, error: rpcErr } = await supabase.rpc("get_feed_candidates", {
        p_device_id:  deviceId,
        p_lang:       effectiveLang,
        p_is_premium: isPremium,
        p_pool_size:  poolSize,
      }));
    }

    // CRIT-03: Post-RPC content_type filter for hidden mode feeds
    // RPCs don't accept content_type param — filter in application layer
    if (candidates && (content_type || sub_category)) {
      candidates = candidates.filter(q => {
        if (content_type && q.content_type !== content_type) return false;
        if (sub_category && q.sub_category !== sub_category) return false;
        return true;
      });
    }

    // Fallback: if RPC not yet deployed, fetch balanced by category
    if (rpcErr) {
      const perCategory = Math.ceil(poolSize / CATEGORIES.length);
      const categoryQueries = CATEGORIES.map(cat => {
        let q = supabase
          .from("quotes")
          .select("id, text, author, category, lang, swipe_dir, pack_name, is_premium, created_at, content_type, tags")
          .eq("lang", effectiveLang)
          .eq("category", cat)
          // Mirror the get_feed_candidates filter: pack quotes never appear in the free feed
          .or("pack_name.eq.free,pack_name.is.null")
          .eq("is_hidden_mode", false)
          .limit(perCategory);
        if (!isPremium) q = q.eq("is_premium", false);
        // HIGH-05: Support content_type filter for hidden mode feeds
        if (content_type) q = q.eq("content_type", content_type);
        if (sub_category) q = q.eq("sub_category", sub_category);
        return q;
      });

      const results = await Promise.all(categoryQueries);
      const allQuotes = [];
      for (const { data, error: qErr } of results) {
        if (!qErr && data) allQuotes.push(...data);
      }

      // Shuffle for randomness
      for (let i = allQuotes.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [allQuotes[i], allQuotes[j]] = [allQuotes[j], allQuotes[i]];
      }

      candidates = allQuotes.slice(0, poolSize);
    }

    // ── Handle exhaustion: all quotes seen — reset seen list and restart ───────
    if (!candidates || candidates.length === 0) {
      await supabase.from("seen_quotes").delete().eq("device_id", deviceId);

      // Retry with the appropriate RPC
      const retryParams = hasVector
        ? supabase.rpc("match_quotes",         { query_embedding: prefVector, p_device_id: deviceId, p_lang: effectiveLang, p_is_premium: isPremium, p_pool_size: poolSize })
        : supabase.rpc("get_feed_candidates",  { p_device_id: deviceId, p_lang: effectiveLang, p_is_premium: isPremium, p_pool_size: poolSize });

      const { data: fresh, error: freshErr } = await retryParams;
      if (freshErr) {
        return reply.status(500).send({ error: "Failed to fetch quotes", code: "INTERNAL_ERROR" });
      }
      candidates = fresh || [];

      // HIGH-04: Apply content_type filter on retry too
      if (candidates.length > 0 && (content_type || sub_category)) {
        candidates = candidates.filter(q => {
          if (content_type && q.content_type !== content_type) return false;
          if (sub_category && q.sub_category !== sub_category) return false;
          return true;
        });
      }
    }

    if (candidates.length === 0) {
      return reply.send({ data: [], next_cursor: null, has_more: false });
    }

    // ── Fetch last 3 seen authors for author-repeat penalty ───────────────────
    const { data: recentSeen } = await supabase
      .from("seen_quotes")
      .select("quotes(author)")
      .eq("device_id", deviceId)
      .order("seen_at", { ascending: false })
      .limit(3);

    const recentAuthors = new Set(
      (recentSeen || []).map(r => r.quotes?.author).filter(Boolean)
    );

    const scoreCtx = { normalised, dwellSignals, recentAuthors, challengeCategory };
    const scoreFn  = hasVector ? hybridScore : behaviouralScore;

    // ── Score, sort, diversify, shuffle ───────────────────────────────────────
    const scored = candidates
      .map(q => ({
        ...q,
        _similarity: q.similarity ?? 0,   // present only from match_quotes
        _score:      scoreFn(q, scoreCtx),
      }))
      .sort((a, b) => b._score - a._score);

    const selected = applyDiversityCap(scored, take);
    selected.sort(() => Math.random() - 0.5);   // shuffle to prevent category clustering

    // ── Mark selected quotes as seen ──────────────────────────────────────────
    const seenInserts = selected.map(q => ({ device_id: deviceId, quote_id: q.id }));
    await supabase.from("seen_quotes").upsert(seenInserts, { onConflict: "device_id,quote_id" });

    const last = selected[selected.length - 1];
    return reply.send({
      data:        selected.map(({ _score, _similarity, similarity, ...q }) => ({
        ...q,
        author_slug: authorSlug(q.author),
        content_type: q.content_type ?? 'philosophical',
        tags: q.tags ?? [],
      })),
      next_cursor: last?.id ?? null,
      has_more:    candidates.length >= poolSize,
      algorithm:   hasVector ? "hybrid" : "behavioural",   // visible in dev for debugging
    });
  });

  // ─────────────────────────────────────────────────────────────────────────────
  /**
   * GET /quotes/daily-pick?lang=en
   *
   * Returns a single personalized daily quote for the device.
   * The pick is cached in `analytics_events` (event_type='daily_pick') so the
   * same quote is served for the entire calendar day regardless of how many
   * times the endpoint is called.
   *
   * Algorithm:
   *   1. If a pick already exists for today + deviceId, return it immediately.
   *   2. If the device has a preference vector, use match_quotes (pool_size=5)
   *      and take the top result → algorithm: 'semantic'.
   *   3. Otherwise pick a random premium quote → algorithm: 'random'.
   *
   * Response: { quote: QuoteModel, picked_at: ISO string, algorithm: string }
   */
  fastify.get("/daily-pick", async (request, reply) => {
    const { lang = "en" } = request.query;
    const { deviceId }    = request;
    const effectiveLang   = normalizeLang(lang);
    const today           = new Date().toISOString().slice(0, 10);   // "YYYY-MM-DD"
    const nextDay         = new Date(Date.now() + 86400000).toISOString().slice(0, 10);

    // CRIT-02 fix: resolve premium status for entitlement gating
    const { data: userRow } = await supabase
      .from("users")
      .select("is_premium, trial_end_date")
      .eq("device_id", deviceId)
      .maybeSingle();
    const isTrialActive = userRow?.trial_end_date && Date.now() < new Date(userRow.trial_end_date).getTime();
    const isPremium     = userRow?.is_premium === true || isTrialActive;

    // ── 1. Check cache: has a pick already been made today? ──────────────────
    const { data: cached, error: cacheErr } = await supabase
      .from("analytics_events")
      .select("properties, created_at")
      .eq("device_id", deviceId)
      .eq("event_type", "daily_pick")
      .gte("created_at", `${today}T00:00:00.000Z`)
      .lt("created_at",  `${nextDay}T00:00:00.000Z`)
      .order("created_at", { ascending: false })
      .limit(1)
      .maybeSingle();

    if (cacheErr) {
      fastify.log.warn({ err: cacheErr }, "daily-pick: cache lookup failed");
    }

    if (cached?.properties?.quote_id) {
      // Return the cached quote
      const { data: cachedQuote, error: quoteErr } = await supabase
        .from("quotes")
        .select("id, text, author, category, lang, swipe_dir, pack_name, is_premium, content_type, tags")
        .eq("id", cached.properties.quote_id)
        .maybeSingle();

      if (!quoteErr && cachedQuote) {
        return reply.send({
          quote: {
            ...cachedQuote,
            author_slug:  authorSlug(cachedQuote.author),
            content_type: cachedQuote.content_type ?? "philosophical",
            tags:         cachedQuote.tags ?? [],
          },
          picked_at: cached.created_at,
          algorithm: cached.properties.algorithm ?? "cached",
        });
      }
      // Cached quote ID no longer valid — fall through to generate a new pick
    }

    // ── 2. Generate a new pick ────────────────────────────────────────────────
    const prefVector = await getPreferenceVector(deviceId);
    const hasVector  = Array.isArray(prefVector) && prefVector.length > 0;

    let pickedQuote = null;
    let algorithm   = "random";

    if (hasVector) {
      // Semantic: use ANN search with pool_size=5, take the closest match
      const { data: semanticPool, error: rpcErr } = await supabase.rpc("match_quotes", {
        query_embedding: prefVector,
        p_device_id:     deviceId,
        p_lang:          effectiveLang,
        p_is_premium:    isPremium,
        p_pool_size:     5,
      });

      if (!rpcErr && semanticPool?.length > 0) {
        pickedQuote = semanticPool[0];
        algorithm   = "semantic";
      }
    }

    if (!pickedQuote) {
      // L-05: Random fallback respects premium entitlement
      let randomQuery = supabase
        .from("quotes")
        .select("id, text, author, category, lang, swipe_dir, pack_name, is_premium, content_type, tags")
        .eq("lang", effectiveLang)
        .eq("is_hidden_mode", false)
        .or("pack_name.eq.free,pack_name.is.null")
        .limit(50);
      if (!isPremium) randomQuery = randomQuery.eq("is_premium", false);
      const { data: randomPool, error: randErr } = await randomQuery;

      if (randErr || !randomPool?.length) {
        return reply.status(500).send({ error: "Failed to fetch daily pick", code: "INTERNAL_ERROR" });
      }

      pickedQuote = randomPool[Math.floor(Math.random() * randomPool.length)];
    }

    // ── 3. Cache the pick as an analytics event (awaited to prevent race) ─────
    const pickedAt = new Date().toISOString();
    try {
      await supabase
        .from("analytics_events")
        .insert({
          device_id:  deviceId,
          event_type: "daily_pick",
          properties: { quote_id: pickedQuote.id, algorithm, lang: effectiveLang },
        });
    } catch (cacheWriteErr) {
      fastify.log.warn({ err: cacheWriteErr }, "daily-pick: failed to persist pick cache");
    }

    return reply.send({
      quote: {
        ...pickedQuote,
        author_slug:  authorSlug(pickedQuote.author),
        content_type: pickedQuote.content_type ?? "philosophical",
        tags:         pickedQuote.tags ?? [],
        // Strip internal similarity field if it came from RPC
        similarity:   undefined,
      },
      picked_at: pickedAt,
      algorithm,
    });
  });

  // ─────────────────────────────────────────────────────────────────────────────
  /**
   * GET /quotes/:id/similar?lang=en&limit=5
   *
   * Returns quotes semantically similar to the given source quote.
   *
   * Algorithm:
   *   1. Fetch the source quote's embedding.
   *   2. If embedding exists: call match_quotes (pool_size = limit*3), filter
   *      out the source quote itself → algorithm: 'semantic'.
   *   3. If no embedding: same-category + overlapping-tags fallback
   *      → algorithm: 'category_tags'.
   *
   * Response: { source_id: string, data: QuoteModel[], algorithm: string }
   */
  fastify.get("/:id/similar", async (request, reply) => {
    const { id }          = request.params;
    const { lang = "en", limit = 5 } = request.query;
    const { deviceId }    = request;
    const effectiveLang   = normalizeLang(lang);
    const take            = Math.min(Math.max(Number(limit) || 5, 1), 20);

    if (!UUID_RE.test(id)) {
      return reply.status(400).send({ error: "Invalid quote id", code: "INVALID_ID" });
    }

    // CRIT-02 fix: resolve premium status
    const { data: simUserRow } = await supabase
      .from("users")
      .select("is_premium, trial_end_date")
      .eq("device_id", deviceId)
      .maybeSingle();
    const simTrialActive = simUserRow?.trial_end_date && Date.now() < new Date(simUserRow.trial_end_date).getTime();
    const simIsPremium   = simUserRow?.is_premium === true || simTrialActive;

    // ── 1. Fetch source quote (need embedding, category, tags) ────────────────
    const { data: source, error: srcErr } = await supabase
      .from("quotes")
      .select("id, category, tags, embedding")
      .eq("id", id)
      .maybeSingle();

    if (srcErr) {
      fastify.log.error({ err: srcErr }, "similar: DB error fetching source quote");
      return reply.status(500).send({ error: "Failed to fetch quote", code: "INTERNAL_ERROR" });
    }

    if (!source) {
      return reply.status(404).send({ error: "Quote not found", code: "NOT_FOUND" });
    }

    // M-03: Extract embedding for RPC, discard from object to prevent accidental logging
    const { embedding: sourceEmbedding, ...sourcePublic } = source;
    const hasEmbedding = Array.isArray(sourceEmbedding) && sourceEmbedding.length > 0;
    const poolSize     = take * 3;

    // ── 2a. Semantic path ─────────────────────────────────────────────────────
    if (hasEmbedding) {
      const { data: pool, error: rpcErr } = await supabase.rpc("match_quotes", {
        query_embedding: sourceEmbedding,
        p_device_id:     deviceId,
        p_lang:          effectiveLang,
        p_is_premium:    simIsPremium,
        p_pool_size:     poolSize + 1,   // +1 because we filter out the source
      });

      if (!rpcErr && pool?.length > 0) {
        const similar = pool
          .filter(q => q.id !== id)
          .slice(0, take)
          .map(({ similarity, ...q }) => ({
            ...q,
            author_slug:  authorSlug(q.author),
            content_type: q.content_type ?? "philosophical",
            tags:         q.tags ?? [],
          }));

        return reply.send({ source_id: id, data: similar, algorithm: "semantic" });
      }
    }

    // ── 2b. Fallback: same category + overlapping tags ────────────────────────
    const sourceTags = sourcePublic.tags ?? [];

    let fallbackQuery = supabase
      .from("quotes")
      .select("id, text, author, category, lang, swipe_dir, pack_name, is_premium, content_type, tags")
      .eq("lang", effectiveLang)
      .eq("is_hidden_mode", false)
      .eq("category", sourcePublic.category)
      .neq("id", id)
      .limit(poolSize);

    // Narrow to overlapping tags only when the source quote has tags
    if (sourceTags.length > 0) {
      fallbackQuery = fallbackQuery.overlaps("tags", sourceTags);
    }

    const { data: fallbackPool, error: fallErr } = await fallbackQuery;

    if (fallErr) {
      fastify.log.error({ err: fallErr }, "similar: DB error in fallback query");
      return reply.status(500).send({ error: "Failed to fetch similar quotes", code: "INTERNAL_ERROR" });
    }

    // Shuffle for variety and trim to requested limit
    const shuffled = (fallbackPool ?? []).sort(() => Math.random() - 0.5).slice(0, take);

    return reply.send({
      source_id: id,
      data: shuffled.map(q => ({
        ...q,
        author_slug:  authorSlug(q.author),
        content_type: q.content_type ?? "philosophical",
        tags:         q.tags ?? [],
      })),
      algorithm: "category_tags",
    });
  });
}
