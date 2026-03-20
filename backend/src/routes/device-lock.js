import { supabase } from "../db/client.js";

/**
 * Device-lock routes.
 *
 * POST /device-lock/register  — register hardware Android ID on first launch.
 *   - If no lock exists for this app-device-id, creates one → { allowed: true }
 *   - If a lock exists with the SAME hardware id      → { allowed: true }
 *   - If a lock exists with a DIFFERENT hardware id    → { allowed: false }
 *
 * Table: device_locks (created manually in Supabase)
 *   device_id   text PK   — the X-Device-ID (UUID from SharedPreferences)
 *   hardware_id text       — real Android ID from the hardware
 *   created_at  timestamptz DEFAULT now()
 */
export default async function deviceLockRoutes(fastify) {
  fastify.post("/register", async (request, reply) => {
    const deviceId = request.deviceId;
    const { hardware_id } = request.body ?? {};

    if (!hardware_id || typeof hardware_id !== "string" || hardware_id.length < 8) {
      return reply.status(400).send({
        error: "hardware_id is required (min 8 chars)",
        code: "INVALID_HARDWARE_ID",
      });
    }

    // Check if ANY device is already locked with this hardware_id
    const { data: existingByHw, error: hwErr } = await supabase
      .from("device_locks")
      .select("device_id, hardware_id")
      .eq("hardware_id", hardware_id.trim())
      .maybeSingle();

    if (hwErr) {
      fastify.log.error(hwErr, "device-lock hw lookup failed");
      return reply.status(500).send({ error: "Internal error", code: "INTERNAL_ERROR" });
    }

    // Same hardware already registered — allow (could be reinstall)
    if (existingByHw) {
      return reply.send({ allowed: true, reason: "known_device" });
    }

    // Check if there's already a lock for ANY hardware (someone else got here first)
    const { count, error: countErr } = await supabase
      .from("device_locks")
      .select("*", { count: "exact", head: true });

    if (countErr) {
      fastify.log.error(countErr, "device-lock count failed");
      return reply.status(500).send({ error: "Internal error", code: "INTERNAL_ERROR" });
    }

    // Only 1 device allowed total — if count > 0 and it's not the same hw, block
    if (count > 0) {
      return reply.send({ allowed: false, reason: "device_limit_reached" });
    }

    // First ever registration — lock to this hardware
    const { error: insertErr } = await supabase
      .from("device_locks")
      .insert({
        device_id: deviceId,
        hardware_id: hardware_id.trim(),
      });

    if (insertErr) {
      // Race condition: someone else inserted between count and insert
      if (insertErr.code === "23505") {
        return reply.send({ allowed: false, reason: "device_limit_reached" });
      }
      fastify.log.error(insertErr, "device-lock insert failed");
      return reply.status(500).send({ error: "Internal error", code: "INTERNAL_ERROR" });
    }

    fastify.log.info({ deviceId, hardware_id }, "device locked");
    return reply.send({ allowed: true, reason: "registered" });
  });
}
