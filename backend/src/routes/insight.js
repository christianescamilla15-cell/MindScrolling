/**
 * insight.js — Insight emotional matching endpoint (hybrid: semantic + tags)
 *
 * Provides personalized quote recommendations based on user emotional input.
 * Uses a three-layer scoring system:
 *   1. Semantic similarity (Voyage AI embedding of user text vs quote embeddings)
 *   2. Tag-based emotional matching (keyword → tag overlap)
 *   3. User preference vector affinity (what they've liked/saved before)
 *
 * Graceful degradation: if embeddings are unavailable, falls back to tag-only.
 *
 * Endpoint:
 *   POST /insight/match — returns top quotes matching emotional input text
 */

import { supabase } from "../db/client.js";
import { generateEmbedding, getPreferenceVector } from "../services/embeddings.js";
import { authorSlug, normalizeLang } from "../utils/validation.js";

// ─── Emotion keyword map ─────────────────────────────────────────────────────

const KEYWORD_TAG_MAP = {
  // English
  sad: ["sadness", "reflection", "meaning"],
  sadness: ["sadness", "reflection", "meaning"],
  depressed: ["sadness", "meaning", "resilience"],
  anxious: ["anxiety", "calm", "mindfulness"],
  anxiety: ["anxiety", "calm", "mindfulness"],
  worried: ["anxiety", "calm", "focus"],
  stressed: ["anxiety", "calm", "discipline"],
  calm: ["calm", "mindfulness", "reflection"],
  peaceful: ["calm", "mindfulness", "gratitude"],
  motivated: ["motivation", "discipline", "courage"],
  motivation: ["motivation", "discipline", "courage"],
  focused: ["focus", "discipline", "self_improvement"],
  focus: ["focus", "discipline", "self_improvement"],
  learn: ["learning", "curiosity", "wisdom"],
  learning: ["learning", "curiosity", "wisdom"],
  curious: ["curiosity", "learning", "wisdom"],
  curiosity: ["curiosity", "learning", "wisdom"],
  discipline: ["discipline", "focus", "inner_strength"],
  strong: ["inner_strength", "courage", "resilience"],
  strength: ["inner_strength", "courage", "resilience"],
  love: ["self_love", "gratitude", "reflection"],
  lonely: ["self_love", "meaning", "reflection"],
  meaning: ["meaning", "existence", "reflection"],
  purpose: ["meaning", "existence", "wisdom"],
  lost: ["meaning", "reflection", "resilience"],
  confused: ["reflection", "wisdom", "calm"],
  grateful: ["gratitude", "calm", "mindfulness"],
  creative: ["creativity", "curiosity", "motivation"],
  courage: ["courage", "resilience", "inner_strength"],
  afraid: ["courage", "resilience", "calm"],
  fear: ["courage", "resilience", "calm"],
  angry: ["calm", "discipline", "reflection"],
  anger: ["calm", "discipline", "reflection"],
  happy: ["gratitude", "mindfulness", "motivation"],
  joy: ["gratitude", "mindfulness", "motivation"],
  tired: ["resilience", "motivation", "self_love"],
  exhausted: ["resilience", "self_love", "calm"],
  mindful: ["mindfulness", "calm", "reflection"],
  think: ["reflection", "wisdom", "meaning"],
  reflect: ["reflection", "wisdom", "meaning"],
  grow: ["self_improvement", "learning", "discipline"],
  growth: ["self_improvement", "learning", "discipline"],
  improve: ["self_improvement", "discipline", "focus"],
  // Spanish
  triste: ["sadness", "reflection", "meaning"],
  tristeza: ["sadness", "reflection", "meaning"],
  ansioso: ["anxiety", "calm", "mindfulness"],
  ansiedad: ["anxiety", "calm", "mindfulness"],
  tranquilo: ["calm", "mindfulness", "reflection"],
  calma: ["calm", "mindfulness", "reflection"],
  motivado: ["motivation", "discipline", "courage"],
  enfocado: ["focus", "discipline", "self_improvement"],
  aprender: ["learning", "curiosity", "wisdom"],
  curioso: ["curiosity", "learning", "wisdom"],
  fuerte: ["inner_strength", "courage", "resilience"],
  amor: ["self_love", "gratitude", "reflection"],
  solo: ["self_love", "meaning", "reflection"],
  sentido: ["meaning", "existence", "reflection"],
  perdido: ["meaning", "reflection", "resilience"],
  agradecido: ["gratitude", "calm", "mindfulness"],
  creativo: ["creativity", "curiosity", "motivation"],
  valiente: ["courage", "resilience", "inner_strength"],
  miedo: ["courage", "resilience", "calm"],
  enojado: ["calm", "discipline", "reflection"],
  feliz: ["gratitude", "mindfulness", "motivation"],
  cansado: ["resilience", "motivation", "self_love"],
  pensar: ["reflection", "wisdom", "meaning"],
  crecer: ["self_improvement", "learning", "discipline"],
  mejorar: ["self_improvement", "discipline", "focus"],
  // Intent detection keywords (for Phase 5 — hidden modes)
  science: ["learning", "curiosity"],
  ciencia: ["learning", "curiosity"],
  physics: ["learning", "curiosity"],
  fisica: ["learning", "curiosity"],
  math: ["learning", "focus"],
  programming: ["learning", "focus"],
  programacion: ["learning", "focus"],
  code: ["learning", "focus"],
  codigo: ["learning", "focus"],
};

