import { supabase } from "../db/client.js";

// ─── Legacy constants ────────────────────────────────────────────────────────
const VALID_PURCHASE_TYPES = ["premium_unlock", "pack_purchase"];
const VALID_CURRENCIES     = ["USD", "EUR", "GBP", "ARS", "BRL"];

// ─── MindScrolling Inside plan constants ─────────────────────────────────────
const PLAN_NAME          = process.env.PREMIUM_PLAN_NAME          ?? "MindScrolling Inside";
const PLAN_PRICE         = process.env.PREMIUM_BASE_PRICE_USD     ?? "4.99";
const PRODUCT_ID_ANDROID = process.env.PREMIUM_PRODUCT_ID_ANDROID ?? "com.mindscrolling.inside";
const PRODUCT_ID_IOS     = process.env.PREMIUM_PRODUCT_ID_IOS     ?? "com.mindscrolling.inside";
const VALID_STORES       = ["android", "ios"];

export default async function premiumRoutes(fastify) {
  /**
   * GET /premium/status
   * Returns the current premium entitlement for the device.
   */
  fastify.get("/status", async (request, reply) => {
    const deviceId = request.deviceId;

    const [
      { data: userRow,  error: userErr     },
      { data: purchase, error: purchaseErr },
    ] = await Promise.all([
      supabase
        .from("users")
        .select("is_premium")
        .eq("device_id", deviceId)
        .maybeSingle(),
      supabase
        .from("purchases")
        .select("id")
        .eq("device_id", deviceId)
        .limit(1)
        .maybeSingle(),
    ]);

    // Gracefully handle missing columns (pre-migration state)
    // DEV MODE: force premium ON for testing (disabled in production)
    const isDev = process.env.NODE_ENV !== "production";
    const DEV_FORCE_PREMIUM = isDev && process.env.DEV_FORCE_PREMIUM === "true";
    const isPremium = DEV_FORCE_PREMIUM || (
      !userErr && !purchaseErr
        ? (userRow?.is_premium === true) && (purchase !== null)
        : false
    );

    return reply.send({
      is_premium: isPremium,
      plan:       isPremium ? PLAN_NAME : null,
      price:      PLAN_PRICE,
      currency:   "USD",
    });
  });

  /**
   * POST /premium/purchase/verify
   * Body: { store, product_id, purchase_token?, transaction_id? }
   * Auto-verifies (real store receipt validation wired later).
   */
  fastify.post("/purchase/verify", async (request, reply) => {
    const deviceId = request.deviceId;
    const {
      store,
      product_id,
      purchase_token = null,
      transaction_id = null,
    } = request.body ?? {};

    if (!store)      return reply.status(400).send({ error: "store is required",      code: "MISSING_FIELD" });
    if (!product_id) return reply.status(400).send({ error: "product_id is required", code: "MISSING_FIELD" });

    if (!VALID_STORES.includes(store)) {
      return reply.status(400).send({ error: `store must be one of: ${VALID_STORES.join(", ")}`, code: "INVALID_FIELD" });
    }

    const expectedProductId = store === "android" ? PRODUCT_ID_ANDROID : PRODUCT_ID_IOS;
    if (product_id !== expectedProductId) {
      return reply.status(400).send({ error: `Unknown product_id for store '${store}'`, code: "INVALID_FIELD" });
    }

    const now = new Date().toISOString();

    const { error: userUpsertErr } = await supabase
      .from("users")
      .upsert({ device_id: deviceId }, { onConflict: "device_id" });

    if (userUpsertErr) {
      return reply.status(500).send({ error: "Failed to initialise user", code: "DB_ERROR" });
    }

    const { error: purchaseErr } = await supabase
      .from("purchases")
      .insert({
        device_id:      deviceId,
        store,
        product_id,
        purchase_token,
        transaction_id,
        amount:         Number(PLAN_PRICE),
        currency:       "USD",
        status:         "verified",
        updated_at:     now,
      });

    if (purchaseErr) {
      request.log.error({ err: purchaseErr }, "premium/purchase/verify: failed to insert purchase");
      return reply.status(500).send({ error: "Failed to record purchase", code: "DB_ERROR" });
    }

    const { error: updateErr } = await supabase
      .from("users")
      .update({ is_premium: true, premium_since: now })
      .eq("device_id", deviceId);

    if (updateErr) {
      return reply.status(500).send({ error: "Failed to upgrade user", code: "DB_ERROR" });
    }

    return reply.status(200).send({ success: true, plan: PLAN_NAME, status: "verified" });
  });

  /**
   * POST /premium/restore
   * Body: { store, purchase_token?, transaction_id? }
   * Restores an existing verified purchase to a new device.
   */
  fastify.post("/restore", async (request, reply) => {
    const deviceId = request.deviceId;
    const {
      store,
      purchase_token = null,
      transaction_id = null,
    } = request.body ?? {};

    if (!store) return reply.status(400).send({ error: "store is required", code: "MISSING_FIELD" });
    if (!VALID_STORES.includes(store)) {
      return reply.status(400).send({ error: `store must be one of: ${VALID_STORES.join(", ")}`, code: "INVALID_FIELD" });
    }
    if (!purchase_token && !transaction_id) {
      return reply.status(400).send({ error: "At least one of purchase_token or transaction_id is required", code: "MISSING_FIELD" });
    }

    let query = supabase
      .from("purchases")
      .select("id, device_id, status")
      .eq("store", store)
      .eq("status", "verified");

    if (purchase_token && transaction_id) {
      query = query.or(`purchase_token.eq.${purchase_token},transaction_id.eq.${transaction_id}`);
    } else if (purchase_token) {
      query = query.eq("purchase_token", purchase_token);
    } else {
      query = query.eq("transaction_id", transaction_id);
    }

    const { data: existingPurchase, error: lookupErr } = await query.limit(1).maybeSingle();

    if (lookupErr) {
      return reply.status(500).send({ error: "Failed to look up purchase", code: "DB_ERROR" });
    }
    if (!existingPurchase) {
      return reply.status(200).send({ restored: false, message: "No purchases found" });
    }

    const now = new Date().toISOString();

    const [{ error: purchaseUpdateErr }, { error: userUpsertErr }] = await Promise.all([
      supabase
        .from("purchases")
        .update({ device_id: deviceId, status: "restored", updated_at: now })
        .eq("id", existingPurchase.id),
      supabase
        .from("users")
        .upsert({ device_id: deviceId }, { onConflict: "device_id" }),
    ]);

    if (purchaseUpdateErr || userUpsertErr) {
      return reply.status(500).send({ error: "Failed to restore purchase", code: "DB_ERROR" });
    }

    await supabase
      .from("users")
      .update({ is_premium: true, premium_since: now })
      .eq("device_id", deviceId);

    return reply.status(200).send({ restored: true, plan: PLAN_NAME });
  });

  /**
   * POST /premium/unlock  (legacy — backward compatibility)
   */
  fastify.post("/unlock", async (request, reply) => {
    const deviceId = request.deviceId;
    const {
      purchase_type = "premium_unlock",
      amount        = null,
      currency      = "USD",
    } = request.body ?? {};

    if (!VALID_PURCHASE_TYPES.includes(purchase_type)) {
      return reply.status(400).send({ error: `purchase_type must be one of: ${VALID_PURCHASE_TYPES.join(", ")}`, code: "INVALID_FIELD" });
    }
    if (currency && !VALID_CURRENCIES.includes(currency)) {
      return reply.status(400).send({ error: `currency must be one of: ${VALID_CURRENCIES.join(", ")}`, code: "INVALID_FIELD" });
    }

    const { error: userUpsertErr } = await supabase
      .from("users")
      .upsert({ device_id: deviceId }, { onConflict: "device_id" });

    if (userUpsertErr) {
      return reply.status(500).send({ error: "Failed to initialise user", code: "DB_ERROR" });
    }

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

    // Try to set is_premium — may fail if column doesn't exist yet (pre-migration)
    await supabase
      .from("users")
      .update({ is_premium: true })
      .eq("device_id", deviceId);

    return reply.status(200).send({ ok: true, is_premium: true, unlocked: true });
  });
}
