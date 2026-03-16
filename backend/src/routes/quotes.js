import { supabase }              from "../db/client.js";
import { getPreferenceVector }   from "../services/embeddings.js";

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
    const { lang = "en", limit = 20 } = request.query;
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
        .select("is_premium")
        .eq("device_id", deviceId)
        .maybeSingle(),

      supabase
        .from("daily_challenges")
        .select("category")
        .eq("active_date", new Date().toISOString().slice(0, 10))
        .maybeSingle(),

      getPreferenceVector(deviceId),   // null for new users
    ]);

    const isPremium         = userRow?.is_premium === true;
    const effectiveLang     = profile?.preferred_language || lang;
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

    if (rpcErr) {
      return reply.status(500).send({ error: "Failed to fetch quotes", code: "DB_ERROR" });
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
        return reply.status(500).send({ error: "Failed to fetch quotes", code: "DB_ERROR" });
      }
      candidates = fresh || [];
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
      data:        selected.map(({ _score, _similarity, similarity, ...q }) => q),
      next_cursor: last?.id ?? null,
      has_more:    candidates.length >= poolSize,
      algorithm:   hasVector ? "hybrid" : "behavioural",   // visible in dev for debugging
    });
  });
}
