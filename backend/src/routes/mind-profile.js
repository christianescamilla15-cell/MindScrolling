import { supabase } from "../db/client.js";

// ─── Insight templates (not AI-generated — zero API cost) ────────────────────

const INSIGHTS = {
  en: {
    stoicism:    "Your mind gravitates toward Stoic resilience today.",
    philosophy:  "You're drawn to deep philosophical questions today.",
    discipline:  "Today you're focused on growth and discipline.",
    reflection:  "A reflective day — you're looking inward.",
  },
  es: {
    stoicism:    "Tu mente gravita hacia la resiliencia estoica hoy.",
    philosophy:  "Hoy te atraen las preguntas filosóficas profundas.",
    discipline:  "Hoy estás enfocado en crecimiento y disciplina.",
    reflection:  "Un día reflexivo — estás mirando hacia adentro.",
  },
};

const MENTAL_STATES = {
  en: {
    "stoicism+philosophy":    "Resilient Thinker",
    "stoicism+discipline":    "Stoic Warrior",
    "stoicism+reflection":    "Calm Sage",
    "philosophy+stoicism":    "Wise Philosopher",
    "philosophy+discipline":  "Strategic Mind",
    "philosophy+reflection":  "Deep Explorer",
    "discipline+stoicism":    "Iron Will",
    "discipline+philosophy":  "Growth Seeker",
    "discipline+reflection":  "Mindful Achiever",
    "reflection+stoicism":    "Inner Fortress",
    "reflection+philosophy":  "Contemplative Soul",
    "reflection+discipline":  "Balanced Spirit",
    _default:                 "Curious Mind",
  },
  es: {
    "stoicism+philosophy":    "Pensador resiliente",
    "stoicism+discipline":    "Guerrero estoico",
    "stoicism+reflection":    "Sabio sereno",
    "philosophy+stoicism":    "Filósofo sabio",
    "philosophy+discipline":  "Mente estratégica",
    "philosophy+reflection":  "Explorador profundo",
    "discipline+stoicism":    "Voluntad de hierro",
    "discipline+philosophy":  "Buscador de crecimiento",
    "discipline+reflection":  "Realizador consciente",
    "reflection+stoicism":    "Fortaleza interior",
    "reflection+philosophy":  "Alma contemplativa",
    "reflection+discipline":  "Espíritu equilibrado",
    _default:                 "Mente curiosa",
  },
};

const CATEGORIES = ["stoicism", "philosophy", "discipline", "reflection"];

// Safe query helper
async function safeQuery(fn) {
  try { return await fn(); }
  catch { return { data: null, error: "table_not_found" }; }
}

export default async function mindProfileRoutes(fastify) {
  /**
   * GET /mind-profile/daily?lang=en|es
   * Returns today's philosophical mind profile for the device.
   */
  fastify.get("/daily", async (request, reply) => {
    const { deviceId } = request;
    const lang = request.query.lang || "en";
    const today = new Date().toISOString().slice(0, 10);

    // ── Parallel fetch ───────────────────────────────────────────────────
    const [prefsResult, likesResult, seenResult, userResult] = await Promise.all([
      safeQuery(() =>
        supabase
          .from("user_preferences")
          .select("category, like_count, vault_count, swipe_count")
          .eq("device_id", deviceId)
      ),
      safeQuery(() =>
        supabase
          .from("likes")
          .select("quote_id, quotes(category)")
          .eq("device_id", deviceId)
          .gte("liked_at", today + "T00:00:00Z")
      ),
      safeQuery(() =>
        supabase
          .from("seen_quotes")
          .select("quote_id, quotes(category)")
          .eq("device_id", deviceId)
          .gte("seen_at", today + "T00:00:00Z")
      ),
      safeQuery(() =>
        supabase
          .from("users")
          .select("streak, total_reflections")
          .eq("device_id", deviceId)
          .maybeSingle()
      ),
    ]);

    const prefs = prefsResult.data || [];
    const todayLikes = likesResult.data || [];
    const todaySeen = seenResult.data || [];
    const user = userResult.data || null;

    // ── Calculate distribution ───────────────────────────────────────────
    const catScores = {};
    CATEGORIES.forEach(c => { catScores[c] = 0; });

    // Weight: likes × 3, vault × 5, swipes × 1
    prefs.forEach(p => {
      catScores[p.category] =
        (p.like_count ?? 0) * 3 +
        (p.vault_count ?? 0) * 5 +
        (p.swipe_count ?? 0);
    });

    // Boost from today's activity
    todayLikes.forEach(l => {
      const cat = l.quotes?.category;
      if (cat) catScores[cat] = (catScores[cat] ?? 0) + 3;
    });
    todaySeen.forEach(s => {
      const cat = s.quotes?.category;
      if (cat) catScores[cat] = (catScores[cat] ?? 0) + 1;
    });

    const total = CATEGORIES.reduce((s, c) => s + catScores[c], 0) || 1;

    const distribution = {};
    CATEGORIES.forEach(c => {
      distribution[c] = Math.round((catScores[c] / total) * 100);
    });

    // Ensure percentages sum to 100
    const distSum = Object.values(distribution).reduce((s, v) => s + v, 0);
    if (distSum !== 100 && distSum > 0) {
      const sorted = [...CATEGORIES].sort((a, b) => catScores[b] - catScores[a]);
      distribution[sorted[0]] += (100 - distSum);
    }

    // Dominant and secondary
    const ranked = [...CATEGORIES].sort((a, b) => catScores[b] - catScores[a]);
    const dominant = ranked[0];
    const secondary = ranked[1];

    const totalInteractions = todayLikes.length + todaySeen.length;

    // Localized insight and mental state
    const langKey = lang === "es" ? "es" : "en";
    const insight = INSIGHTS[langKey][dominant] || INSIGHTS.en[dominant];
    const stateKey = `${dominant}+${secondary}`;
    const mentalState = MENTAL_STATES[langKey][stateKey] || MENTAL_STATES[langKey]._default;

    return reply.send({
      date: today,
      distribution,
      dominant,
      secondary,
      total_interactions: totalInteractions,
      insight,
      mental_state: mentalState,
      streak: user?.streak ?? 0,
      total_reflections: user?.total_reflections ?? 0,
    });
  });
}
