import crypto from "crypto";
import { supabase } from "../db/client.js";

// ─── RevenueCat webhook event types that grant / revoke premium ───────────────
// https://www.revenuecat.com/docs/webhooks#events
const GRANT_EVENTS = new Set([
  "INITIAL_PURCHASE",
  "NON_SUBSCRIPTION_PURCHASE",
  "RENEWAL",
  "PRODUCT_CHANGE",
  "UNCANCELLATION",
]);

const REVOKE_EVENTS = new Set([
  "EXPIRATION",
  "CANCELLATION",
  "BILLING_ISSUE",
  "SUBSCRIBER_ALIAS",
]);

// ─── Shared secret set in RevenueCat dashboard → Project → Webhooks ──────────
const RC_WEBHOOK_SECRET = process.env.REVENUECAT_WEBHOOK_SECRET;

/**
 * Validates the RevenueCat webhook Authorization header.
 * RevenueCat sends: Authorization: <shared_secret>
 */
function verifyRevenueCatSecret(request, reply) {
  if (!RC_WEBHOOK_SECRET) {
    // In development without the secret configured, allow through with a warning
    if (process.env.NODE_ENV !== "production") {
      request.log.warn("REVENUECAT_WEBHOOK_SECRET not set — skipping auth in development");
      return true;
    }
    reply.status(503).send({ error: "Webhook not configured", code: "WEBHOOK_NOT_CONFIGURED" });
    return false;
  }

  const provided = request.headers["authorization"] ?? "";
  const providedBuf = Buffer.from(provided);
  const expectedBuf = Buffer.from(RC_WEBHOOK_SECRET);

  if (
    providedBuf.length !== expectedBuf.length ||
    !crypto.timingSafeEqual(providedBuf, expectedBuf)
  ) {
    reply.status(401).send({ error: "Unauthorized", code: "INVALID_WEBHOOK_SECRET" });
    return false;
  }
  return true;
}

export default async function webhooksRoutes(fastify) {
  /**
   * POST /webhooks/revenuecat
   *
   * Receives server-to-server purchase events from RevenueCat.
   * Grants or revokes premium entitlement on the users table
   * based on the event type and app_user_id (= device_id).
   *
   * RevenueCat setup:
   *   1. Go to RevenueCat dashboard → Project → Webhooks
   *   2. Add webhook URL: https://your-backend.railway.app/webhooks/revenuecat
   *   3. Set a shared secret and copy it to env: REVENUECAT_WEBHOOK_SECRET=<secret>
   *
   * Event payload reference:
   *   https://www.revenuecat.com/docs/webhooks#sample-events
   */
  fastify.post("/revenuecat", async (request, reply) => {
    if (!verifyRevenueCatSecret(request, reply)) return;

    const body = request.body;
    const event = body?.event;

    if (!event) {
      return reply.status(400).send({ error: "Missing event", code: "INVALID_PAYLOAD" });
    }

    const {
      type,
      app_user_id: deviceId,
      product_id:  productId,
      store,
      environment,
      purchased_at_ms: purchasedAtMs,
    } = event;

    if (!deviceId) {
      return reply.status(400).send({ error: "Missing app_user_id", code: "INVALID_PAYLOAD" });
    }

    request.log.info(
      { type, deviceId, productId, store, environment },
      "revenuecat webhook received"
    );

    // Ignore sandbox events in production
    if (process.env.NODE_ENV === "production" && environment === "SANDBOX") {
      request.log.info({ type, deviceId }, "revenuecat: ignoring sandbox event in production");
      return reply.status(200).send({ ok: true, ignored: true, reason: "sandbox" });
    }

    // ── Grant premium ──────────────────────────────────────────────────────────
    if (GRANT_EVENTS.has(type)) {
      // Ensure user row exists
      await supabase
        .from("users")
        .upsert({ device_id: deviceId }, { onConflict: "device_id" });

      const premiumSource = store === "APP_STORE" ? "app_store" : "play_billing";
      const purchasedAt   = purchasedAtMs
        ? new Date(purchasedAtMs).toISOString()
        : new Date().toISOString();

      const { error: updateErr } = await supabase
        .from("users")
        .update({
          is_premium:           true,
          premium_status:       "active",
          premium_source:       premiumSource,
          premium_activated_at: purchasedAt,
        })
        .eq("device_id", deviceId);

      if (updateErr) {
        request.log.error({ err: updateErr, deviceId, type }, "revenuecat: failed to grant premium");
        return reply.status(500).send({ error: "Failed to grant premium", code: "INTERNAL_ERROR" });
      }

      // Audit
      await supabase.from("premium_audit_log").insert({
        device_id:  deviceId,
        event_type: "premium_granted_webhook",
        source:     premiumSource,
        metadata: {
          rc_event_type: type,
          product_id:    productId,
          store,
          environment,
          purchased_at:  purchasedAt,
        },
      }).then(() => {}).catch(() => {});

      request.log.info({ deviceId, type, productId }, "revenuecat: premium granted");
      return reply.status(200).send({ ok: true, action: "granted" });
    }

    // ── Revoke premium ─────────────────────────────────────────────────────────
    if (REVOKE_EVENTS.has(type)) {
      // For MindScrolling Inside (one-time purchase), EXPIRATION/CANCELLATION
      // should NOT revoke access — the product is lifetime.
      // We log the event but keep is_premium = true.
      // Only BILLING_ISSUE on a subscription-style product would revoke.
      request.log.info(
        { deviceId, type },
        "revenuecat: revoke event received — no-op for lifetime product"
      );

      await supabase.from("premium_audit_log").insert({
        device_id:  deviceId,
        event_type: "revoke_event_ignored",
        source:     "revenuecat_webhook",
        metadata: { rc_event_type: type, product_id: productId, store, environment },
      }).then(() => {}).catch(() => {});

      return reply.status(200).send({ ok: true, action: "no-op", reason: "lifetime_product" });
    }

    // Unknown event type — acknowledge and log
    request.log.info({ type, deviceId }, "revenuecat: unhandled event type");
    return reply.status(200).send({ ok: true, action: "unhandled" });
  });
}
