import { supabase }                from "../db/client.js";
import { updatePreferenceVector } from "../services/embeddings.js";

export default async function likesRoutes(fastify) {
  /** POST /quotes/:id/like  body: { action: "like" | "unlike" } */
  fastify.post("/:id/like", async (request, reply) => {
    const { id }   = request.params;
    const { action } = request.body ?? {};
    const { deviceId } = request;

    if (!["like", "unlike"].includes(action)) {
      return reply.status(400).send({ error: 'action must be "like" or "unlike"', code: "INVALID_ACTION" });
    }

    const { data: quote, error: qErr } = await supabase
      .from("quotes")
      .select("category")
      .eq("id", id)
      .single();

    if (qErr || !quote) {
      return reply.status(404).send({ error: "Quote not found", code: "NOT_FOUND" });
    }

    if (action === "like") {
      await supabase
        .from("likes")
        .upsert({ device_id: deviceId, quote_id: id }, { onConflict: "device_id,quote_id" });
      await supabase.rpc("increment_like", { p_device_id: deviceId, p_category: quote.category });

      // Fire-and-forget: update semantic preference vector (strong signal α=0.20)
      updatePreferenceVector(deviceId, id, "like").catch(() => {});
    } else {
      await supabase.from("likes").delete().eq("device_id", deviceId).eq("quote_id", id);
      await supabase.rpc("decrement_like", { p_device_id: deviceId, p_category: quote.category });
      // Note: no vector decrement — EMA naturally decays old signals
    }

    return reply.send({ ok: true });
  });
}
