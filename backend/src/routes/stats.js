import { supabase } from "../db/client.js";

export default async function statsRoutes(fastify) {
  /** GET /stats — user streak + reflections + category distribution */
  fastify.get("/", async (request, reply) => {
    const deviceId = request.deviceId;

    const [userRes, prefsRes] = await Promise.all([
      supabase.from("users").select("streak, total_reflections").eq("device_id", deviceId).maybeSingle(),
      supabase.from("user_preferences").select("category, swipe_count").eq("device_id", deviceId),
    ]);

    const user  = userRes.data  ?? { streak: 0, total_reflections: 0 };
    const prefs = prefsRes.data ?? [];

    const category_counts = { stoicism: 0, philosophy: 0, discipline: 0, reflection: 0 };
    prefs.forEach(p => { if (p.category in category_counts) category_counts[p.category] = p.swipe_count; });

    // Count today's actual swipes from swipe_events (not seen_quotes which includes feed-loaded)
    const todayStr = new Date().toISOString().slice(0, 10);
    const { count: todaySwipes } = await supabase
      .from("swipe_events")
      .select("id", { count: "exact", head: true })
      .eq("device_id", deviceId)
      .gte("created_at", todayStr + "T00:00:00Z");

    return reply.send({
      streak:            user.streak,
      total_reflections: user.total_reflections,
      today_swipes:      todaySwipes ?? 0,
      category_counts,
    });
  });
}
