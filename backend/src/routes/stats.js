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

    return reply.send({
      streak:            user.streak,
      total_reflections: user.total_reflections,
      category_counts,
    });
  });
}
