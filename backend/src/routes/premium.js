import { supabase } from "../db/client.js";

const VALID_PURCHASE_TYPES = ["premium_unlock", "pack_purchase"];
const VALID_CURRENCIES     = ["USD", "EUR", "GBP", "ARS", "BRL"];

export default async function premiumRoutes(fastify) {
  /**
   * GET /premium/status
   * Returns whether the device has an active premium entitlement.
   * Cross-checks users.is_premium with the purchases table.
   */
  fastify.get("/status", async (request, reply) => {
    const deviceId = request.deviceId;

    const { data: userRow, error: userErr } = await supabase
      .from("users")
      .select("is_premium")
      .eq("device_id", deviceId)
      .maybeSingle();

    if (userErr) {
      return reply.status(500).send({ error: "Failed to fetch user", code: "DB_ERROR" });
    }

    // Also verify at least one purchase record exists as source of truth
    const { data: purchase, error: purchaseErr } = await supabase
      .from("purchases")
      .select("id")
      .eq("device_id", deviceId)
      .eq("purchase_type", "premium_unlock")
      .limit(1)
      .maybeSingle();

    if (purchaseErr) {
      return reply.status(500).send({ error: "Failed to verify purchase", code: "DB_ERROR" });
    }

    const isPremium = (userRow?.is_premium === true) && (purchase !== null);

    return reply.send({ is_premium: isPremium });
  });

  /**
   * POST /premium/unlock
   * Body: { purchase_type?, amount?, currency? }
   * Records a purchase and sets users.is_premium = true.
   */
  fastify.post("/unlock", async (request, reply) => {
    const deviceId = request.deviceId;
    const {
      purchase_type = "premium_unlock",
      amount        = null,
      currency      = "USD",
    } = request.body ?? {};

    if (!VALID_PURCHASE_TYPES.includes(purchase_type)) {
      return reply.status(400).send({
        error: `purchase_type must be one of: ${VALID_PURCHASE_TYPES.join(", ")}`,
        code:  "INVALID_FIELD",
      });
    }
    if (currency && !VALID_CURRENCIES.includes(currency)) {
      return reply.status(400).send({
        error: `currency must be one of: ${VALID_CURRENCIES.join(", ")}`,
        code:  "INVALID_FIELD",
      });
    }

    // Ensure user row exists
    const { error: userUpsertErr } = await supabase
      .from("users")
      .upsert({ device_id: deviceId }, { onConflict: "device_id" });

    if (userUpsertErr) {
      return reply.status(500).send({ error: "Failed to initialise user", code: "DB_ERROR" });
    }

    // Record the purchase
    const { error: purchaseErr } = await supabase
      .from("purchases")
      .insert({
        device_id:     deviceId,
        purchase_type,
        amount:        amount !== null ? Number(amount) : null,
        currency,
      });

    if (purchaseErr) {
      return reply.status(500).send({ error: "Failed to record purchase", code: "DB_ERROR" });
    }

    // Set is_premium = true on the user
    const { error: updateErr } = await supabase
      .from("users")
      .update({ is_premium: true })
      .eq("device_id", deviceId);

    if (updateErr) {
      return reply.status(500).send({ error: "Failed to upgrade user", code: "DB_ERROR" });
    }

    return reply.status(200).send({ unlocked: true });
  });
}
