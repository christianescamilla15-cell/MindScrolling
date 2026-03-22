/**
 * insight.js — Insight emotional matching endpoint
 *
 * Provides personalized quote recommendations based on user emotional input.
 * Available only to Inside (premium) users.
 *
 * Endpoint:
 *   POST /insight/match — returns top quotes matching emotional input text
 */

import { supabase } from "../db/client.js";
import { authorSlug, normalizeLang } from "../utils/validation.js";

// ─── Emotion keyword map ─────────────────────────────────────────────────────
// Maps user input keywords to emotional tags stored on quotes.
// Supports both EN and ES keywords.

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
        // Primary match gets higher weight
        const weight = i === 0 ? 3 : i === 1 ? 2 : 1;
        tagScores[tags[i]] = (tagScores[tags[i]] ?? 0) + weight;
      }
    }
  }

  return tagScores;
}

// ─── Route ────────────────────────────────────────────────────────────────────

export default async function insightRoutes(fastify) {
  /**
   * POST /insight/match
   *
   * Body: { text: string, lang?: string, limit?: number }
   * Returns: { quote_of_day: QuoteModel | null, tags_detected: string[], data: QuoteModel[] }
   */
  fastify.post("/match", async (request, reply) => {
    const { deviceId } = request;
    const { text = "", lang = "en", limit = 10 } = request.body ?? {};
    const effectiveLang = normalizeLang(lang);
    const take = Math.min(Math.max(Number(limit) || 10, 1), 20);

    if (!text || typeof text !== "string" || text.trim().length === 0) {
      // Empty input — return a random premium quote as suggestion
      const { data: randomQuotes } = await supabase
        .from("quotes")
        .select("id, text, author, category, lang, swipe_dir, pack_name, is_premium, content_type, tags")
        .eq("lang", effectiveLang)
        .eq("is_hidden_mode", false)
        .limit(take);

      return reply.send({
        quote_of_day: randomQuotes?.[0] ? { ...randomQuotes[0], author_slug: authorSlug(randomQuotes[0].author) } : null,
        tags_detected: [],
        data: (randomQuotes ?? []).map(q => ({ ...q, author_slug: authorSlug(q.author) })),
      });
    }

    // Extract emotional tags from input
    const tagScores = extractEmotionalTags(text.trim());
    const detectedTags = Object.entries(tagScores)
      .sort((a, b) => b[1] - a[1])
      .map(([tag]) => tag);

    if (detectedTags.length === 0) {
      // No tags matched — return random quotes
      const { data: randomQuotes } = await supabase
        .from("quotes")
        .select("id, text, author, category, lang, swipe_dir, pack_name, is_premium, content_type, tags")
        .eq("lang", effectiveLang)
        .eq("is_hidden_mode", false)
        .limit(take);

      return reply.send({
        quote_of_day: randomQuotes?.[0] ? { ...randomQuotes[0], author_slug: authorSlug(randomQuotes[0].author) } : null,
        tags_detected: [],
        data: (randomQuotes ?? []).map(q => ({ ...q, author_slug: authorSlug(q.author) })),
      });
    }

    // Query quotes that have overlapping tags — use the top 3 detected tags
    const topTags = detectedTags.slice(0, 3);
    const poolSize = take * 4;

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
      return reply.send({
        quote_of_day: null,
        tags_detected: detectedTags,
        data: [],
      });
    }

    // Score candidates by tag overlap with detected emotions
    const scored = candidates.map(q => {
      const quoteTags = q.tags ?? [];
      let score = 0;
      for (const tag of quoteTags) {
        score += tagScores[tag] ?? 0;
      }
      // Bonus for premium content (Inside users get the best matches)
      if (q.is_premium) score += 1;
      // Small noise for variety
      score += Math.random() * 0.5;
      return { ...q, _score: score };
    });

    scored.sort((a, b) => b._score - a._score);
    const selected = scored.slice(0, take);

    // Quote of the day = highest scoring quote
    const qotd = selected[0];

    return reply.send({
      quote_of_day: qotd ? { ...qotd, author_slug: authorSlug(qotd.author), _score: undefined } : null,
      tags_detected: detectedTags,
      data: selected.map(({ _score, ...q }) => ({ ...q, author_slug: authorSlug(q.author) })),
    });
  });
}
