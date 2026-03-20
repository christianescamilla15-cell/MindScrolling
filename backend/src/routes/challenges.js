import { supabase } from "../db/client.js";
import { UUID_RE, normalizeLang } from "../utils/validation.js";

// Fallback challenge shown when no DB entry exists for today
const DEFAULT_CHALLENGE = {
  id:          "default",
  code:        "daily_reflection",
  title:       "Daily Reflection",
  description: "Read 5 quotes today and reflect on one that resonates with you. Write down a single sentence about what it means in your life.",
  active_date: null,
};

// ── In-memory Spanish translations keyed by challenge code ───────────────────
// Used until the DB supports a lang column on daily_challenges.
const CHALLENGE_TRANSLATIONS_ES = {
  daily_reflection: {
    title:       "Reflexión diaria",
    description: "Lee 5 frases hoy y reflexiona sobre una que resuene contigo. Escribe una sola oración sobre lo que significa en tu vida.",
  },
  deep_read: {
    title:       "Lectura profunda",
    description: "Dedica al menos 5 segundos a cada frase antes de deslizar. Observa qué ideas te detienen.",
  },
  stoic_focus: {
    title:       "Enfoque estoico",
    description: "Hoy, desliza hacia arriba las frases que hablen de resiliencia y virtud. Encuentra 8 que te inspiren.",
  },
  mindful_vault: {
    title:       "Bóveda consciente",
    description: "Guarda 3 frases en tu bóveda que quieras releer esta semana.",
  },
  philosophy_explorer: {
    title:       "Explorador filosófico",
    description: "Lee frases de al menos 3 categorías diferentes hoy. Observa cuál te atrae más.",
  },
};

/** Translate a challenge object to the target language (in-memory). */
function translateChallenge(challenge, lang) {
  if (lang !== "es") return challenge;
  const tr = CHALLENGE_TRANSLATIONS_ES[challenge.code];
  if (!tr) return challenge;
  return { ...challenge, title: tr.title, description: tr.description };
}

export default async function challengesRoutes(fastify) {
  /**
   * GET /challenges/today
   * Query: ?lang=en|es
   * Returns today's challenge and the device's progress on it.
   */
  fastify.get("/today", async (request, reply) => {
    const deviceId  = request.deviceId;
    const lang      = normalizeLang(request.query.lang);
    const todayStr  = new Date().toISOString().slice(0, 10); // "YYYY-MM-DD"

    // Fetch today's challenge
    const { data: challenge, error: challengeErr } = await supabase
      .from("daily_challenges")
      .select("*")
      .eq("active_date", todayStr)
      .maybeSingle();

    if (challengeErr) {
      return reply.status(500).send({ error: "Failed to fetch challenge", code: "INTERNAL_ERROR" });
    }

    const activeChallenge = translateChallenge(
      challenge ?? { ...DEFAULT_CHALLENGE, active_date: todayStr },
      lang,
    );

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
        return reply.status(500).send({ error: "Failed to fetch progress", code: "INTERNAL_ERROR" });
      }

      if (prog) {
        progress = { progress: prog.progress, completed: prog.completed };
      }
    }

    return reply.send({ challenge: activeChallenge, progress, target: 8 });
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
    const { count = 1 } = request.body ?? {};

    if (!UUID_RE.test(challengeId)) {
      return reply.status(400).send({ error: "Invalid challenge ID format", code: "INVALID_FIELD" });
    }

    // Validate count (how many swipes to add, defaults to 1)
    if (typeof count !== "number" || !Number.isInteger(count) || count < 1 || count > 20) {
      return reply.status(400).send({ error: "count must be an integer between 1 and 20", code: "INVALID_FIELD" });
    }

    // Ensure user row exists
    const { error: userErr } = await supabase
      .from("users")
      .upsert({ device_id: deviceId }, { onConflict: "device_id" });

    if (userErr) {
      return reply.status(500).send({ error: "Failed to initialise user", code: "INTERNAL_ERROR" });
    }

    // Verify the challenge exists
    const { data: challenge, error: challengeErr } = await supabase
      .from("daily_challenges")
      .select("id")
      .eq("id", challengeId)
      .maybeSingle();

    if (challengeErr) {
      return reply.status(500).send({ error: "Failed to verify challenge", code: "INTERNAL_ERROR" });
    }
    if (!challenge) {
      return reply.status(404).send({ error: "Challenge not found", code: "NOT_FOUND" });
    }

    // Fetch current server-side progress
    const { data: existing, error: progressErr } = await supabase
      .from("challenge_progress")
      .select("progress, completed")
      .eq("device_id", deviceId)
      .eq("challenge_id", challengeId)
      .maybeSingle();

    if (progressErr) {
      return reply.status(500).send({ error: "Failed to fetch progress", code: "INTERNAL_ERROR" });
    }

    // If already completed, return immediately
    if (existing?.completed) {
      return reply.status(200).send({ updated: false, completed: true, progress: existing.progress, target: TARGET_QUOTES });
    }

    // Atomic increment via SQL to prevent TOCTOU race on concurrent requests.
    // Uses INSERT ... ON CONFLICT with LEAST() so progress never exceeds target.
    const { data: result, error: upsertErr } = await supabase.rpc("increment_challenge_progress", {
      p_device_id: deviceId,
      p_challenge_id: challengeId,
      p_count: count,
      p_target: TARGET_QUOTES,
    });

    if (upsertErr) {
      fastify.log.error({ err: upsertErr }, "challenges/progress: increment_challenge_progress RPC failed — ensure migration 020 has been applied");
      return reply.status(500).send({ error: "Failed to update progress", code: "INTERNAL_ERROR" });
    }

    const row = Array.isArray(result) ? result[0] : result;
    const newProgress = row?.progress ?? 0;
    const completed = row?.completed ?? false;

    return reply.status(200).send({ updated: true, progress: newProgress, completed, target: TARGET_QUOTES });
  });
}
