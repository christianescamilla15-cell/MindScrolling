/**
 * GET /insights/weekly
 *
 * Returns a Claude-generated personalised philosophical insight for the device.
 * Cached for 24 hours in the ai_insights table.
 * Returns null if ANTHROPIC_API_KEY is not configured.
 */

import { supabase }         from "../db/client.js";
import { getWeeklyInsight } from "../services/insights.js";

export default async function insightsRoutes(fastify) {
  fastify.get("/weekly", async (request, reply) => {
    const { deviceId } = request;

    // ── Parallel fetch: preferences + snapshot scores + liked quotes + user stats ──
    const [
      { data: prefs   },
      { data: snapRow },
      { data: liked   },
      { data: user    },
    ] = await Promise.all([
      supabase
        .from("user_preferences")
        .select("category, like_count, swipe_count")
        .eq("device_id", deviceId),

      // Latest snapshot (for stable 0-100 scores)
      supabase
        .from("user_preference_snapshots")
        .select("wisdom_score, discipline_score, reflection_score, philosophy_score")
        .eq("device_id", deviceId)
        .order("created_at", { ascending: false })
        .limit(1)
        .maybeSingle(),

      // Recently liked / vaulted quotes for Claude context
      supabase
        .from("likes")
        .select("quote_id, quotes(text, author, category)")
        .eq("device_id", deviceId)
        .order("liked_at", { ascending: false })
        .limit(5),

      supabase
        .from("users")
        .select("streak, total_reflections")
        .eq("device_id", deviceId)
        .maybeSingle(),
    ]);

    // ── Derive top category from preferences ──────────────────────────────────
    const catScores = {};
    (prefs || []).forEach(p => {
      catScores[p.category] = (p.like_count ?? 0) * 3 + (p.swipe_count ?? 0);
    });

    const topCategory = Object.entries(catScores)
      .sort(([, a], [, b]) => b - a)[0]?.[0] ?? "stoicism";

    // ── Build 0-100 scores (live or from snapshot) ────────────────────────────
    const scores = snapRow
      ? {
          wisdom:      Number(snapRow.wisdom_score),
          discipline:  Number(snapRow.discipline_score),
          reflection:  Number(snapRow.reflection_score),
          philosophy:  Number(snapRow.philosophy_score),
        }
      : { wisdom: 0, discipline: 0, reflection: 0, philosophy: 0 };

    const recentQuotes = (liked || [])
      .map(r => r.quotes)
      .filter(Boolean);

    // ── Generate or return cached insight ─────────────────────────────────────
    let insight = null;
    try {
      insight = await getWeeklyInsight(deviceId, {
        topCategory,
        scores,
        recentQuotes,
        streak:           user?.streak            ?? 0,
        totalReflections: user?.total_reflections  ?? 0,
      });
    } catch (err) {
      fastify.log.warn({ err }, "Failed to generate AI insight");
    }

    return reply.send({ insight });   // null if API not configured or generation failed
  });
}