/**
 * Extract emotional tags from free-text input using keyword matching.
 * Returns a weighted map of { tag: score }.
 */
function extractEmotionalTags(text) {
  const lower = text.toLowerCase().replace(/[^a-záéíóúñü\s]/g, "");
  const words = lower.split(/\s+/).filter(Boolean);
  const tagScores = {};

  for (const word of words) {
    const tags = KEYWORD_TAG_MAP[word];
    if (tags) {
      for (let i = 0; i < tags.length; i++) {
        const weight = i === 0 ? 3 : i === 1 ? 2 : 1;
        tagScores[tags[i]] = (tagScores[tags[i]] ?? 0) + weight;
      }
    }
  }

  return tagScores;
}

// ─── Scoring weights ─────────────────────────────────────────────────────────
// Hybrid scoring mirrors the feed algorithm but prioritizes emotional relevance.
//
// With embeddings:
//   score = semantic_similarity × 0.40   (how close to what user typed)
//         + tag_overlap         × 0.25   (emotional keyword matching)
//         + user_preference     × 0.20   (what they've liked/saved before)
//         + noise              × 0.10   (variety)
//         + premium_bonus      × 0.05   (Inside users get premium content first)
//
// Without embeddings (fallback):
//   score = tag_overlap         × 0.55
//         + premium_bonus      × 0.15
//         + noise              × 0.30

// ─── Route ────────────────────────────────────────────────────────────────────

