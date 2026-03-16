import { supabase } from "../db/client.js";

export default async function vaultRoutes(fastify) {
  /** GET /vault — list saved quotes */
  fastify.get("/", async (request, reply) => {
    const { data, error } = await supabase
      .from("vault")
      .select("saved_at, quotes(*)")
      .eq("device_id", request.deviceId)
      .order("saved_at", { ascending: false });

    if (error) return reply.status(500).send({ error: "Failed to load vault", code: "DB_ERROR" });

    return reply.send({ data: (data || []).map(r => ({ ...r.quotes, saved_at: r.saved_at })) });
  });

  /** POST /vault — save a quote */
  fastify.post("/", async (request, reply) => {
    const { quote_id } = request.body ?? {};
    if (!quote_id) return reply.status(400).send({ error: "quote_id is required", code: "MISSING_FIELD" });

    const { error } = await supabase
      .from("vault")
      .upsert({ device_id: request.deviceId, quote_id }, { onConflict: "device_id,quote_id" });

    if (error) return reply.status(500).send({ error: "Failed to save quote", code: "DB_ERROR" });
    return reply.status(201).send({ saved: true, quote_id });
  });

  /** DELETE /vault/:quote_id — remove a quote */
  fastify.delete("/:quote_id", async (request, reply) => {
    const { quote_id } = request.params;

    const { error, count } = await supabase
      .from("vault")
      .delete({ count: "exact" })
      .eq("device_id", request.deviceId)
      .eq("quote_id", quote_id);

    if (error) return reply.status(500).send({ error: "Failed to remove quote", code: "DB_ERROR" });
    if (count === 0) return reply.status(404).send({ error: "Quote not in vault", code: "NOT_FOUND" });
    return reply.send({ removed: true, quote_id });
  });
}
