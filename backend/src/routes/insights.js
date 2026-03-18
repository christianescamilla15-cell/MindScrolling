/**
 * GET /insights/weekly
 *
 * Returns a Claude-generated personalised philosophical insight for the device.
 * Cached for 24 hours in the ai_insights table.
 * Returns null if ANTHROPIC_API_KEY is not configured.
 */

import { supabase }         from "../db/client.js";
import { getWeeklyInsight } from "../services/insights.js";

// Safe query helper — returns { data, error } without throwing
async function safeQuery(queryFn) {
  try {
    return await queryFn();
  } catch {
    return { data: null, error: "table_not_found" };
  }
}

export default async function insightsRoutes(fastify) {
  fastify.get("/weekly", async (request, reply) => {
    const { deviceId } = request;
    const lang = request.query.lang || request.headers["accept-language"]?.slice(0, 2) || "en";

    // Premium check: AI insights are a MindScrolling Inside feature
    // Skip in dev mode; in production, require premium OR active trial
    const isDev = process.env.NODE_ENV !== "production";
    const devForcePremium = isDev && process.env.DEV_FORCE_PREMIUM === "true";
    if (!devForcePremium) {
      const premiumResult = await safeQuery(() =>
        supabase
          .from("users")
          .select("is_premium, trial_start_date")
          .eq("device_id", deviceId)
          .maybeSingle()
      );
      const userRow = premiumResult.data;
      const isPaid = userRow?.is_premium === true;

      // Also allow active trial users (trial started within the last 7 days)
      let isTrialActive = false;
      if (!isPaid && userRow?.trial_start_date) {
        const trialEnd = new Date(userRow.trial_start_date).getTime() + 7 * 86400000;
        isTrialActive = Date.now() < trialEnd;
      }

      if (!isPaid && !isTrialActive) {
        return reply.send({ insight: null, premium_required: true });
      }
    }

    // ── Parallel fetch (each query is safe — missing tables don't crash) ──
    const [prefsResult, snapResult, likedResult, userResult] = await Promise.all([
      safeQuery(() =>
        supabase
          .from("user_preferences")
          .select("category, like_count, swipe_count")
          .eq("device_id", deviceId)
      ),

      // Snapshot table may not exist (requires migration 004)
      safeQuery(() =>
        supabase
          .from("user_preference_snapshots")
          .select("wisdom_score, discipline_score, reflection_score, philosophy_score")
          .eq("device_id", deviceId)
          .order("created_at", { ascending: false })
          .limit(1)
          .maybeSingle()
      ),

      safeQuery(() =>
        supabase
          .from("likes")
          .select("quote_id, quotes(text, author, category)")
          .eq("device_id", deviceId)
          .order("liked_at", { ascending: false })
          .limit(5)
      ),

      safeQuery(() =>
        supabase
          .from("users")
          .select("streak, total_reflections")
          .eq("device_id", deviceId)
          .maybeSingle()
      ),
    ]);

    const prefs   = prefsResult.data   || [];
    const snapRow = snapResult.data    || null;
    const liked   = likedResult.data   || [];
    const user    = userResult.data    || null;

    // ── Derive top category from preferences ──────────────────────────────────
    const catScores = {};
    prefs.forEach(p => {
      catScores[p.category] = (p.like_count ?? 0) * 3 + (p.swipe_count ?? 0);
    });

    const topCategory = Object.entries(catScores)
      .sort(([, a], [, b]) => b - a)[0]?.[0] ?? "stoicism";

    // ── Build 0-100 scores from preferences (snapshot fallback) ─────────────
    let scores;
    if (snapRow && snapRow.wisdom_score != null) {
      scores = {
        wisdom:     Number(snapRow.wisdom_score),
        discipline: Number(snapRow.discipline_score),
        reflection: Number(snapRow.reflection_score),
        philosophy: Number(snapRow.philosophy_score),
      };
    } else {
      // Derive approximate scores from preference data
      const total = Object.values(catScores).reduce((s, v) => s + v, 0) || 1;
      scores = {
        wisdom:     Math.round(((catScores.stoicism   ?? 0) / total) * 100),
        discipline: Math.round(((catScores.discipline  ?? 0) / total) * 100),
        reflection: Math.round(((catScores.reflection  ?? 0) / total) * 100),
        philosophy: Math.round(((catScores.philosophy  ?? 0) / total) * 100),
      };
    }

    const recentQuotes = liked
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
        lang,
      });
    } catch (err) {
      fastify.log.warn({ err }, "Failed to generate AI insight");
    }

    return reply.send({ insight });
  });
}
