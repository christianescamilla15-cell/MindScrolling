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
        .select("is_premium, trial_start_date, trial_end_date, premium_status")
        .eq("device_id", deviceId)
        .maybeSingle(),
      supabase
        .from("purchases")
        .select("id")
        .eq("device_id", deviceId)
        .limit(1)
        .maybeSingle(),
    ]);

    const isDev = process.env.NODE_ENV !== "production";
    const DEV_FORCE_PREMIUM = isDev && process.env.DEV_FORCE_PREMIUM === "true";
    // is_premium flag is the source of truth (set by purchase, code redeem, or admin)
    const isPremium = DEV_FORCE_PREMIUM || (userRow?.is_premium === true);

    // ── Trial logic (server-side) ──────────────────────────────────────
    const TRIAL_DAYS = 7;
    let trialActive = false;
    let trialDaysLeft = 0;
    let trialExpired = false;

    if (userRow?.trial_start_date) {
      const start = new Date(userRow.trial_start_date);
      const end = new Date(start.getTime() + TRIAL_DAYS * 86400000);
      const now = new Date();
      if (now < end) {
        trialActive = true;
        trialDaysLeft = Math.ceil((end - now) / 86400000);
      } else {
        trialExpired = true;
      }
    }

    return reply.send({
      is_premium: isPremium || trialActive,
      is_paid_premium: isPremium,
      plan:       (isPremium || trialActive) ? PLAN_NAME : null,
      price:      PLAN_PRICE,
      currency:   "USD",
      trial_active: trialActive,
      trial_days_left: trialDaysLeft,
      trial_expired: trialExpired,
    });
  });

  /**
   * POST /premium/start-trial
   * Starts a 7-day trial for the device. Only works once per device.
   * Returns: { started, trial_days_left } or { already_used }
   */
  fastify.post("/start-trial", async (request, reply) => {
    const deviceId = request.deviceId;

    // Ensure user row exists
    await supabase
      .from("users")
      .upsert({ device_id: deviceId }, { onConflict: "device_id" });

    // Check if trial was already started
    const { data: user } = await supabase
      .from("users")
      .select("trial_start_date")
      .eq("device_id", deviceId)
      .maybeSingle();

    if (user?.trial_start_date) {
      // Trial already used — check if still active
      const start = new Date(user.trial_start_date);
      const end = new Date(start.getTime() + 7 * 86400000);
      const now = new Date();
      if (now < end) {
        return reply.send({
          started: false,
          already_active: true,
          trial_days_left: Math.ceil((end - now) / 86400000),
        });
      }
      return reply.send({ started: false, already_used: true });
    }

    // Start trial
    const now = new Date().toISOString();
    const { error } = await supabase
      .from("users")
      .update({
        trial_start_date: now,
        trial_end_date: new Date(Date.now() + 7 * 86400000).toISOString(),
        premium_status: "trial",
      })
      .eq("device_id", deviceId);

    if (error) {
      return reply.status(500).send({ error: "Failed to start trial", code: "DB_ERROR" });
    }

    // Audit log
    await supabase.from("premium_audit_log").insert({
      device_id: deviceId,
      event_type: "trial_started",
      source: "app",
      metadata: { started_at: now },
    }).catch(() => {});

    return reply.send({ started: true, trial_days_left: 7 });
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

    // Insert a NEW purchase row for the restoring device (don't mutate the original)
    const [{ error: purchaseUpdateErr }, { error: userUpsertErr }] = await Promise.all([
      supabase
        .from("purchases")
        .insert({
          device_id: deviceId,
          store,
          purchase_token: purchase_token,
          transaction_id: transaction_id,
          status: "restored",
          amount: 4.99,
          currency: "USD",
          updated_at: now,
        }),
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

  /**
   * POST /premium/redeem
   * Body: { code }
   * Validates an activation code and grants premium_lifetime.
   */
  fastify.post("/redeem", async (request, reply) => {
    const deviceId = request.deviceId;
    const { code } = request.body ?? {};

    if (!code || typeof code !== "string" || code.trim().length < 6) {
      return reply.status(400).send({
        error: "Invalid code format",
        code: "INVALID_CODE",
      });
    }

    const cleanCode = code.trim().toUpperCase();

    // Look up the activation code
    const { data: codeRow, error: lookupErr } = await supabase
      .from("premium_activation_codes")
      .select("*")
      .eq("code", cleanCode)
      .maybeSingle();

    if (lookupErr) {
      request.log.error({ err: lookupErr }, "premium/redeem: lookup failed");
      return reply.status(500).send({ error: "Failed to validate code", code: "DB_ERROR" });
    }

    // Validate code
    if (!codeRow) {
      return reply.status(404).send({
        error: "Code not found",
        code: "CODE_NOT_FOUND",
      });
    }

    if (codeRow.revoked) {
      return reply.status(410).send({
        error: "This code has been revoked",
        code: "CODE_REVOKED",
      });
    }

    if (codeRow.is_redeemed) {
      return reply.status(409).send({
        error: "This code has already been used",
        code: "CODE_ALREADY_REDEEMED",
      });
    }

    if (codeRow.expires_at && new Date(codeRow.expires_at) < new Date()) {
      return reply.status(410).send({
        error: "This code has expired",
        code: "CODE_EXPIRED",
      });
    }

    const now = new Date().toISOString();

    // Mark code as redeemed
    const { error: redeemErr } = await supabase
      .from("premium_activation_codes")
      .update({
        is_redeemed: true,
        redeemed_by: deviceId,
        redeemed_at: now,
      })
      .eq("id", codeRow.id);

    if (redeemErr) {
      request.log.error({ err: redeemErr }, "premium/redeem: failed to mark code");
      return reply.status(500).send({ error: "Failed to redeem code", code: "DB_ERROR" });
    }

    // Ensure user row exists
    await supabase
      .from("users")
      .upsert({ device_id: deviceId }, { onConflict: "device_id" });

    // Grant premium lifetime
    const { error: upgradeErr } = await supabase
      .from("users")
      .update({
        is_premium: true,
        premium_status: "premium_lifetime",
        premium_source: "activation_code",
        premium_activated_at: now,
        premium_since: now,
      })
      .eq("device_id", deviceId);

    if (upgradeErr) {
      request.log.error({ err: upgradeErr }, "premium/redeem: failed to upgrade user");
      return reply.status(500).send({ error: "Failed to activate premium", code: "DB_ERROR" });
    }

    // Audit log
    await supabase
      .from("premium_audit_log")
      .insert({
        device_id: deviceId,
        event_type: "code_redeemed",
        source: "activation_code",
        metadata: {
          code_id: codeRow.id,
          code: cleanCode,
          type: codeRow.type,
          assigned_email: codeRow.assigned_email,
        },
      })
      .then(() => {}) // fire and forget
      .catch(() => {});

    request.log.info({ deviceId, code: cleanCode }, "premium/redeem: code redeemed successfully");

    return reply.status(200).send({
      success: true,
      plan: PLAN_NAME,
      type: codeRow.type,
      message: "MindScrolling Inside activated!",
    });
  });
}
