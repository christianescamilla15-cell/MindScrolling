/**
 * AI Insight Service — Claude API
 *
 * Generates a personalised weekly philosophy insight for a device.
 * Insights are cached in the `ai_insights` table for 24 hours.
 *
 * Model: claude-haiku-4-5-20251001
 *   - Fast, cost-efficient (cached insights amortize cost over 24 h)
 *   - Output is bounded to 200 tokens — no risk of long responses
 */

import Anthropic from "@anthropic-ai/sdk";
import { supabase } from "../db/client.js";

const CACHE_TTL_MS  = 24 * 60 * 60 * 1000;   // 24 hours
const MODEL         = "claude-haiku-4-5-20251001";
const MAX_TOKENS    = 220;

const client = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });

// ─── Prompt builder ───────────────────────────────────────────────────────────

function buildPrompt({ topCategory, scores, recentQuotes, streak, totalReflections, lang }) {
  const isSpanish = lang === "es";

  const catLabelsEn = {
    stoicism:    "Stoic resilience and virtue",
    discipline:  "discipline and personal growth",
    reflection:  "reflection and life meaning",
    philosophy:  "existential philosophy and ideas",
  };

  const catLabelsEs = {
    stoicism:    "resiliencia estoica y virtud",
    discipline:  "disciplina y crecimiento personal",
    reflection:  "reflexión y sentido de vida",
    philosophy:  "filosofía existencial e ideas",
  };

  const catLabels = isSpanish ? catLabelsEs : catLabelsEn;

  const quoteSamples = recentQuotes.length > 0
    ? recentQuotes
        .slice(0, 3)
        .map(q => `• "${q.text}" — ${q.author}`)
        .join("\n")
    : isSpanish ? "Aún no hay frases guardadas esta semana." : "No quotes saved this week yet.";

  const langInstruction = isSpanish
    ? "IMPORTANT: Write the entire response in Spanish."
    : "";

  return `You are a philosophical guide in MindScrolling, a mindfulness app for philosophical reflection.
${langInstruction}

A user's reading patterns this week reveal:

Dominant interest: ${catLabels[topCategory] || topCategory}
Philosophy map: Wisdom ${scores.wisdom}/100 · Discipline ${scores.discipline}/100 · Reflection ${scores.reflection}/100 · Philosophy ${scores.philosophy}/100
Reading streak: ${streak} days
Total reflections: ${totalReflections}

Quotes they saved or liked this week:
${quoteSamples}

Write a personalised philosophical insight (2–3 sentences) that:
1. Acknowledges the specific philosophical path visible in their data
2. Offers one concrete, actionable reflection or question to sit with
3. Feels like it comes from a wise human voice, not an AI

Rules:
- No hashtags, no emojis, no lists
- Reference their dominant theme naturally
- Be direct and grounded — avoid vague inspiration-speak
- Maximum 3 sentences`;
}

// ─── Cache helpers ────────────────────────────────────────────────────────────

async function getCachedInsight(deviceId, lang = "en") {
  const { data } = await supabase
    .from("ai_insights")
    .select("insight, generated_at, lang")
    .eq("device_id", deviceId)
    .maybeSingle();

  if (!data) return null;

  // If cached in a different language, treat as expired
  if (data.lang && data.lang !== lang) return null;

  const age = Date.now() - new Date(data.generated_at).getTime();
  if (age > CACHE_TTL_MS) return null;   // expired

  return data.insight;
}

async function cacheInsight(deviceId, insight, lang = "en") {
  await supabase
    .from("ai_insights")
    .upsert(
      { device_id: deviceId, insight, lang, generated_at: new Date().toISOString() },
      { onConflict: "device_id" }
    );
}

// ─── Public API ───────────────────────────────────────────────────────────────

/**
 * Returns a Claude-generated personalised weekly insight for the device.
 * Returns the cached version if generated within the last 24 h.
 *
 * @param {string} deviceId
 * @param {object} context   — { topCategory, scores, recentQuotes, streak, totalReflections }
 * @returns {Promise<string>}
 */
export async function getWeeklyInsight(deviceId, context) {
  if (!process.env.ANTHROPIC_API_KEY) {
    return null;   // insight feature not configured
  }

  const lang = context.lang || "en";

  // Return cached if fresh AND same language
  const cached = await getCachedInsight(deviceId, lang);
  if (cached) return cached;

  // Generate with Claude
  const prompt = buildPrompt(context);

  const message = await client.messages.create({
    model:      MODEL,
    max_tokens: MAX_TOKENS,
    messages:   [{ role: "user", content: prompt }],
  });

  const insight = message.content[0]?.text?.trim() ?? null;
  if (!insight) return null;

  // Persist for 24-hour cache (keyed by device + lang)
  await cacheInsight(deviceId, insight, lang);

  return insight;
}
