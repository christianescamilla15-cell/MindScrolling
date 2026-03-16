import { supabase }                from "../db/client.js";
import { updatePreferenceVector } from "../services/embeddings.js";

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
    const { deviceId } = request;
    const { quote_id } = request.body ?? {};
    if (!quote_id) return reply.status(400).send({ error: "quote_id is required", code: "MISSING_FIELD" });

    // Check for duplicate
    const { data: existing } = await supabase
      .from("vault")
      .select("quote_id")
      .eq("device_id", deviceId)
      .eq("quote_id", quote_id)
      .maybeSingle();

    if (existing) return reply.send({ ok: true, status: "already_saved" });

    // Fetch category (needed for vault preference signal)
    const { data: quote } = await supabase
      .from("quotes")
      .select("category")
      .eq("id", quote_id)
      .maybeSingle();

    // Parallel: insert vault row + increment vault preference signal
    const ops = [supabase.from("vault").insert({ device_id: deviceId, quote_id })];
    if (quote?.category) {
      ops.push(supabase.rpc("increment_vault", { p_device_id: deviceId, p_category: quote.category }));
    }

    const [{ error }] = await Promise.all(ops);
    if (error) return reply.status(500).send({ error: "Failed to save quote", code: "DB_ERROR" });

    // Fire-and-forget: update semantic preference vector (strongest signal α=0.25)
    updatePreferenceVector(deviceId, quote_id, "vault").catch(() => {});

    return reply.send({ ok: true });
  });

  /** DELETE /vault/:id — remove a quote */
  fastify.delete("/:id", async (request, reply) => {
    const { deviceId }   = request;
    const { id: quote_id } = request.params;

    // Fetch category before deleting (for preference signal decrement)
    const { data: quote } = await supabase
      .from("quotes")
      .select("category")
      .eq("id", quote_id)
      .maybeSingle();

    const { error, count } = await supabase
      .from("vault")
      .delete({ count: "exact" })
      .eq("device_id", deviceId)
      .eq("quote_id", quote_id);

    if (error) return reply.status(500).send({ error: "Failed to remove quote", code: "DB_ERROR" });
    if (count === 0) return reply.status(404).send({ error: "Quote not in vault", code: "NOT_FOUND" });

    // Fire-and-forget decrement
    if (quote?.category) {
      supabase.rpc("decrement_vault", { p_device_id: deviceId, p_category: quote.category }).catch(() => {});
    }

    return reply.send({ ok: true });
  });
}
