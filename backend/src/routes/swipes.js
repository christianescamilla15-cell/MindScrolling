import { supabase }                from "../db/client.js";
import { updatePreferenceVector } from "../services/embeddings.js";

// Dwell thresholds
const SKIP_THRESHOLD_MS  = 500;    // dwell < 500 ms → quick dismissal
const DWELL_SIGNAL_MS    = 5000;   // dwell ≥ 5 s → long engagement → update semantic vector

export default async function swipesRoutes(fastify) {
  /**
   * POST /swipes
   * Body: { quote_id, direction, category, dwell_time_ms }
   * Fire-and-forget — client does not need to await a meaningful response.
   */
  fastify.post("/", async (request, reply) => {
    const { deviceId } = request;
    const { quote_id, direction, category, dwell_time_ms = 0 } = request.body ?? {};

    if (!quote_id)  return reply.status(400).send({ error: "quote_id is required",  code: "MISSING_FIELD" });
    if (!direction) return reply.status(400).send({ error: "direction is required", code: "MISSING_FIELD" });
    if (!category)  return reply.status(400).send({ error: "category is required",  code: "MISSING_FIELD" });

    const VALID_DIRECTIONS = ["up", "down", "left", "right"];
    if (!VALID_DIRECTIONS.includes(direction)) {
      return reply.status(400).send({ error: "direction must be up, down, left, or right", code: "INVALID_DIRECTION" });
    }

    const dwellMs = Math.max(0, Number(dwell_time_ms) || 0);
    const isSkip  = dwellMs < SKIP_THRESHOLD_MS;

    // ── Parallel fetch: user row + current preference row ─────────────────────
    const [
      { data: existingUser, error: userFetchErr },
      { data: prefRow },
    ] = await Promise.all([
      supabase
        .from("users")
        .select("streak, total_reflections, last_active")
        .eq("device_id", deviceId)
        .maybeSingle(),

      supabase
        .from("user_preferences")
        .select("swipe_count, skip_count, total_dwell_ms")
        .eq("device_id", deviceId)
        .eq("category", category)
        .maybeSingle(),
    ]);

    if (userFetchErr) {
      return reply.status(500).send({ error: "Failed to fetch user", code: "DB_ERROR" });
    }

    // ── Streak logic ───────────────────────────────────────────────────────────
    const todayStr    = new Date().toISOString().slice(0, 10);
    const lastActive  = existingUser?.last_active ?? null;
    let   streak      = existingUser?.streak              ?? 0;
    const reflections = existingUser?.total_reflections   ?? 0;

    if (!lastActive) {
      streak = 1;
    } else if (lastActive !== todayStr) {
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);
      streak = lastActive === yesterday.toISOString().slice(0, 10) ? streak + 1 : 1;
    }

    // ── Parallel write: upsert user + insert swipe event ─────────────────────
    const [{ error: userUpsertErr }, { error: swipeErr }] = await Promise.all([
      supabase.from("users").upsert(
        {
          device_id:         deviceId,
          streak,
          total_reflections: reflections + 1,
          last_active:       todayStr,
        },
        { onConflict: "device_id" }
      ),

      supabase.from("swipe_events").insert({
        device_id:     deviceId,
        quote_id,
        direction,
        category,
        dwell_time_ms: dwellMs,
      }),
    ]);

    if (userUpsertErr) return reply.status(500).send({ error: "Failed to update user",  code: "DB_ERROR" });
    if (swipeErr)      return reply.status(500).send({ error: "Failed to record swipe", code: "DB_ERROR" });

    // ── Update behavioural preference signals ─────────────────────────────────
    const prefUpdate = {
      device_id:      deviceId,
      category,
      swipe_count:    (prefRow?.swipe_count    ?? 0) + 1,
      skip_count:     isSkip ? (prefRow?.skip_count  ?? 0) + 1 : (prefRow?.skip_count  ?? 0),
      total_dwell_ms: (prefRow?.total_dwell_ms ?? 0) + dwellMs,
      updated_at:     new Date().toISOString(),
    };

    const { error: prefErr } = await supabase
      .from("user_preferences")
      .upsert(prefUpdate, { onConflict: "device_id,category" });

    if (prefErr) {
      return reply.status(500).send({ error: "Failed to update preferences", code: "DB_ERROR" });
    }

    // ── Fire-and-forget: update semantic vector on deep engagement ────────────
    if (dwellMs >= DWELL_SIGNAL_MS) {
      updatePreferenceVector(deviceId, quote_id, "dwell").catch(() => {});
    }

    return reply.status(200).send({ ok: true });
  });
}
