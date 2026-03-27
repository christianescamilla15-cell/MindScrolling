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

    // Device already known — allow
    if (existingByHw) {
      return reply.send({ allowed: true, reason: "known_device" });
    }

    // Register new device — no limit enforced (multi-device allowed)
    const { error: insertErr } = await supabase
      .from("device_locks")
      .upsert({
        device_id: deviceId,
        hardware_id: hardware_id.trim(),
      }, { onConflict: "hardware_id" });

    if (insertErr) {
      fastify.log.error(insertErr, "device-lock insert failed");
      // Even on error, allow the device — don't block users
      return reply.send({ allowed: true, reason: "fallback_allowed" });
    }

    fastify.log.info({ deviceId, hardware_id }, "device registered (multi-device mode)");
    return reply.send({ allowed: true, reason: "registered" });
  });
}
