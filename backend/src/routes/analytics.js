/**
 * POST /analytics/event
 *
 * Lightweight server-side event logger for key funnel events.
 * Events are logged to the server console (visible in Render dashboard)
 * and persisted to the analytics_events table (migration 021).
 *
 * Payload: { event_type: string, app_version?: string, properties?: object }
 *
 * Key events:
 *   app_opened         — fires on every cold launch with app_version
 *   onboarding_completed — fires when the user finishes the 3-screen onboarding
 */

import { supabase } from "../db/client.js";

export default async function analyticsRoutes(fastify) {
  fastify.post("/event", async (request, reply) => {
    const { deviceId } = request;
    const { event_type, app_version, properties } = request.body ?? {};

    if (!event_type || typeof event_type !== "string") {
      return reply.status(400).send({ error: "event_type required", code: "MISSING_FIELD" });
    }

    // Structured log — visible in Render Log Stream dashboard
    fastify.log.info(
      {
        analytics: true,
        event_type,
        device_id: deviceId ? deviceId.slice(0, 8) + "…" : "unknown", // partial for privacy
        app_version: app_version ?? "unknown",
        properties: properties ?? {},
      },
      `[analytics] ${event_type}`
    );

    // Persist to analytics_events table — fire-and-forget so DB latency never
    // blocks the 202 response. Errors are logged but not surfaced to the client.
    supabase
      .from("analytics_events")
      .insert({
        device_id: deviceId,
        event_type,
        properties: {
          ...(properties ?? {}),
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
