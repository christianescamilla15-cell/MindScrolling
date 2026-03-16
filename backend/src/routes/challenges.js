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

    // Fetch progress (only if a real DB challenge exists)
    let progress = { progress: 0, completed: false };

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
   * Body: { progress, completed }
   * Upserts challenge_progress for this device.
   */
  fastify.post("/:id/progress", async (request, reply) => {
    const deviceId    = request.deviceId;
    const challengeId = request.params.id;
    const { progress = 0, completed = false } = request.body ?? {};

    if (typeof progress !== "number") {
      return reply.status(400).send({ error: "progress must be a number", code: "INVALID_FIELD" });
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

    // Upsert progress
    const { error: upsertErr } = await supabase
      .from("challenge_progress")
      .upsert(
        {
          device_id:    deviceId,
          challenge_id: challengeId,
          progress:     Number(progress),
          completed:    Boolean(completed),
          updated_at:   new Date().toISOString(),
        },
        { onConflict: "device_id,challenge_id" }
      );

    if (upsertErr) {
      return reply.status(500).send({ error: "Failed to update progress", code: "DB_ERROR" });
    }

    return reply.status(200).send({ updated: true });
  });
}