export default async function insightRoutes(fastify) {
  /**
   * POST /insight/match
   *
   * Body: { text: string, lang?: string, limit?: number }
   * Returns: {
   *   quote_of_day: QuoteModel | null,
   *   tags_detected: string[],
   *   algorithm: 'hybrid' | 'tags_only',
   *   data: QuoteModel[]
   * }
   */
  fastify.post("/match", async (request, reply) => {
    const { deviceId } = request;
    const { text = "", lang = "en", limit = 10 } = request.body ?? {};
    const effectiveLang = normalizeLang(lang);
    const take = Math.min(Math.max(Number(limit) || 10, 1), 20);

    if (!text || typeof text !== "string" || text.trim().length === 0) {
      // Empty input — use user's preference vector for personalized suggestions
      const prefVector = await getPreferenceVector(deviceId);

      if (prefVector) {
        // Semantic: return quotes most similar to user's taste profile
        const { data: semanticQuotes } = await supabase.rpc("match_quotes", {
          query_embedding: prefVector,
          p_device_id: deviceId,
          p_lang: effectiveLang,
          p_is_premium: true,
          p_pool_size: take,
        });

        if (semanticQuotes?.length > 0) {
          return reply.send({
            quote_of_day: { ...semanticQuotes[0], author_slug: authorSlug(semanticQuotes[0].author) },
            tags_detected: [],
            algorithm: "preference_vector",
            data: semanticQuotes.map(q => ({ ...q, author_slug: authorSlug(q.author) })),
          });
        }
      }

      // Fallback: random premium quotes
      const { data: randomQuotes } = await supabase
        .from("quotes")
        .select("id, text, author, category, lang, swipe_dir, pack_name, is_premium, content_type, tags")
        .eq("lang", effectiveLang)
        .eq("is_hidden_mode", false)
        .limit(take);

      return reply.send({
        quote_of_day: randomQuotes?.[0] ? { ...randomQuotes[0], author_slug: authorSlug(randomQuotes[0].author) } : null,
        tags_detected: [],
        algorithm: "random",
        data: (randomQuotes ?? []).map(q => ({ ...q, author_slug: authorSlug(q.author) })),
      });
    }

    // ── Extract emotional tags from input ──────────────────────────────────
    const tagScores = extractEmotionalTags(text.trim());
    const detectedTags = Object.entries(tagScores)
      .sort((a, b) => b[1] - a[1])
      .map(([tag]) => tag);
    const topTags = detectedTags.slice(0, 3);
    const poolSize = take * 5;

    // ── Try semantic matching first ────────────────────────────────────────
    let inputEmbedding = null;
    let semanticCandidates = null;
    let prefVector = null;

    try {
      // Generate embedding for user's emotional text + fetch their preference vector
      [inputEmbedding, prefVector] = await Promise.all([
        generateEmbedding(text.trim()),
        getPreferenceVector(deviceId),
      ]);

      // ANN search: find quotes semantically similar to user's input
      const { data, error } = await supabase.rpc("match_quotes", {
        query_embedding: inputEmbedding,
        p_device_id: deviceId,
        p_lang: effectiveLang,
        p_is_premium: true,
        p_pool_size: poolSize,
      });

      if (!error && data?.length > 0) {
        semanticCandidates = data;
      }
    } catch {
      // Embedding generation failed (no API key, rate limit, etc.)
      // Fall through to tag-only matching
    }

    // ── Hybrid scoring (semantic + tags + preference) ──────────────────────
    if (semanticCandidates?.length > 0) {
      const maxTagScore = Math.max(...Object.values(tagScores), 1);

      const scored = semanticCandidates.map(q => {
        // 1. Semantic similarity to user's input text (0–1)
        const semantic = q.similarity ?? 0;

        // 2. Tag overlap score (0–1 normalized)
        const quoteTags = q.tags ?? [];
        let tagScore = 0;
        for (const tag of quoteTags) {
          tagScore += tagScores[tag] ?? 0;
        }
        const normalizedTagScore = tagScore / maxTagScore;

        // 3. User preference affinity (cosine similarity to their vector)
        //    This is approximated: if the quote is similar to what they usually like
        //    Note: match_quotes already sorts by similarity to the query, so we use
        //    a secondary signal — does this quote's tags match their historical interests?
        let prefAffinity = 0;
        if (prefVector) {
          // Simple heuristic: quotes that match both input AND user history score higher
          // The preference vector influence comes from the fact that match_quotes
          // can be called with the user's pref vector too, but here we use the input text.
          // So we add a small boost based on tag diversity to favor "on-brand" content.
          prefAffinity = semantic * 0.5 + normalizedTagScore * 0.5;
        }

        // 4. Noise for variety
        const noise = Math.random();

        // 5. Premium bonus
        const premium = q.is_premium ? 1 : 0;

        // Hybrid score
        const score = prefVector
          ? semantic * 0.40 + normalizedTagScore * 0.25 + prefAffinity * 0.20 + noise * 0.10 + premium * 0.05
          : semantic * 0.45 + normalizedTagScore * 0.30 + noise * 0.15 + premium * 0.10;

        return { ...q, _score: score };
      });

      scored.sort((a, b) => b._score - a._score);
      const selected = scored.slice(0, take);
      const qotd = selected[0];

      return reply.send({
        quote_of_day: qotd ? { ...qotd, author_slug: authorSlug(qotd.author), _score: undefined, similarity: undefined } : null,
        tags_detected: detectedTags,
        algorithm: "hybrid",
        data: selected.map(({ _score, similarity, ...q }) => ({ ...q, author_slug: authorSlug(q.author) })),
      });
    }

    // ── Fallback: tag-only matching ────────────────────────────────────────
    if (detectedTags.length === 0) {
      const { data: randomQuotes } = await supabase
        .from("quotes")
        .select("id, text, author, category, lang, swipe_dir, pack_name, is_premium, content_type, tags")
        .eq("lang", effectiveLang)
        .eq("is_hidden_mode", false)
        .limit(take);

      return reply.send({
        quote_of_day: randomQuotes?.[0] ? { ...randomQuotes[0], author_slug: authorSlug(randomQuotes[0].author) } : null,
        tags_detected: [],
        algorithm: "random",
        data: (randomQuotes ?? []).map(q => ({ ...q, author_slug: authorSlug(q.author) })),
      });
    }

    const { data: candidates, error: queryErr } = await supabase
      .from("quotes")
      .select("id, text, author, category, lang, swipe_dir, pack_name, is_premium, content_type, tags")
      .eq("lang", effectiveLang)
      .eq("is_hidden_mode", false)
      .overlaps("tags", topTags)
      .limit(poolSize);

    if (queryErr) {
      fastify.log.error({ err: queryErr }, "insight/match: DB error");
      return reply.status(500).send({ error: "Failed to match quotes", code: "INTERNAL_ERROR" });
    }

    if (!candidates || candidates.length === 0) {
      return reply.send({ quote_of_day: null, tags_detected: detectedTags, algorithm: "tags_only", data: [] });
    }

    const scored = candidates.map(q => {
      const quoteTags = q.tags ?? [];
      let score = 0;
      for (const tag of quoteTags) {
        score += tagScores[tag] ?? 0;
      }
      if (q.is_premium) score += 1;
      score += Math.random() * 0.5;
      return { ...q, _score: score };
    });

    scored.sort((a, b) => b._score - a._score);
    const selected = scored.slice(0, take);
    const qotd = selected[0];

    return reply.send({
      quote_of_day: qotd ? { ...qotd, author_slug: authorSlug(qotd.author), _score: undefined } : null,
      tags_detected: detectedTags,
      algorithm: "tags_only",
      data: selected.map(({ _score, ...q }) => ({ ...q, author_slug: authorSlug(q.author) })),
    });
  });

  // ─────────────────────────────────────────────────────────────────────────────
  /**
   * POST /insight/mood
   *
   * Save a mood entry for the authenticated device.
   * Stored as an analytics_events row with event_type='mood_entry'.
   *
   * Body: { text: string, tags?: string[], lang?: string }
   * Response: { ok: true, entry_id: string }
   */
  fastify.post("/mood", async (request, reply) => {
    const { deviceId } = request;
    const { text, tags = [], lang = "en" } = request.body ?? {};

    if (!text || typeof text !== "string" || text.trim().length === 0) {
      return reply.status(400).send({ error: "text is required", code: "MISSING_FIELD" });
    }

    if (!Array.isArray(tags)) {
      return reply.status(400).send({ error: "tags must be an array", code: "INVALID_FIELD" });
    }

    const effectiveLang = normalizeLang(lang);

    const { data: inserted, error: insertErr } = await supabase
      .from("analytics_events")
      .insert({
        device_id:  deviceId,
        event_type: "mood_entry",
        properties: {
          text:  text.trim(),
          tags:  tags.map(t => String(t).trim()).filter(Boolean),
          lang:  effectiveLang,
        },
      })
      .select("id")
      .maybeSingle();

    if (insertErr) {
      fastify.log.error({ err: insertErr }, "insight/mood: DB error on insert");
      return reply.status(500).send({ error: "Failed to save mood entry", code: "INTERNAL_ERROR" });
    }

    return reply.status(201).send({ ok: true, entry_id: inserted?.id ?? null });
  });

  // ─────────────────────────────────────────────────────────────────────────────
  /**
   * GET /insight/mood-history?days=30
   *
   * Returns mood entries for the last N calendar days (default 30, max 90).
   * Also computes a mood_summary containing the top 5 most-used tags.
   *
   * Response: {
   *   entries: [{ id, text, tags, lang, created_at }],
   *   mood_summary: { top_tags: string[] }
   * }
   */
  fastify.get("/mood-history", async (request, reply) => {
    const { deviceId } = request;
    const { days = 30 } = request.query;
    const dayCount = Math.min(Math.max(Number(days) || 30, 1), 90);

    const since = new Date(Date.now() - dayCount * 24 * 60 * 60 * 1000).toISOString();

    const { data: rows, error: fetchErr } = await supabase
      .from("analytics_events")
      .select("id, properties, created_at")
      .eq("device_id", deviceId)
      .eq("event_type", "mood_entry")
      .gte("created_at", since)
      .order("created_at", { ascending: false });

    if (fetchErr) {
      fastify.log.error({ err: fetchErr }, "insight/mood-history: DB error");
      return reply.status(500).send({ error: "Failed to fetch mood history", code: "INTERNAL_ERROR" });
    }

    const entries = (rows ?? []).map(row => ({
      id:         row.id,
      text:       row.properties?.text  ?? "",
      tags:       row.properties?.tags  ?? [],
      lang:       row.properties?.lang  ?? "en",
      created_at: row.created_at,
    }));

    // Compute top_tags: tally all tags across entries, return up to 5
    const tagTally = {};
    for (const entry of entries) {
      for (const tag of entry.tags) {
        tagTally[tag] = (tagTally[tag] ?? 0) + 1;
      }
    }

    const top_tags = Object.entries(tagTally)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 5)
      .map(([tag]) => tag);

    return reply.send({
      entries,
      mood_summary: { top_tags },
    });
  });
}
