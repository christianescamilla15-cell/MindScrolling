import { supabase }                from "../db/client.js";
import { updatePreferenceVector } from "../services/embeddings.js";
import { UUID_RE }                from "../utils/validation.js";

export default async function likesRoutes(fastify) {
  /** POST /quotes/:id/like  body: { action: "like" | "unlike" } */
  fastify.post("/:id/like", async (request, reply) => {
    const { id }   = request.params;
    const { action } = request.body ?? {};
    const { deviceId } = request;

    if (!UUID_RE.test(id)) {
      return reply.status(400).send({ error: "Quote ID must be a valid UUID", code: "INVALID_FIELD" });
    }

    if (!["like", "unlike"].includes(action)) {
      return reply.status(400).send({ error: 'action must be "like" or "unlike"', code: "INVALID_ACTION" });
    }

    const { data: quote, error: qErr } = await supabase
      .from("quotes")
      .select("category")
      .eq("id", id)
      .maybeSingle();

    if (qErr) {
      request.log.error({ err: qErr }, "like: failed to fetch quote");
      return reply.status(500).send({ error: "Failed to fetch quote", code: "INTERNAL_ERROR" });
    }
    if (!quote) {
      return reply.status(404).send({ error: "Quote not found", code: "NOT_FOUND" });
    }

    if (action === "like") {
      const [upsertRes, rpcRes] = await Promise.all([
        supabase.from("likes").upsert({ device_id: deviceId, quote_id: id }, { onConflict: "device_id,quote_id" }),
        supabase.rpc("increment_like", { p_device_id: deviceId, p_category: quote.category }),
      ]);

      if (upsertRes.error || rpcRes.error) {
        request.log.error({ upsertErr: upsertRes.error, rpcErr: rpcRes.error }, "like: DB error");
        return reply.status(500).send({ error: "Failed to record like", code: "INTERNAL_ERROR" });
      }

      // Fire-and-forget: update semantic preference vector (strong signal α=0.20)
      updatePreferenceVector(deviceId, id, "like").catch(() => {});
    } else {
      const [deleteRes, rpcRes] = await Promise.all([
        supabase.from("likes").delete().eq("device_id", deviceId).eq("quote_id", id),
        supabase.rpc("decrement_like", { p_device_id: deviceId, p_category: quote.category }),
      ]);

      if (deleteRes.error || rpcRes.error) {
        request.log.error({ deleteErr: deleteRes.error, rpcErr: rpcRes.error }, "unlike: DB error");
        return reply.status(500).send({ error: "Failed to record unlike", code: "INTERNAL_ERROR" });
      }
      // Note: no vector decrement — EMA naturally decays old signals
    }

    return reply.send({ ok: true });
  });
}
