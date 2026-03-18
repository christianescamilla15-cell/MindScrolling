/**
 * premium.js — MindScrolling Inside premium routes
 *
 * Block B additions:
 *   - GET /premium/status    — adds owned_packs[] and user_state fields
 *   - POST /premium/restore  — also restores individual pack entitlements
 *
 * All previously existing routes (start-trial, purchase/verify, unlock, redeem)
 * are preserved unchanged.
 */

import { supabase } from "../db/client.js";
import {
  getOwnedPackIds,
  resolveUserState,
  KNOWN_PACK_IDS,
} from "../services/packEntitlement.js";

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
  // ── GET /premium/status ───────────────────────────────────────────────────
  /**
   * Returns current premium entitlement for the device.
   *
   * Block B additions:
   *   - owned_packs: string[] — pack IDs the device can access in full
   *   - user_state: 'free' | 'trial' | 'inside' | 'pack_owner'
   */
  fastify.get("/status", async (request, reply) => {
    const deviceId = request.deviceId;

    // Fetch user row
    const { data: userRow, error: userErr } = await supabase
      .from("users")
      .select("is_premium, trial_start_date, trial_end_date, premium_status")
      .eq("device_id", deviceId)
      .maybeSingle();

    if (userErr) {
      request.log.error({ err: userErr }, "premium/status: DB error");
      return reply.status(500).send({ error: "Failed to load status", code: "DB_ERROR" });
    }

    const isDev = process.env.NODE_ENV !== "production";
    const DEV_FORCE_PREMIUM = isDev && process.env.DEV_FORCE_PREMIUM === "true";
    const isPremium = DEV_FORCE_PREMIUM || (userRow?.is_premium === true);

    // ── Trial logic ────────────────────────────────────────────────────────
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
        // Fire trial_expired audit once (deduplicated — fire-and-forget).
        supabase.from("premium_audit_log")
          .select("id").eq("device_id", deviceId).eq("event_type", "trial_expired")
          .limit(1).maybeSingle()
          .then(({ data }) => {
            if (!data) {
              supabase.from("premium_audit_log").insert({
                device_id: deviceId,
                event_type: "trial_expired",
                source: "app",
                metadata: { expired_at: new Date().toISOString() },
              }).then(() => {}).catch(() => {});
            }
          }).catch(() => {});
      }
    }

    // ── Block B: owned_packs ───────────────────────────────────────────────
    // Use a synthetic row when DEV_FORCE_PREMIUM is active.
    const effectiveUserRow = DEV_FORCE_PREMIUM
      ? { ...(userRow ?? {}), is_premium: true }
      : userRow;

    let ownedPacks = [];
    try {
      ownedPacks = await getOwnedPackIds(deviceId, effectiveUserRow);
    } catch {
      // Non-blocking — if this fails, owned_packs returns [].
      request.log.warn({ deviceId }, "premium/status: owned_packs lookup failed");
    }

    const userState = resolveUserState(effectiveUserRow, ownedPacks);

    return reply.send({
      is_premium: isPremium || trialActive,
      is_paid_premium: isPremium,
      plan:       (isPremium || trialActive) ? PLAN_NAME : null,
      price:      PLAN_PRICE,
      currency:   "USD",
      trial_active: trialActive,
      trial_days_left: trialDaysLeft,
      trial_expired: trialExpired,
      // Block B additive fields:
      owned_packs: ownedPacks,
      user_state: userState,
    });
  });

  // ── POST /premium/start-trial ─────────────────────────────────────────────
  /**
   * Starts a 7-day trial for the device. Only works once per device.
   * Unchanged from pre-Block B.
   */
  fastify.post("/start-trial", async (request, reply) => {
    const deviceId = request.deviceId;

    // Ensure user row exists
    await supabase
      .from("users")
      .upsert({ device_id: deviceId }, { onConflict: "device_id" });

    const now = new Date().toISOString();
    const { data: updated, error } = await supabase
      .from("users")
      .update({
        trial_start_date: now,
        trial_end_date: new Date(Date.now() + 7 * 86400000).toISOString(),
        premium_status: "trial",
      })
      .eq("device_id", deviceId)
      .is("trial_start_date", null)
      .select("trial_start_date");

    if (error) {
      return reply.status(500).send({ error: "Failed to start trial", code: "DB_ERROR" });
    }

    if (!updated || updated.length === 0) {
      const { data: user } = await supabase
        .from("users")
        .select("trial_start_date")
        .eq("device_id", deviceId)
        .maybeSingle();

      if (user?.trial_start_date) {
        const start = new Date(user.trial_start_date);
        const end   = new Date(start.getTime() + 7 * 86400000);
        if (Date.now() < end.getTime()) {
          return reply.send({
            started: false,
            already_active: true,
            trial_days_left: Math.ceil((end - Date.now()) / 86400000),
          });
        }
      }
      return reply.send({ started: false, already_used: true });
    }

    supabase.from("premium_audit_log").insert({
      device_id: deviceId,
      event_type: "trial_started",
      source: "app",
      metadata: { started_at: now },
    }).then(() => {}).catch(() => {});

    return reply.send({ started: true, trial_days_left: 7 });
  });

  // ── POST /premium/purchase/verify ─────────────────────────────────────────
  /**
   * Verifies an Inside purchase. Unchanged from pre-Block B.
   * (Individual pack purchase uses POST /packs/:id/purchase/verify.)
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
      .update({
        is_premium: true,
        premium_since: now,
        premium_status: "premium_onetime",
        premium_source: store === "ios" ? "app_store" : "play_billing",
      })
      .eq("device_id", deviceId);

    if (updateErr) {
      return reply.status(500).send({ error: "Failed to upgrade user", code: "DB_ERROR" });
    }

    // Audit log — premium_purchased
    supabase.from("premium_audit_log").insert({
      device_id: deviceId,
      event_type: "premium_purchased",
      source: store === "ios" ? "app_store" : "play_billing",
      metadata: { product_id, store, purchased_at: now },
    }).then(() => {}).catch(() => {});

    return reply.status(200).send({ success: true, plan: PLAN_NAME, status: "verified" });
  });

  // ── POST /premium/restore ─────────────────────────────────────────────────
  /**
   * Restores an existing verified Inside purchase to a new/reinstalled device.
   *
   * Block B additions:
   *   - Also restores individual pack_purchases rows.
   *   - Returns restored_packs[] and updated message.
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
      return reply.status(400).send({
        error: "At least one of purchase_token or transaction_id is required",
        code: "MISSING_FIELD",
      });
    }

    // ── Look up existing Inside purchase across all devices ───────────────────
    let insideQuery = supabase
      .from("purchases")
      .select("id, device_id, status")
      .eq("store", store)
      .eq("status", "verified");

    if (purchase_token && transaction_id) {
      insideQuery = insideQuery.or(
        `purchase_token.eq.${purchase_token},transaction_id.eq.${transaction_id}`
      );
    } else if (purchase_token) {
      insideQuery = insideQuery.eq("purchase_token", purchase_token);
    } else {
      insideQuery = insideQuery.eq("transaction_id", transaction_id);
    }

    // ── Look up existing pack purchases by token or transaction_id ────────────
    let packQuery = supabase
      .from("pack_purchases")
      .select("id, device_id, pack_id, store, product_id, amount, currency")
      .in("status", ["verified", "restored"]);

    if (purchase_token && transaction_id) {
      packQuery = packQuery.or(
        `purchase_token.eq.${purchase_token},transaction_id.eq.${transaction_id}`
      );
    } else if (purchase_token) {
      packQuery = packQuery.eq("purchase_token", purchase_token);
    } else {
      packQuery = packQuery.eq("transaction_id", transaction_id);
    }

    const [
      { data: existingInsidePurchase, error: insideLookupErr },
      { data: existingPackPurchases, error: packLookupErr },
    ] = await Promise.all([
      insideQuery.limit(1).maybeSingle(),
      packQuery,
    ]);

    if (insideLookupErr || packLookupErr) {
      request.log.error({ insideLookupErr, packLookupErr }, "premium/restore: lookup error");
      return reply.status(500).send({ error: "Failed to look up purchase", code: "DB_ERROR" });
    }

    const hasInside = Boolean(existingInsidePurchase);
    const packRows = existingPackPurchases ?? [];
    const hasAnyPurchase = hasInside || packRows.length > 0;

    if (!hasAnyPurchase) {
      return reply.status(200).send({
        restored: false,
        restored_packs: [],
        message: "No purchases found.",
      });
    }

    const now = new Date().toISOString();

    // ── Ensure user row exists for restoring device ───────────────────────────
    const { error: userUpsertErr } = await supabase
      .from("users")
      .upsert({ device_id: deviceId }, { onConflict: "device_id" });

    if (userUpsertErr) {
      request.log.error({ err: userUpsertErr }, "premium/restore: user upsert failed");
      return reply.status(500).send({ error: "Failed to restore purchase", code: "DB_ERROR" });
    }

    // ── Restore Inside ────────────────────────────────────────────────────────
    if (hasInside) {
      const restoredProductId = store === "ios" ? PRODUCT_ID_IOS : PRODUCT_ID_ANDROID;

      const [{ error: purchaseInsertErr }, { error: upgradeErr }] = await Promise.all([
        supabase.from("purchases").insert({
          device_id: deviceId,
          store,
          product_id: restoredProductId,
          purchase_token,
          transaction_id,
          status: "restored",
          amount: Number(PLAN_PRICE),
          currency: "USD",
          updated_at: now,
        }),
        supabase.from("users").update({
          is_premium: true,
          premium_since: now,
          premium_status: "premium_onetime",
          premium_source: store === "ios" ? "app_store" : "play_billing",
        }).eq("device_id", deviceId),
      ]);

      if (purchaseInsertErr || upgradeErr) {
        request.log.error(
          { purchaseInsertErr, upgradeErr },
          "premium/restore: failed to restore Inside"
        );
        return reply.status(500).send({ error: "Failed to restore purchase", code: "DB_ERROR" });
      }
    }

    // ── Restore individual pack purchases ─────────────────────────────────────
    // Per contract: upsert a restored row for each found pack purchase.
    // On conflict (device_id, pack_id): update status = 'restored'.
    const restoredPackIds = [];

    if (packRows.length > 0) {
      const upsertPayloads = packRows
        .filter((p) => KNOWN_PACK_IDS.has(p.pack_id))
        .map((p) => ({
          device_id: deviceId,
          pack_id: p.pack_id,
          store: p.store ?? store,
          product_id: p.product_id,
          purchase_token,
          transaction_id,
          amount: Number(p.amount ?? 2.99),
          currency: p.currency ?? "USD",
          status: "restored",
          purchased_at: now,
          updated_at: now,
        }));

      if (upsertPayloads.length > 0) {
        const { error: packRestoreErr } = await supabase
          .from("pack_purchases")
          .upsert(upsertPayloads, { onConflict: "device_id,pack_id" });

        if (packRestoreErr) {
          request.log.error({ err: packRestoreErr }, "premium/restore: pack restore failed");
          // Non-fatal for Inside restore — log but continue
        } else {
          restoredPackIds.push(...upsertPayloads.map((p) => p.pack_id));
        }
      }

      // Fire-and-forget audit log per restored pack
      for (const packId of restoredPackIds) {
        supabase.from("premium_audit_log").insert({
          device_id: deviceId,
          event_type: "pack_purchased",
          source: "restore",
          metadata: { pack_id: packId, store },
        }).then(() => {}).catch(() => {});
      }
    }

    // ── Build response message ────────────────────────────────────────────────
    let message;
    if (hasInside && restoredPackIds.length > 0) {
      const packNames = restoredPackIds
        .map((pid) => {
          const meta = {
            stoicism_deep: "Stoicism Deep Dive",
            existentialism: "Existentialism",
            zen_mindfulness: "Zen & Mindfulness",
          };
          return meta[pid] ?? pid;
        })
        .join(", ");
      message = `Your purchases have been restored: ${packNames}.`;
    } else if (hasInside) {
      message = "MindScrolling Inside restored.";
    } else {
      // Only packs restored (no Inside)
      const packNames = restoredPackIds
        .map((pid) => {
          const meta = {
            stoicism_deep: "Stoicism Deep Dive",
            existentialism: "Existentialism",
            zen_mindfulness: "Zen & Mindfulness",
          };
          return meta[pid] ?? pid;
        })
        .join(", ");
      message = `Your purchases have been restored: ${packNames}.`;
    }

    return reply.status(200).send({
      restored: true,
      plan: hasInside ? PLAN_NAME : null,
      restored_packs: restoredPackIds,
      message,
    });
  });

  // ── POST /premium/unlock (legacy — backward compatibility) ────────────────
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

    const { error: upgradeErr } = await supabase
      .from("users")
      .update({
        is_premium: true,
        premium_status: "premium_onetime",
        premium_source: "legacy_unlock",
        premium_since: new Date().toISOString(),
      })
      .eq("device_id", deviceId);

    if (upgradeErr) {
      return reply.status(500).send({ error: "Failed to activate premium", code: "DB_ERROR" });
    }

    return reply.status(200).send({ ok: true, is_premium: true, unlocked: true });
  });

  // ── POST /premium/redeem ──────────────────────────────────────────────────
  /**
   * Validates an activation code and grants premium_lifetime.
   * Unchanged from pre-Block B.
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

    const { data: codeRow, error: lookupErr } = await supabase
      .from("premium_activation_codes")
      .select("*")
      .eq("code", cleanCode)
      .maybeSingle();

    if (lookupErr) {
      request.log.error({ err: lookupErr }, "premium/redeem: lookup failed");
      return reply.status(500).send({ error: "Failed to validate code", code: "DB_ERROR" });
    }

    if (!codeRow) {
      return reply.status(404).send({ error: "Code not found", code: "CODE_NOT_FOUND" });
    }
    if (codeRow.revoked) {
      return reply.status(410).send({ error: "This code has been revoked", code: "CODE_REVOKED" });
    }
    if (codeRow.is_redeemed) {
      return reply.status(409).send({ error: "This code has already been used", code: "CODE_ALREADY_REDEEMED" });
    }
    if (codeRow.expires_at && new Date(codeRow.expires_at) < new Date()) {
      return reply.status(410).send({ error: "This code has expired", code: "CODE_EXPIRED" });
    }

    const now = new Date().toISOString();

    const { error: redeemErr } = await supabase
      .from("premium_activation_codes")
      .update({ is_redeemed: true, redeemed_by: deviceId, redeemed_at: now })
      .eq("id", codeRow.id);

    if (redeemErr) {
      request.log.error({ err: redeemErr }, "premium/redeem: failed to mark code");
      return reply.status(500).send({ error: "Failed to redeem code", code: "DB_ERROR" });
    }

    await supabase
      .from("users")
      .upsert({ device_id: deviceId }, { onConflict: "device_id" });

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

    supabase.from("premium_audit_log").insert({
      device_id: deviceId,
      event_type: "code_redeemed",
      source: "activation_code",
      metadata: {
        code_id: codeRow.id,
        code: cleanCode,
        type: codeRow.type,
        assigned_email: codeRow.assigned_email,
      },
    }).then(() => {}).catch(() => {});

    request.log.info({ deviceId, code: cleanCode }, "premium/redeem: code redeemed successfully");

    return reply.status(200).send({
      success: true,
      plan: PLAN_NAME,
      type: codeRow.type,
      message: "MindScrolling Inside activated!",
    });
  });
}
