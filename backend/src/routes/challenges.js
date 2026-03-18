import { supabase } from "../db/client.js";

// Fallback challenge shown when no DB entry exists for today
const DEFAULT_CHALLENGE = {
  id:          "default",
  code:        "daily_reflection",
  title:       "Daily Reflection",
  description: "Read 5 quotes today and reflect on one that resonates with you. Write down a single sentence about what it means in your life.",
  active_date: null,
};

export default async function challengesRoutes(fastify) {
  /**
   * GET /challenges/today
   * Returns today's challenge and the device's progress on it.
   */
  fastify.get("/today", async (request, reply) => {
    const deviceId  = request.deviceId;
    const todayStr  = new Date().toISOString().slice(0, 10); // "YYYY-MM-DD"

    // Fetch today's challenge
    const { data: challenge, error: challengeErr } = await supabase
      .from("daily_challenges")
      .select("*")
      .eq("active_date", todayStr)
      .maybeSingle();

    if (challengeErr) {
      return reply.status(500).send({ error: "Failed to fetch challenge", code: "DB_ERROR" });
    }

    const activeChallenge = challenge ?? { ...DEFAULT_CHALLENGE, active_date: todayStr };

    // Fetch progress — null if the device has never interacted with this challenge
    let progress = null;

    if (challenge) {
      const { data: prog, error: progErr } = await supabase
        .from("challenge_progress")
        .select("progress, completed")
        .eq("device_id", deviceId)
        .eq("challenge_id", challenge.id)
        .maybeSingle();

      if (progErr) {
        return reply.status(500).send({ error: "Failed to fetch progress", code: "DB_ERROR" });
      }

      if (prog) {
        progress = { progress: prog.progress, completed: prog.completed };
      }
    }

    return reply.send({ challenge: activeChallenge, progress });
  });

  /**
   * POST /challenges/:id/progress
   * Body: { progress }
   * Increments challenge progress by 1. Server enforces the completion rule:
   * a challenge completes automatically when progress reaches TARGET_QUOTES.
   * Clients must NOT send completed=true — the server derives it.
   */
  fastify.post("/:id/progress", async (request, reply) => {
    const TARGET_QUOTES = 8; // quotes required to complete a challenge

    const deviceId    = request.deviceId;
    const challengeId = request.params.id;
    const { progress: clientProgress } = request.body ?? {};

    // Validate progress if explicitly provided (must be a non-negative integer)
    if (clientProgress !== undefined) {
      if (typeof clientProgress !== "number" || !Number.isInteger(clientProgress) || clientProgress < 0) {
        return reply.status(400).send({ error: "progress must be a non-negative integer", code: "INVALID_FIELD" });
      }
      // Reject client-side completion claims
      if (clientProgress >= TARGET_QUOTES) {
        return reply.status(400).send({ error: "Progress can only be incremented by 1 per call", code: "INVALID_FIELD" });
      }
    }

    // Ensure user row exists
    const { error: userErr } = await supabase
      .from("users")
      .upsert({ device_id: deviceId }, { onConflict: "device_id" });

    if (userErr) {
      return reply.status(500).send({ error: "Failed to initialise user", code: "DB_ERROR" });
    }

    // Verify the challenge exists
    const { data: challenge, error: challengeErr } = await supabase
      .from("daily_challenges")
      .select("id")
      .eq("id", challengeId)
      .maybeSingle();

    if (challengeErr) {
      return reply.status(500).send({ error: "Failed to verify challenge", code: "DB_ERROR" });
    }
    if (!challenge) {
      return reply.status(404).send({ error: "Challenge not found", code: "NOT_FOUND" });
    }

    // Fetch current server-side progress
    const { data: existing } = await supabase
      .from("challenge_progress")
      .select("progress, completed")
      .eq("device_id", deviceId)
      .eq("challenge_id", challengeId)
      .maybeSingle();

    // If already completed, return immediately
    if (existing?.completed) {
      return reply.status(200).send({ updated: false, completed: true, progress: existing.progress });
    }

    // Increment server-side progress by 1
    const newProgress = (existing?.progress ?? 0) + 1;
    const completed   = newProgress >= TARGET_QUOTES;

    const { error: upsertErr } = await supabase
      .from("challenge_progress")
      .upsert(
        {
          device_id:    deviceId,
          challenge_id: challengeId,
          progress:     newProgress,
          completed,
          updated_at:   new Date().toISOString(),
        },
        { onConflict: "device_id,challenge_id" }
      );

    if (upsertErr) {
      return reply.status(500).send({ error: "Failed to update progress", code: "DB_ERROR" });
    }

    return reply.status(200).send({ updated: true, progress: newProgress, completed });
  });
}
