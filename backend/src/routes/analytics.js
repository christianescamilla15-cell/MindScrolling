/**
 * POST /analytics/event
 *
 * Lightweight server-side event logger for key funnel events.
 * Events are logged to the server console (visible in Render dashboard)
 * and persisted to the analytics_events table (migration 021).
 *
 * Payload: { event_type: string, app_version?: string, properties?: object }
 */

import { supabase } from "../db/client.js";

// HIGH-04: Allowlist of valid event types to prevent cache poisoning
const VALID_EVENT_TYPES = new Set([
  "app_opened",
  "onboarding_completed",
  "feed_loaded",
  "quote_shared",
  "pack_catalog_viewed",
  "pack_preview_started",
  "pack_preview_completed",
  "pack_paywall_shown",
  "pack_purchased",
  "pack_feed_entered",
  "premium_screen_viewed",
  "premium_purchase_started",
  "premium_trial_started",
  "daily_pick",
  "mood_entry",
]);

// Max JSON size for properties (4KB)
const MAX_PROPERTIES_SIZE = 4096;

export default async function analyticsRoutes(fastify) {
  fastify.post("/event", {
    config: {
      // MED-07: Per-device rate limit for analytics
      rateLimit: {
        max: 30,
        timeWindow: 60_000,
        keyGenerator: (req) => req.deviceId ?? req.ip,
      },
    },
  }, async (request, reply) => {
    const { deviceId } = request;
    const { event_type, app_version, properties } = request.body ?? {};

    if (!event_type || typeof event_type !== "string") {
      return reply.status(400).send({ error: "event_type required", code: "MISSING_FIELD" });
    }

    // HIGH-04: Validate event_type against allowlist
    if (!VALID_EVENT_TYPES.has(event_type)) {
      return reply.status(400).send({ error: "Unknown event_type", code: "INVALID_FIELD" });
    }

    // HIGH-04: Cap properties size
    const propsObj = properties && typeof properties === "object" ? properties : {};
    const propsJson = JSON.stringify(propsObj);
    if (propsJson.length > MAX_PROPERTIES_SIZE) {
      return reply.status(400).send({ error: "properties too large (max 4KB)", code: "INVALID_FIELD" });
    }

    // Structured log — visible in Render Log Stream dashboard
    fastify.log.info(
      {
        analytics: true,
        event_type,
        device_id: deviceId ? deviceId.slice(0, 8) + "…" : "unknown",
        app_version: app_version ?? "unknown",
      },
      `[analytics] ${event_type}`
    );

    // Persist to analytics_events table — fire-and-forget
    supabase
      .from("analytics_events")
      .insert({
        device_id: deviceId,
        event_type,
        properties: {
          ...propsObj,
          ...(app_version ? { app_version } : {}),
        },
      })
      .then(() => {})
      .catch((err) => {
        fastify.log.warn({ err, event_type }, "[analytics] failed to persist event to DB");
      });

    return reply.status(202).send({ ok: true });
  });
}
