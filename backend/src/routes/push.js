/**
 * push.js — Web Push subscription management + delivery helper
 *
 * Endpoints:
 *   POST   /push/subscribe         — register a PushSubscription for this device
 *   DELETE /push/subscribe         — unregister all subscriptions for this device
 *   GET    /push/vapid-public-key  — return VAPID public key (no auth needed for client bootstrap)
 *
 * Helper exported for other routes:
 *   sendPushToDevice(deviceId, payload) — deliver a notification to one device
 *
 * VAPID env vars (set in Render):
 *   VAPID_PUBLIC_KEY    — base64url public key
 *   VAPID_PRIVATE_KEY   — base64url private key
 *   VAPID_SUBJECT       — mailto:owner@example.com (RFC 8292 contact)
 */

import webpush from "web-push";
import { supabase } from "../db/client.js";

// ─── VAPID setup (runs once at boot) ─────────────────────────────────────────
const VAPID_PUBLIC  = process.env.VAPID_PUBLIC_KEY;
const VAPID_PRIVATE = process.env.VAPID_PRIVATE_KEY;
const VAPID_SUBJECT = process.env.VAPID_SUBJECT || "mailto:christianescamilla15@gmail.com";

let vapidConfigured = false;
if (VAPID_PUBLIC && VAPID_PRIVATE) {
  webpush.setVapidDetails(VAPID_SUBJECT, VAPID_PUBLIC, VAPID_PRIVATE);
  vapidConfigured = true;
}

/**
 * Send a push to every subscription a device has registered.
 * Auto-prunes subscriptions that return 404/410 (unsubscribed).
 *
 * @param {string} deviceId
 * @param {{ title: string, body: string, url?: string, icon?: string }} payload
 * @returns {Promise<{ delivered: number, pruned: number }>}
 */
export async function sendPushToDevice(deviceId, payload) {
  if (!vapidConfigured) return { delivered: 0, pruned: 0 };

  const { data: subs, error } = await supabase
    .from("push_subscriptions")
    .select("id, endpoint, p256dh, auth")
    .eq("device_id", deviceId);

  if (error || !subs || subs.length === 0) {
    return { delivered: 0, pruned: 0 };
  }

  const body = JSON.stringify(payload);
  let delivered = 0;
  let pruned = 0;
  const stale = [];

  await Promise.all(subs.map(async (s) => {
    const sub = { endpoint: s.endpoint, keys: { p256dh: s.p256dh, auth: s.auth } };
    try {
      await webpush.sendNotification(sub, body);
      delivered++;
    } catch (err) {
      const sc = err?.statusCode;
      if (sc === 404 || sc === 410) {
        stale.push(s.id);
        pruned++;
      }
    }
  }));

  if (stale.length > 0) {
    await supabase.from("push_subscriptions").delete().in("id", stale);
  }

  return { delivered, pruned };
}

export default async function pushRoutes(fastify) {

  // ── GET /push/vapid-public-key ────────────────────────────────────────────
  // Lets the client bootstrap without bundling the key at build time.
  // Note: deviceId plugin still gates this — frontend hits with X-Device-ID.
  fastify.get("/vapid-public-key", async (_request, reply) => {
    if (!vapidConfigured) {
      return reply.status(503).send({ error: "Push not configured", code: "VAPID_MISSING" });
    }
    return reply.send({ public_key: VAPID_PUBLIC });
  });

  // ── POST /push/subscribe ──────────────────────────────────────────────────
  // Body: { endpoint: string, keys: { p256dh: string, auth: string } }
  // (matches PushSubscription.toJSON() output)
  fastify.post("/subscribe", async (request, reply) => {
    if (!vapidConfigured) {
      return reply.status(503).send({ error: "Push not configured on server", code: "VAPID_MISSING" });
    }

    const deviceId = request.deviceId;
    const { endpoint, keys } = request.body || {};
    const userAgent = request.headers["user-agent"] || null;

    if (!endpoint || typeof endpoint !== "string") {
      return reply.status(400).send({ error: "endpoint required", code: "MISSING_ENDPOINT" });
    }
    if (!keys || !keys.p256dh || !keys.auth) {
      return reply.status(400).send({ error: "keys.p256dh and keys.auth required", code: "MISSING_KEYS" });
    }

    const { error } = await supabase
      .from("push_subscriptions")
      .upsert(
        {
          device_id:    deviceId,
          endpoint,
          p256dh:       keys.p256dh,
          auth:         keys.auth,
          user_agent:   userAgent,
          last_seen_at: new Date().toISOString(),
        },
        { onConflict: "device_id,endpoint" }
      );

    if (error) {
      request.log.error({ err: error }, "push_subscribe_failed");
      return reply.status(500).send({ error: "Failed to store subscription", code: "DB_ERROR" });
    }

    return reply.send({ ok: true });
  });

  // ── DELETE /push/subscribe ────────────────────────────────────────────────
  // Removes ALL push subscriptions for this device. Used when the user
  // turns notifications off in Settings or revokes browser permission.
  fastify.delete("/subscribe", async (request, reply) => {
    const deviceId = request.deviceId;
    const { error } = await supabase
      .from("push_subscriptions")
      .delete()
      .eq("device_id", deviceId);

    if (error) {
      request.log.error({ err: error }, "push_unsubscribe_failed");
      return reply.status(500).send({ error: "Failed to remove subscription", code: "DB_ERROR" });
    }
    return reply.send({ ok: true });
  });
}
