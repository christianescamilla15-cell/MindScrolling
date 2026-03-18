import { supabase }                from "../db/client.js";
import { updatePreferenceVector } from "../services/embeddings.js";
import { UUID_RE }                from "../utils/validation.js";

export default async function vaultRoutes(fastify) {
  /** GET /vault — list saved quotes */
  fastify.get("/", async (request, reply) => {
    const { data, error } = await supabase
      .from("vault")
      .select("saved_at, quotes(*)")
      .eq("device_id", request.deviceId)
      .order("saved_at", { ascending: false });

    if (error) return reply.status(500).send({ error: "Failed to load vault", code: "INTERNAL_ERROR" });

    return reply.send({ data: (data || []).map(r => ({ ...r.quotes, saved_at: r.saved_at })) });
  });

  /** POST /vault — save a quote */
  fastify.post("/", async (request, reply) => {
    const FREE_VAULT_LIMIT = 20;

    const { deviceId } = request;
    const { quote_id } = request.body ?? {};
    if (!quote_id) return reply.status(400).send({ error: "quote_id is required", code: "MISSING_FIELD" });
    if (!UUID_RE.test(quote_id)) return reply.status(400).send({ error: "quote_id must be a valid UUID", code: "INVALID_FIELD" });

    // Check for duplicate first (avoids unnecessary limit check for re-saves)
    const { data: existing } = await supabase
      .from("vault")
      .select("quote_id")
      .eq("device_id", deviceId)
      .eq("quote_id", quote_id)
      .maybeSingle();

    if (existing) return reply.send({ ok: true, status: "already_saved" });

    // Enforce free-user vault limit
    const { data: userRow } = await supabase
      .from("users")
      .select("is_premium")
      .eq("device_id", deviceId)
      .maybeSingle();

    const isPremium = userRow?.is_premium === true;
    if (!isPremium) {
      const { count } = await supabase
        .from("vault")
        .select("quote_id", { count: "exact", head: true })
        .eq("device_id", deviceId);

      if ((count ?? 0) >= FREE_VAULT_LIMIT) {
        return reply.status(403).send({
          error: `Free vault is limited to ${FREE_VAULT_LIMIT} quotes. Upgrade to MindScrolling Inside to save unlimited quotes.`,
          code: "VAULT_LIMIT_REACHED",
          limit: FREE_VAULT_LIMIT,
        });
      }
    }

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

    const [{ error: insertErr }, rpcResult] = await Promise.all(ops);
    if (insertErr) return reply.status(500).send({ error: "Failed to save quote", code: "INTERNAL_ERROR" });
    if (rpcResult?.error) {
      fastify.log.error({ err: rpcResult.error }, "vault/save: increment_vault RPC failed — preference count diverged");
    }

    // Fire-and-forget: update semantic preference vector (strongest signal α=0.25)
    updatePreferenceVector(deviceId, quote_id, "vault").catch(() => {});

    return reply.send({ ok: true });
  });

  /** DELETE /vault/:id — remove a quote */
  fastify.delete("/:id", async (request, reply) => {
    const { deviceId }   = request;
    const { id: quote_id } = request.params;

    if (!UUID_RE.test(quote_id)) {
      return reply.status(400).send({ error: "Invalid quote ID format", code: "INVALID_FIELD" });
    }

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

    if (error) return reply.status(500).send({ error: "Failed to remove quote", code: "INTERNAL_ERROR" });
    if (count === 0) return reply.status(404).send({ error: "Quote not in vault", code: "NOT_FOUND" });

    // Fire-and-forget decrement
    if (quote?.category) {
      supabase.rpc("decrement_vault", { p_device_id: deviceId, p_category: quote.category }).then(() => {}).catch(() => {});
    }

    return reply.send({ ok: true });
  });
}
