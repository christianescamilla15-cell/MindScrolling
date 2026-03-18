import { supabase } from "../db/client.js";

const VALID_AGE_RANGES  = ["18-24", "25-34", "35-44", "45+"];
const VALID_INTERESTS   = ["philosophy", "stoicism", "personal_growth", "mindfulness", "curiosity"];
const VALID_GOALS       = ["calm_mind", "discipline", "meaning", "emotional_clarity"];
const VALID_LANGUAGES   = ["en", "es"];

export default async function profileRoutes(fastify) {
  /**
   * POST /profile
   * Body: { age_range, interest, goal, preferred_language }
   * Upserts user row then user_profiles row.
   */
  fastify.post("/", async (request, reply) => {
    const deviceId = request.deviceId;
    const { age_range, interest, goal, preferred_language = "en" } = request.body ?? {};

    // Validate
    if (age_range && !VALID_AGE_RANGES.includes(age_range)) {
      return reply.status(400).send({ error: `age_range must be one of: ${VALID_AGE_RANGES.join(", ")}`, code: "INVALID_FIELD" });
    }
    if (interest && !VALID_INTERESTS.includes(interest)) {
      return reply.status(400).send({ error: `interest must be one of: ${VALID_INTERESTS.join(", ")}`, code: "INVALID_FIELD" });
    }
    if (goal && !VALID_GOALS.includes(goal)) {
      return reply.status(400).send({ error: `goal must be one of: ${VALID_GOALS.join(", ")}`, code: "INVALID_FIELD" });
    }
    if (preferred_language && !VALID_LANGUAGES.includes(preferred_language)) {
      return reply.status(400).send({ error: `preferred_language must be one of: ${VALID_LANGUAGES.join(", ")}`, code: "INVALID_FIELD" });
    }

    // Ensure the user row exists first (FK requirement)
    const { error: userErr } = await supabase
      .from("users")
      .upsert({ device_id: deviceId }, { onConflict: "device_id" });

    if (userErr) {
      return reply.status(500).send({ error: "Failed to initialise user", code: "INTERNAL_ERROR" });
    }

    // Upsert profile
    const { error: profileErr } = await supabase
      .from("user_profiles")
      .upsert(
        {
          device_id:          deviceId,
          age_range:          age_range          ?? null,
          interest:           interest           ?? null,
          goal:               goal               ?? null,
          preferred_language: preferred_language,
          updated_at:         new Date().toISOString(),
        },
        { onConflict: "device_id" }
      );

    if (profileErr) {
      return reply.status(500).send({ error: "Failed to save profile", code: "INTERNAL_ERROR" });
    }

    return reply.status(200).send({ ok: true });
  });

  /**
   * GET /profile
   * Returns the user profile or null if not found.
   */
  fastify.get("/", async (request, reply) => {
    const deviceId = request.deviceId;

    const { data, error } = await supabase
      .from("user_profiles")
      .select("device_id, age_range, interest, goal, preferred_language, created_at, updated_at")
      .eq("device_id", deviceId)
      .maybeSingle();

    if (error) {
      return reply.status(500).send({ error: "Failed to fetch profile", code: "INTERNAL_ERROR" });
    }

    return reply.send({ data: data ?? null });
  });
}
