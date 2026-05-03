/**
 * users.js — User discovery (search, lookup)
 *
 * Endpoints:
 *   GET /users/search?q=<query>&limit=<n>  — search users by display_name (ILIKE)
 *   GET /users/:device_id                  — lookup a single user (public profile shape)
 *
 * Auth: device-id required (deviceIdPlugin global). Self is excluded from
 * search results so users don't see themselves in their own follow list.
 *
 * Privacy:
 * - Only users with a non-empty display_name are searchable.
 * - Users that haven't set a display_name are invisible to /search by design.
 * - The lookup endpoint returns 404 for both "no such user" and "exists but
 *   has no display_name" — same shape, no enumeration leak.
 */

import { supabase } from "../db/client.js";

const MIN_QUERY_LENGTH = 2;
const MAX_LIMIT        = 25;
const DEFAULT_LIMIT    = 10;

export default async function usersRoutes(fastify) {

  // ── GET /users/search ─────────────────────────────────────────────────────
  // Query: q=<string> (min 2 chars), limit=<int> (1..25, default 10)
  // Returns: [{ device_id, display_name, streak, longest_streak, is_premium }]
  fastify.get("/search", async (request, reply) => {
    const deviceId = request.deviceId;
    const q = (request.query?.q || "").trim();
    const rawLimit = Number(request.query?.limit) || DEFAULT_LIMIT;
    const limit = Math.max(1, Math.min(MAX_LIMIT, rawLimit));

    if (q.length < MIN_QUERY_LENGTH) {
      return reply.status(400).send({
        error: `Query must be at least ${MIN_QUERY_LENGTH} characters`,
        code: "QUERY_TOO_SHORT",
      });
    }

    // Escape ILIKE wildcards in the user input so a `%` typed by the user
    // doesn't accidentally match every row.
    const escaped = q.replace(/[\\%_]/g, (c) => "\\" + c);

    const { data, error } = await supabase
      .from("users")
      .select("device_id, display_name, streak, longest_streak, is_premium")
      .ilike("display_name", `%${escaped}%`)
      .neq("device_id", deviceId)
      .not("display_name", "is", null)
      .limit(limit);

    if (error) {
      request.log.error({ err: error }, "users_search_failed");
      return reply.status(500).send({ error: "Search failed", code: "DB_ERROR" });
    }

    // Filter out empty display_names that ILIKE can match via '%%' edge cases.
    const results = (data || []).filter((u) => (u.display_name || "").trim().length > 0);
    return reply.send({ results });
  });

  // ── GET /users/:device_id ─────────────────────────────────────────────────
  // Public-shape lookup — returns 404 if user doesn't exist OR has no
  // display_name (so users who haven't opted in to discovery aren't enumerable).
  fastify.get("/:device_id", async (request, reply) => {
    const targetId = request.params.device_id;

    if (!targetId || targetId.length > 100) {
      return reply.status(400).send({ error: "Invalid device_id", code: "BAD_DEVICE_ID" });
    }

    const { data, error } = await supabase
      .from("users")
      .select("device_id, display_name, streak, longest_streak, is_premium, created_at")
      .eq("device_id", targetId)
      .maybeSingle();

    if (error) {
      request.log.error({ err: error }, "users_lookup_failed");
      return reply.status(500).send({ error: "Lookup failed", code: "DB_ERROR" });
    }

    if (!data || !data.display_name || data.display_name.trim().length === 0) {
      return reply.status(404).send({ error: "User not found", code: "NOT_FOUND" });
    }

    return reply.send({ user: data });
  });
}
