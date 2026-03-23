/**
 * exercises.js — Programming Exercises routes
 *
 * Endpoints:
 *   GET  /exercises/list              — paginated list filtered by language/difficulty/category
 *   GET  /exercises/stats             — user's exercise completion stats
 *   GET  /exercises/languages         — available languages with counts per difficulty
 *   GET  /exercises/:id               — full exercise detail + user progress
 *   POST /exercises/:id/hint          — record hint view, return hint content
 *   POST /exercises/:id/submit        — record submission, validate, award points
 *
 * NOTE: /exercises/stats and /exercises/languages must be registered BEFORE
 * /exercises/:id so that Fastify does not match "stats" or "languages" as an :id param.
 */

import { supabase }              from "../db/client.js";
import { UUID_RE, normalizeLang } from "../utils/validation.js";

// Points awarded per difficulty level on correct submission
const POINTS_BY_DIFFICULTY = { 1: 10, 2: 20, 3: 30, 4: 50, 5: 80 };

// Maximum hints allowed per exercise
const MAX_HINTS = 3;

// Maximum allowed limit per page
const MAX_LIMIT = 50;

export default async function exercisesRoutes(fastify) {

  // ── GET /exercises/list ────────────────────────────────────────────────────
  /**
   * Paginated exercise list with optional filters.
   * Query: ?language=python&difficulty=2&category=loops&lang=en&limit=20&cursor=<uuid>
   * Returns user progress status per exercise joined from exercise_progress.
   */
  fastify.get("/list", async (request, reply) => {
    const { deviceId }  = request;
    const lang          = normalizeLang(request.query.lang);
    const { language, difficulty, category, cursor } = request.query;
    const rawLimit      = Number(request.query.limit ?? 20);

    if (!Number.isInteger(rawLimit) || rawLimit < 1 || rawLimit > MAX_LIMIT) {
      return reply.status(400).send({
        error: `limit must be an integer between 1 and ${MAX_LIMIT}`,
        code:  "INVALID_FIELD",
      });
    }

    if (difficulty !== undefined) {
      const d = Number(difficulty);
      if (!Number.isInteger(d) || d < 1 || d > 5) {
        return reply.status(400).send({
          error: "difficulty must be an integer between 1 and 5",
          code:  "INVALID_FIELD",
        });
      }
    }

    if (cursor !== undefined && !UUID_RE.test(cursor)) {
      return reply.status(400).send({ error: "cursor must be a valid UUID", code: "INVALID_FIELD" });
    }

    // Select localised columns
    const titleCol = lang === "es" ? "title_es" : "title_en";
    const descCol  = lang === "es" ? "description_es" : "description_en";

    let query = supabase
      .from("exercises")
      .select(
        `id, ${titleCol}, ${descCol}, language, difficulty, category, points, hint_count, created_at`,
        { count: "exact" }
      )
      .order("id", { ascending: true })
      .limit(rawLimit + 1); // fetch one extra to detect has_more

    if (language)             query = query.eq("language", language);
    if (difficulty !== undefined) query = query.eq("difficulty", Number(difficulty));
    if (category)             query = query.eq("category", category);
    if (cursor)               query = query.gt("id", cursor);

    // Parallel: exercises + user progress for this device
    const [exercisesRes, progressRes] = await Promise.all([
      query,
      supabase
        .from("exercise_progress")
        .select("exercise_id, status, hints_used, attempts")
        .eq("device_id", deviceId),
    ]);

    if (exercisesRes.error) {
      request.log.error({ err: exercisesRes.error }, "exercises/list: DB error");
      return reply.status(500).send({ error: "Failed to fetch exercises", code: "INTERNAL_ERROR" });
    }

    if (progressRes.error) {
      request.log.error({ err: progressRes.error }, "exercises/list: progress fetch error");
      return reply.status(500).send({ error: "Failed to fetch progress", code: "INTERNAL_ERROR" });
    }

    const rawRows = exercisesRes.data ?? [];
    const total   = exercisesRes.count ?? 0;

    // Build a progress lookup keyed by exercise_id
    const progressMap = {};
    for (const p of progressRes.data ?? []) {
      progressMap[p.exercise_id] = {
        status:     p.status,
        hints_used: p.hints_used,
        attempts:   p.attempts,
      };
    }

    const hasMore   = rawRows.length > rawLimit;
    const pageRows  = hasMore ? rawRows.slice(0, rawLimit) : rawRows;
    const nextCursor = hasMore && pageRows.length > 0 ? pageRows[pageRows.length - 1].id : null;

    const data = pageRows.map((row) => ({
      id:          row.id,
      title:       row[titleCol]  ?? row.title_en ?? null,
      description: row[descCol]   ?? row.description_en ?? null,
      language:    row.language,
      difficulty:  row.difficulty,
      category:    row.category,
      points:      row.points,
      hint_count:  row.hint_count,
      created_at:  row.created_at,
      progress:    progressMap[row.id] ?? null,
    }));

    return reply.send({ data, next_cursor: nextCursor, has_more: hasMore, total });
  });

  // ── GET /exercises/stats ───────────────────────────────────────────────────
  /**
   * User's aggregate exercise statistics.
   * Response: { total_completed, total_points, by_language, by_difficulty }
   */
  fastify.get("/stats", async (request, reply) => {
    const { deviceId } = request;

    const { data, error } = await supabase
      .from("exercise_progress")
      .select("status, points_earned, exercise_id, exercises(language, difficulty)")
      .eq("device_id", deviceId)
      .eq("status", "completed");

    if (error) {
      request.log.error({ err: error }, "exercises/stats: DB error");
      return reply.status(500).send({ error: "Failed to fetch exercise stats", code: "INTERNAL_ERROR" });
    }

    const rows = data ?? [];

    let total_completed = 0;
    let total_points    = 0;
    const by_language   = {};
    const by_difficulty = {};

    for (const row of rows) {
      total_completed += 1;
      total_points    += row.points_earned ?? 0;

      const lang = row.exercises?.language;
      const diff = row.exercises?.difficulty;

      if (lang) by_language[lang]   = (by_language[lang]   ?? 0) + 1;
      if (diff) by_difficulty[diff] = (by_difficulty[diff] ?? 0) + 1;
    }

    return reply.send({ total_completed, total_points, by_language, by_difficulty });
  });

  // ── GET /exercises/languages ───────────────────────────────────────────────
  /**
   * Lists available programming languages with exercise counts per difficulty.
   * Response: { languages: [{ id, name, icon, count, difficulties: { 1: n, ... } }] }
   */
  fastify.get("/languages", async (request, reply) => {
    const { data, error } = await supabase
      .from("exercises")
      .select("language, difficulty");

    if (error) {
      request.log.error({ err: error }, "exercises/languages: DB error");
      return reply.status(500).send({ error: "Failed to fetch languages", code: "INTERNAL_ERROR" });
    }

    // Aggregate counts per language and per difficulty inside that language
    const langMap = {};
    for (const row of data ?? []) {
      if (!row.language) continue;
      if (!langMap[row.language]) {
        langMap[row.language] = { count: 0, difficulties: {} };
      }
      langMap[row.language].count += 1;
      const d = row.difficulty;
      if (d) {
        langMap[row.language].difficulties[d] =
          (langMap[row.language].difficulties[d] ?? 0) + 1;
      }
    }

    // Fetch language metadata (name, icon) from exercise_languages if it exists;
    // fall back to a minimal object if the table is not yet seeded.
    const { data: langMeta, error: metaErr } = await supabase
      .from("exercise_languages")
      .select("id, name, icon");

    if (metaErr) {
      // Non-fatal: language metadata table may not yet exist.
      // Return aggregate-only response so the client still works.
      request.log.warn({ err: metaErr }, "exercises/languages: metadata table not available, returning aggregate only");
    }

    const metaByLang = {};
    for (const m of langMeta ?? []) {
      metaByLang[m.id] = { name: m.name, icon: m.icon };
    }

    const languages = Object.entries(langMap).map(([id, agg]) => ({
      id,
      name:         metaByLang[id]?.name ?? id,
      icon:         metaByLang[id]?.icon ?? null,
      count:        agg.count,
      difficulties: agg.difficulties,
    }));

    // Stable sort alphabetically by id
    languages.sort((a, b) => a.id.localeCompare(b.id));

    return reply.send({ languages });
  });

  // ── GET /exercises/:id ─────────────────────────────────────────────────────
  /**
   * Full exercise detail plus user progress.
   * Hints array returns only hint numbers, not content (content served by POST /hint).
   * Response: { exercise, progress: { status, hints_used, attempts } }
   */
  fastify.get("/:id", async (request, reply) => {
    const { deviceId } = request;
    const { id }       = request.params;
    const lang         = normalizeLang(request.query.lang);

    if (!UUID_RE.test(id)) {
      return reply.status(400).send({ error: "Invalid exercise ID format", code: "INVALID_FIELD" });
    }

    const titleCol = lang === "es" ? "title_es" : "title_en";
    const descCol  = lang === "es" ? "description_es" : "description_en";

    // Parallel: exercise row + user progress
    const [exerciseRes, progressRes] = await Promise.all([
      supabase
        .from("exercises")
        .select(
          `id, ${titleCol}, ${descCol}, language, difficulty, category, starter_code,
           expected_output, hint_count, points, created_at`
        )
        .eq("id", id)
        .maybeSingle(),
      supabase
        .from("exercise_progress")
        .select("status, hints_used, attempts")
        .eq("device_id", deviceId)
        .eq("exercise_id", id)
        .maybeSingle(),
    ]);

    if (exerciseRes.error) {
      request.log.error({ err: exerciseRes.error }, "exercises/:id: DB error");
      return reply.status(500).send({ error: "Failed to fetch exercise", code: "INTERNAL_ERROR" });
    }
    if (!exerciseRes.data) {
      return reply.status(404).send({ error: "Exercise not found", code: "NOT_FOUND" });
    }
    if (progressRes.error) {
      request.log.error({ err: progressRes.error }, "exercises/:id: progress fetch error");
      return reply.status(500).send({ error: "Failed to fetch progress", code: "INTERNAL_ERROR" });
    }

    const row = exerciseRes.data;
    const hintCount = row.hint_count ?? 0;

    // Return hint numbers only (1-based), not content
    const hints = Array.from({ length: hintCount }, (_, i) => i + 1);

    const exercise = {
      id:             row.id,
      title:          row[titleCol] ?? row.title_en ?? null,
      description:    row[descCol]  ?? row.description_en ?? null,
      language:       row.language,
      difficulty:     row.difficulty,
      category:       row.category,
      starter_code:   row.starter_code ?? null,
      hint_count:     hintCount,
      hints,
      points:         row.points,
      created_at:     row.created_at,
    };

    const prog = progressRes.data;
    const progress = prog
      ? { status: prog.status, hints_used: prog.hints_used ?? 0, attempts: prog.attempts ?? 0 }
      : { status: "not_started", hints_used: 0, attempts: 0 };

    return reply.send({ exercise, progress });
  });

  // ── POST /exercises/:id/hint ───────────────────────────────────────────────
  /**
   * Records that the user has viewed a hint and returns its content.
   * Body: { hint_number: 1|2|3 }
   * Response: { hint: string, hints_used: number }
   */
  fastify.post("/:id/hint", {
    config: {
      rateLimit: { max: 30, timeWindow: 60_000, keyGenerator: (req) => req.deviceId ?? req.ip },
    },
  }, async (request, reply) => {
    const { deviceId } = request;
    const { id }       = request.params;
    const lang         = normalizeLang(request.query?.lang ?? request.body?.lang);

    if (!UUID_RE.test(id)) {
      return reply.status(400).send({ error: "Invalid exercise ID format", code: "INVALID_FIELD" });
    }

    const { hint_number } = request.body ?? {};

    if (hint_number === undefined || hint_number === null) {
      return reply.status(400).send({ error: "hint_number is required", code: "MISSING_FIELD" });
    }
    if (!Number.isInteger(hint_number) || hint_number < 1 || hint_number > MAX_HINTS) {
      return reply.status(400).send({
        error: `hint_number must be an integer between 1 and ${MAX_HINTS}`,
        code:  "INVALID_FIELD",
      });
    }

    const hintCol = lang === "es" ? `hint_${hint_number}_es` : `hint_${hint_number}_en`;

    // Fetch the exercise (to validate it exists and retrieve hint content)
    const { data: exercise, error: exErr } = await supabase
      .from("exercises")
      .select(`id, hint_count, ${hintCol}`)
      .eq("id", id)
      .maybeSingle();

    if (exErr) {
      request.log.error({ err: exErr }, "exercises/:id/hint: exercise fetch error");
      return reply.status(500).send({ error: "Failed to fetch exercise", code: "INTERNAL_ERROR" });
    }
    if (!exercise) {
      return reply.status(404).send({ error: "Exercise not found", code: "NOT_FOUND" });
    }

    const hintCount = exercise.hint_count ?? 0;
    if (hint_number > hintCount) {
      return reply.status(400).send({
        error: `This exercise only has ${hintCount} hint(s)`,
        code:  "INVALID_FIELD",
      });
    }

    const hintContent = exercise[hintCol] ?? null;
    if (!hintContent) {
      return reply.status(404).send({ error: "Hint content not available", code: "NOT_FOUND" });
    }

    // Upsert progress row, tracking the maximum hint number seen
    // hints_used = max hint number viewed (idempotent if user revisits same hint)
    const { data: existing, error: progFetchErr } = await supabase
      .from("exercise_progress")
      .select("hints_used, status, attempts")
      .eq("device_id", deviceId)
      .eq("exercise_id", id)
      .maybeSingle();

    if (progFetchErr) {
      request.log.error({ err: progFetchErr }, "exercises/:id/hint: progress fetch error");
      return reply.status(500).send({ error: "Failed to fetch progress", code: "INTERNAL_ERROR" });
    }

    const prevHintsUsed = existing?.hints_used ?? 0;
    const newHintsUsed  = Math.max(prevHintsUsed, hint_number);
    const now           = new Date().toISOString();

    const upsertPayload = {
      device_id:   deviceId,
      exercise_id: id,
      hints_used:  newHintsUsed,
      status:      existing?.status ?? "in_progress",
      attempts:    existing?.attempts ?? 0,
      updated_at:  now,
    };
    if (!existing) {
      upsertPayload.started_at = now;
    }

    const { error: upsertErr } = await supabase
      .from("exercise_progress")
      .upsert(upsertPayload, { onConflict: "device_id,exercise_id" });

    if (upsertErr) {
      request.log.error({ err: upsertErr }, "exercises/:id/hint: upsert error");
      return reply.status(500).send({ error: "Failed to record hint view", code: "INTERNAL_ERROR" });
    }

    return reply.send({ hint: hintContent, hints_used: newHintsUsed });
  });

  // ── POST /exercises/:id/submit ─────────────────────────────────────────────
  /**
   * Records a submission attempt and validates output.
   * Body: { code: string }
   * Response: { correct: boolean, expected_output, points_earned, message }
   */
  fastify.post("/:id/submit", {
    config: {
      rateLimit: { max: 10, timeWindow: 60_000, keyGenerator: (req) => req.deviceId ?? req.ip },
    },
  }, async (request, reply) => {
    const { deviceId } = request;
    const { id }       = request.params;
    const lang         = normalizeLang(request.query?.lang ?? request.body?.lang);

    if (!UUID_RE.test(id)) {
      return reply.status(400).send({ error: "Invalid exercise ID format", code: "INVALID_FIELD" });
    }

    const { code } = request.body ?? {};

    // M-01: Cap code length to prevent memory abuse
    if (typeof code === "string" && code.length > 10_000) {
      return reply.status(400).send({ error: "code must be 10,000 characters or fewer", code: "INVALID_FIELD" });
    }

    if (!code && code !== "") {
      return reply.status(400).send({ error: "code is required", code: "MISSING_FIELD" });
    }
    if (typeof code !== "string") {
      return reply.status(400).send({ error: "code must be a string", code: "INVALID_FIELD" });
    }

    // Fetch exercise for expected_output, difficulty, and points
    const { data: exercise, error: exErr } = await supabase
      .from("exercises")
      .select("id, expected_output, difficulty, points, hints_used_penalty")
      .eq("id", id)
      .maybeSingle();

    if (exErr) {
      request.log.error({ err: exErr }, "exercises/:id/submit: exercise fetch error");
      return reply.status(500).send({ error: "Failed to fetch exercise", code: "INTERNAL_ERROR" });
    }
    if (!exercise) {
      return reply.status(404).send({ error: "Exercise not found", code: "NOT_FOUND" });
    }

    // Fetch current progress to know hints_used and if already completed
    const { data: existing, error: progErr } = await supabase
      .from("exercise_progress")
      .select("status, hints_used, attempts")
      .eq("device_id", deviceId)
      .eq("exercise_id", id)
      .maybeSingle();

    if (progErr) {
      request.log.error({ err: progErr }, "exercises/:id/submit: progress fetch error");
      return reply.status(500).send({ error: "Failed to fetch progress", code: "INTERNAL_ERROR" });
    }

    const alreadyCompleted = existing?.status === "completed";
    const hintsUsed        = existing?.hints_used ?? 0;
    const prevAttempts     = existing?.attempts   ?? 0;

    // Simple string-match validation: trim both sides for whitespace tolerance
    const expected = (exercise.expected_output ?? "").trim();
    const submitted = code.trim();
    const correct   = submitted === expected;

    // Points calculation: base points from difficulty, penalty per hint used
    const basePoints   = exercise.points ?? POINTS_BY_DIFFICULTY[exercise.difficulty ?? 1] ?? 10;
    const hintPenalty  = exercise.hints_used_penalty ?? 5; // points deducted per hint
    const pointsEarned = correct && !alreadyCompleted
      ? Math.max(0, basePoints - hintsUsed * hintPenalty)
      : 0;

    const now = new Date().toISOString();

    // Upsert progress: increment attempts, set completed + points if correct
    const upsertPayload = {
      device_id:    deviceId,
      exercise_id:  id,
      hints_used:   hintsUsed,
      attempts:     prevAttempts + 1,
      status:       correct ? "completed" : (existing?.status ?? "in_progress"),
      updated_at:   now,
    };

    if (correct && !alreadyCompleted) {
      upsertPayload.completed_at  = now;
      upsertPayload.points_earned = pointsEarned;
    }
    if (!existing) {
      upsertPayload.started_at = now;
    }

    const { error: upsertErr } = await supabase
      .from("exercise_progress")
      .upsert(upsertPayload, { onConflict: "device_id,exercise_id" });

    if (upsertErr) {
      request.log.error({ err: upsertErr }, "exercises/:id/submit: upsert error");
      return reply.status(500).send({ error: "Failed to record submission", code: "INTERNAL_ERROR" });
    }

    // Localised response message
    let message;
    if (correct && alreadyCompleted) {
      message = lang === "es"
        ? "Ya completaste este ejercicio."
        : "You already completed this exercise.";
    } else if (correct) {
      message = lang === "es"
        ? `Correcto! Ganaste ${pointsEarned} puntos.`
        : `Correct! You earned ${pointsEarned} points.`;
    } else {
      message = lang === "es"
        ? "Incorrecto. Revisa tu respuesta e intenta de nuevo."
        : "Incorrect. Check your answer and try again.";
    }

    // H-01: Only reveal expected_output after correct completion (not on wrong answers)
    return reply.send({
      correct,
      ...(correct ? { expected_output: exercise.expected_output ?? null } : {}),
      points_earned:   pointsEarned,
      message,
    });
  });
}
