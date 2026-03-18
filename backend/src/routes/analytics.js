/**
 * POST /analytics/event
 *
 * Lightweight server-side event logger for key funnel events.
 * Events are logged to the server console (visible in Render dashboard).
 * No DB writes — pure log-based analytics for the closed-testing phase.
 *
 * Payload: { event_type: string, app_version?: string, properties?: object }
 *
 * Key events:
 *   app_opened         — fires on every cold launch with app_version
 *   onboarding_completed — fires when the user finishes the 3-screen onboarding
 */

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

    return reply.status(202).send({ ok: true });
  });
}
