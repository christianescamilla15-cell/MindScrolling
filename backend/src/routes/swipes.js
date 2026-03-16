import { supabase } from "../db/client.js";

// Which aggregate score column to increment per category
const CATEGORY_SCORE_COL = {
  stoicism:    "wisdom_score",
  philosophy:  "philosophy_score",
  discipline:  "discipline_score",
  reflection:  "reflection_score",
};

const SCORE_INCREMENT = 1.0; // points added to the relevant score per swipe

export default async function swipesRoutes(fastify) {
  /**
   * POST /swipes
   * Body: { quote_id, direction, category, dwell_time_ms }
   */
  fastify.post("/", async (request, reply) => {
    const deviceId = request.deviceId;
    const { quote_id, direction, category, dwell_time_ms = 0 } = request.body ?? {};

    if (!quote_id)  return reply.status(400).send({ error: "quote_id is required",  code: "MISSING_FIELD" });
    if (!direction) return reply.status(400).send({ error: "direction is required", code: "MISSING_FIELD" });
    if (!category)  return reply.status(400).send({ error: "category is required",  code: "MISSING_FIELD" });

    // ── Ensure user row exists (required for all FK operations below) ──────
    const { data: existingUser, error: userFetchErr } = await supabase
      .from("users")
      .select("streak, total_reflections, last_active")
      .eq("device_id", deviceId)
      .maybeSingle();

    if (userFetchErr) {
      return reply.status(500).send({ error: "Failed to fetch user", code: "DB_ERROR" });
    }

    // ── Streak logic ──────────────────────────────────────────────────────
    const todayStr     = new Date().toISOString().slice(0, 10); // "YYYY-MM-DD"
    const lastActive   = existingUser?.last_active ?? null;
    let   streak       = existingUser?.streak       ?? 0;
    const reflections  = existingUser?.total_reflections ?? 0;

    if (!lastActive) {
      // First ever swipe
      streak = 1;
    } else if (lastActive === todayStr) {
      // Already active today — streak unchanged
    } else {
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);
      const yesterdayStr = yesterday.toISOString().slice(0, 10);

      if (lastActive === yesterdayStr) {
        streak += 1;
      } else {
        streak = 1;
      }
    }

    // ── Upsert user (streak + reflection count + last_active) ─────────────
    const { error: userUpsertErr } = await supabase
      .from("users")
      .upsert(
        {
          device_id:         deviceId,
          streak,
          total_reflections: reflections + 1,
          last_active:       todayStr,
        },
        { onConflict: "device_id" }
      );

    if (userUpsertErr) {
      return reply.status(500).send({ error: "Failed to update user", code: "DB_ERROR" });
    }

    // ── Insert swipe event ─────────────────────────────────────────────────
    const { error: swipeErr } = await supabase
      .from("swipe_events")
      .insert({
        device_id:     deviceId,
        quote_id,
        direction,
        category,
        dwell_time_ms: Number(dwell_time_ms) || 0,
      });

    if (swipeErr) {
      return reply.status(500).send({ error: "Failed to record swipe", code: "DB_ERROR" });
    }

    // ── Update user_preferences (swipe_count + score field) ───────────────
    const scoreCol = CATEGORY_SCORE_COL[category];

    // Fetch current preference row so we can compute new score value
    const { data: prefRow } = await supabase
      .from("user_preferences")
      .select("swipe_count, wisdom_score, discipline_score, reflection_score, philosophy_score")
      .eq("device_id", deviceId)
      .eq("category", category)
      .maybeSingle();

    const currentSwipeCount   = prefRow?.swipe_count   ?? 0;
    const currentScoreValue   = prefRow?.[scoreCol]     ?? 0;

    const prefUpdate = {
      device_id:         deviceId,
      category,
      swipe_count:       currentSwipeCount + 1,
      updated_at:        new Date().toISOString(),
    };

    // Only update the score column that matches this category
    if (scoreCol) {
      prefUpdate[scoreCol] = Number(currentScoreValue) + SCORE_INCREMENT;
    }

    const { error: prefErr } = await supabase
      .from("user_preferences")
      .upsert(prefUpdate, { onConflict: "device_id,category" });

    if (prefErr) {
      return reply.status(500).send({ error: "Failed to update preferences", code: "DB_ERROR" });
    }

    return reply.status(200).send({ recorded: true });
  });
}
