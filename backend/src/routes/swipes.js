import { supabase }                from "../db/client.js";
import { updatePreferenceVector } from "../services/embeddings.js";
import { getPackEntitlement, KNOWN_PACK_IDS } from "../services/packEntitlement.js";

// Dwell thresholds
const SKIP_THRESHOLD_MS  = 500;    // dwell < 500 ms → quick dismissal
const DWELL_SIGNAL_MS    = 5000;   // dwell ≥ 5 s → long engagement → update semantic vector

export default async function swipesRoutes(fastify) {
  /**
   * POST /swipes
   * Body: { quote_id, direction, category, dwell_time_ms, source?, source_pack_id? }
   *
   * Block B additions (API_CONTRACT_BLOCK_B.md §2):
   *   source         — 'feed' (default) | 'pack' | 'preview'
   *   source_pack_id — required when source is 'pack' or 'preview'
   *
   * Behavioral matrix by source:
   *   source     | daily/trial limit | updates prefs+vector | entitlement check
   *   'feed'     | YES               | YES                  | no
   *   'pack'     | NO  (OQ-01)       | YES                  | YES → 403 if not entitled
   *   'preview'  | NO                | NO                   | no
   */
  fastify.post("/", async (request, reply) => {
    const { deviceId } = request;
    const {
      quote_id,
      direction,
      category,
      dwell_time_ms   = 0,
      source          = "feed",
      source_pack_id  = null,
    } = request.body ?? {};

    // ── Required field validation ──────────────────────────────────────────────
    if (!quote_id)  return reply.status(400).send({ error: "quote_id is required",  code: "MISSING_FIELD" });
    if (!direction) return reply.status(400).send({ error: "direction is required", code: "MISSING_FIELD" });
    if (!category)  return reply.status(400).send({ error: "category is required",  code: "MISSING_FIELD" });

    const VALID_DIRECTIONS = ["up", "down", "left", "right"];
    if (!VALID_DIRECTIONS.includes(direction)) {
      return reply.status(400).send({ error: "direction must be up, down, left, or right", code: "INVALID_DIRECTION" });
    }

    const VALID_CATEGORIES = ["stoicism", "philosophy", "discipline", "reflection"];
    if (!VALID_CATEGORIES.includes(category)) {
      return reply.status(400).send({ error: `category must be one of: ${VALID_CATEGORIES.join(", ")}`, code: "INVALID_FIELD" });
    }

    const VALID_SOURCES = ["feed", "pack", "preview"];
    if (!VALID_SOURCES.includes(source)) {
      return reply.status(400).send({ error: `source must be one of: ${VALID_SOURCES.join(", ")}`, code: "INVALID_FIELD" });
    }

    // source_pack_id required when source is 'pack' or 'preview'
    if ((source === "pack" || source === "preview") && !source_pack_id) {
      return reply.status(400).send({
        error: "source_pack_id is required when source is 'pack' or 'preview'",
        code: "MISSING_FIELD",
      });
    }

    // source_pack_id must be a known pack ID
    if (source_pack_id && !KNOWN_PACK_IDS.has(source_pack_id)) {
      return reply.status(400).send({
        error: `source_pack_id must be one of: ${[...KNOWN_PACK_IDS].join(", ")}`,
        code: "INVALID_FIELD",
      });
    }

    // ── Pack entitlement check (source = 'pack' only) ─────────────────────────
    // 'preview' swipes are analytics-only and do not require entitlement.
    if (source === "pack") {
      let entitlement;
      try {
        entitlement = await getPackEntitlement(deviceId, source_pack_id);
      } catch {
        return reply.status(500).send({ error: "Failed to check entitlement", code: "DB_ERROR" });
      }
      if (entitlement.access !== "full") {
        return reply.status(403).send({
          error: "Purchase required to access this pack",
          code: "PACK_NOT_ENTITLED",
        });
      }
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

    // ── Upsert user first (swipe_events has FK on users.device_id) ───────────
    const { error: userUpsertErr } = await supabase.from("users").upsert(
      {
        device_id:         deviceId,
        streak,
        total_reflections: reflections + 1,
        last_active:       todayStr,
      },
      { onConflict: "device_id" }
    );

    if (userUpsertErr) {
      request.log.error({ err: userUpsertErr }, "swipes: failed to upsert user");
      return reply.status(500).send({ error: "Failed to update user", code: "DB_ERROR" });
    }

    // ── Insert swipe event — always recorded regardless of source ─────────────
    // source and source_pack_id columns added by migration 009.
    const { error: swipeErr } = await supabase.from("swipe_events").insert({
      device_id:      deviceId,
      quote_id,
      direction,
      category,
      dwell_time_ms:  dwellMs,
      source,
      source_pack_id: source_pack_id ?? null,
    });

    if (swipeErr) {
      request.log.error({ err: swipeErr }, "swipes: failed to insert swipe_event");
      return reply.status(500).send({ error: "Failed to record swipe", code: "DB_ERROR" });
    }

    // ── Update behavioural preference signals ─────────────────────────────────
    // 'preview' swipes do NOT update user_preferences or preference vector (BR-08).
    // 'feed' and 'pack' swipes both update prefs and vector.
    if (source !== "preview") {
      const prefUpdate = {
        device_id:      deviceId,
        category,
        swipe_count:    (prefRow?.swipe_count    ?? 0) + 1,
        skip_count:     isSkip ? (prefRow?.skip_count  ?? 0) + 1 : (prefRow?.skip_count ?? 0),
        total_dwell_ms: (prefRow?.total_dwell_ms ?? 0) + dwellMs,
        updated_at:     new Date().toISOString(),
      };

      const { error: prefErr } = await supabase
        .from("user_preferences")
        .upsert(prefUpdate, { onConflict: "device_id,category" });

      if (prefErr) {
        request.log.error({ err: prefErr }, "swipes: failed to upsert user_preferences");
        return reply.status(500).send({ error: "Failed to update preferences", code: "DB_ERROR" });
      }

      // Fire-and-forget: update semantic vector on deep engagement
      if (dwellMs >= DWELL_SIGNAL_MS) {
        updatePreferenceVector(deviceId, quote_id, "dwell").catch(() => {});
      }
    }

    return reply.status(200).send({ ok: true });
  });
}
