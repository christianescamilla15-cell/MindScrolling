import { supabase } from "../db/client.js";

/**
 * Normalises a raw score (like_count * 3 + swipe_count) to a 0–100 scale.
 * Uses a soft cap of 100 raw points = 100% so early users see meaningful growth.
 */
const RAW_CAP = 100;

function normalise(raw) {
  return Math.min(Math.round((raw / RAW_CAP) * 100), 100);
}

/**
 * Derives the four dimension scores from a user_preferences row set.
 * Each dimension maps to one category's contribution.
 *
 * wisdom      ← stoicism
 * discipline  ← discipline
 * reflection  ← reflection
 * philosophy  ← philosophy
 */
function computeScores(prefs) {
  const byCategory = {};
  (prefs || []).forEach(p => { byCategory[p.category] = p; });

  const raw = (cat) => {
    const p = byCategory[cat];
    if (!p) return 0;
    return (p.like_count ?? 0) * 3 + (p.swipe_count ?? 0);
  };

  return {
    wisdom:      normalise(raw("stoicism")),
    discipline:  normalise(raw("discipline")),
    reflection:  normalise(raw("reflection")),
    philosophy:  normalise(raw("philosophy")),
  };
}

export default async function mapRoutes(fastify) {
  /**
   * GET /map
   * Returns current dimension scores and the most recent snapshot.
   */
  fastify.get("/", async (request, reply) => {
    const deviceId = request.deviceId;

    // Fetch all preference rows for this device
    const { data: prefs, error: prefsErr } = await supabase
      .from("user_preferences")
      .select("category, like_count, swipe_count")
      .eq("device_id", deviceId);

    if (prefsErr) {
      request.log.error({ err: prefsErr }, "map: failed to fetch user_preferences");
      return reply.status(500).send({ error: "Failed to fetch preferences", code: "DB_ERROR" });
    }

    const current = computeScores(prefs);

    // Fetch latest snapshot
    const { data: snapRow, error: snapErr } = await supabase
      .from("user_preference_snapshots")
      .select("wisdom_score, discipline_score, reflection_score, philosophy_score, created_at")
      .eq("device_id", deviceId)
      .order("created_at", { ascending: false })
      .limit(1)
      .maybeSingle();

    if (snapErr) {
      // Non-fatal: snapshot table may not exist yet. Return map without history.
      request.log.warn({ err: snapErr }, "map: snapshot query failed — returning null snapshot");
    }

    const snapshot = snapRow
      ? {
          wisdom:      Number(snapRow.wisdom_score),
          discipline:  Number(snapRow.discipline_score),
          reflection:  Number(snapRow.reflection_score),
          philosophy:  Number(snapRow.philosophy_score),
        }
      : null;

    return reply.send({
      current,
      snapshot,
      snapshot_date: snapRow?.created_at ?? null,
    });
  });

  /**
   * POST /map/snapshot
   * Saves current scores as a snapshot entry.
   */
  fastify.post("/snapshot", async (request, reply) => {
    const deviceId = request.deviceId;

    // Ensure user row exists
    const { error: userErr } = await supabase
      .from("users")
      .upsert({ device_id: deviceId }, { onConflict: "device_id" });

    if (userErr) {
      return reply.status(500).send({ error: "Failed to initialise user", code: "DB_ERROR" });
    }

    // Read current preferences to snapshot
    const { data: prefs, error: prefsErr } = await supabase
      .from("user_preferences")
      .select("category, like_count, swipe_count")
      .eq("device_id", deviceId);

    if (prefsErr) {
      return reply.status(500).send({ error: "Failed to fetch preferences", code: "DB_ERROR" });
    }

    const scores = computeScores(prefs);

    const { error: insertErr } = await supabase
      .from("user_preference_snapshots")
      .insert({
        device_id:         deviceId,
        wisdom_score:      scores.wisdom,
        discipline_score:  scores.discipline,
        reflection_score:  scores.reflection,
        philosophy_score:  scores.philosophy,
      });

    if (insertErr) {
      return reply.status(500).send({ error: "Failed to save snapshot", code: "DB_ERROR" });
    }

    return reply.status(200).send({ saved: true });
  });
}
