import { supabase } from "../db/client.js";

export default async function likesRoutes(fastify) {
  /** POST /quotes/:id/like  body: { action: "like" | "unlike" } */
  fastify.post("/:id/like", async (request, reply) => {
    const { id }     = request.params;
    const { action } = request.body ?? {};
    const deviceId   = request.deviceId;

    if (!["like", "unlike"].includes(action)) {
      return reply.status(400).send({ error: 'action must be "like" or "unlike"', code: "INVALID_ACTION" });
    }

    // Fetch the quote's category to update user_preferences
    const { data: quote, error: qErr } = await supabase
      .from("quotes").select("category").eq("id", id).single();

    if (qErr || !quote) return reply.status(404).send({ error: "Quote not found", code: "NOT_FOUND" });

    if (action === "like") {
      await supabase.from("likes").upsert({ device_id: deviceId, quote_id: id }, { onConflict: "device_id,quote_id" });
      // Increment like_count in user_preferences
      await supabase.rpc("increment_like", { p_device_id: deviceId, p_category: quote.category });
    } else {
      await supabase.from("likes").delete().eq("device_id", deviceId).eq("quote_id", id);
      await supabase.rpc("decrement_like", { p_device_id: deviceId, p_category: quote.category });
    }

    return reply.send({ liked: action === "like", quote_id: id });
  });
}
