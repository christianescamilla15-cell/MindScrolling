import { supabase } from "../db/client.js";
import crypto from "crypto";

const ADMIN_SECRET = process.env.ADMIN_SECRET;
if (!ADMIN_SECRET && process.env.NODE_ENV === "production") {
  throw new Error("ADMIN_SECRET must be set in production");
}

/**
 * Validates the X-Admin-Secret header using a timing-safe comparison
 * to prevent timing-attack-based secret enumeration.
 */
function requireAdmin(request, reply) {
  if (!ADMIN_SECRET) {
    reply.status(503).send({ error: "Admin not configured", code: "ADMIN_NOT_CONFIGURED" });
    return false;
  }
  const secret = request.headers["x-admin-secret"] ?? "";
  const providedBuf = Buffer.from(secret);
  const expectedBuf = Buffer.from(ADMIN_SECRET);
  // Lengths must match before timingSafeEqual (different lengths = wrong, not a timing oracle)
  if (providedBuf.length !== expectedBuf.length || !crypto.timingSafeEqual(providedBuf, expectedBuf)) {
    reply.status(403).send({ error: "Forbidden", code: "INVALID_ADMIN_SECRET" });
    return false;
  }
  return true;
}

/**
 * Generates a code in format MIND-XXXX-XXXX (uppercase alphanumeric).
 */
function generateCode() {
  const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"; // no 0/O/1/I to avoid confusion
  let block1 = "", block2 = "";
  for (let i = 0; i < 4; i++) {
    block1 += chars[crypto.randomInt(chars.length)];
    block2 += chars[crypto.randomInt(chars.length)];
  }
  return `MIND-${block1}-${block2}`;
}

export default async function adminRoutes(fastify) {
  // Stricter rate limit for admin routes (10 req/min vs 60 global)
  fastify.addHook("preHandler", async (request, reply) => {
    // Defence-in-depth: enforce admin secret on every admin route via shared hook.
    // Individual handlers also call requireAdmin(), but this ensures protection even
    // if a future handler forgets to do so.
    if (!requireAdmin(request, reply)) return;

    // Simple in-memory rate limit for admin
    const ip = request.ip;
    const now = Date.now();
    if (!adminRoutes._rateMap) adminRoutes._rateMap = new Map();
    // Evict expired entries to prevent unbounded memory growth
    if (adminRoutes._rateMap.size > 500) {
      for (const [k, v] of adminRoutes._rateMap) {
        if (now > v.resetAt) adminRoutes._rateMap.delete(k);
      }
    }
    const entry = adminRoutes._rateMap.get(ip) || { count: 0, resetAt: now + 60000 };
    if (now > entry.resetAt) {
      entry.count = 0;
      entry.resetAt = now + 60000;
    }
    entry.count++;
    adminRoutes._rateMap.set(ip, entry);
    if (entry.count > 10) {
      return reply.status(429).send({ error: "Too many admin requests", code: "RATE_LIMITED" });
    }
  });
  /**
   * POST /admin/codes/create
   * Headers: X-Admin-Secret
   * Body: { count?, assigned_email?, notes?, expires_at? }
   * Returns: array of generated codes
   */
  fastify.post("/codes/create", async (request, reply) => {
    if (!requireAdmin(request, reply)) return;

    const {
      count = 1,
      assigned_email = null,
      notes = null,
      expires_at = null,
    } = request.body ?? {};

    const codeCount = Math.min(Math.max(1, Number(count) || 1), 50); // max 50 at once
    const codes = [];

    const inserts = Array.from({ length: codeCount }, () => ({
      code: generateCode(),
      type: "lifetime",
      created_by: "admin",
      assigned_email,
      notes,
      expires_at,
    }));

    const { data: insertedCodes, error: bulkErr } = await supabase
      .from("premium_activation_codes")
      .insert(inserts)
      .select("id, code, created_at");

    if (bulkErr) {
      request.log.error({ err: bulkErr }, "admin/codes/create: bulk insert failed");
      return reply.status(500).send({ error: "Failed to create codes", code: "INTERNAL_ERROR" });
    }
    codes.push(...(insertedCodes ?? []));

    // Audit — fire-and-forget: audit failure must not fail the action
    supabase.from("premium_audit_log").insert({
      device_id: null,
      event_type: "codes_created",
      source: "admin",
      metadata: {
        count: codes.length,
        assigned_email,
        notes,
        codes: codes.map((c) => c.code),
      },
    }).catch(() => {});

    return reply.send({
      created: codes.length,
      codes: codes.map((c) => ({
        id: c.id,
        code: c.code,
        created_at: c.created_at,
        assigned_email,
      })),
    });
  });

  /**
   * POST /admin/codes/revoke
   * Headers: X-Admin-Secret
   * Body: { code }
   */
  fastify.post("/codes/revoke", async (request, reply) => {
    if (!requireAdmin(request, reply)) return;

    const { code } = request.body ?? {};
    if (!code) {
      return reply.status(400).send({ error: "code is required", code: "MISSING_FIELD" });
    }

    const cleanCode = code.trim().toUpperCase();

    const { data: codeRow, error: lookupErr } = await supabase
      .from("premium_activation_codes")
      .select("id, is_redeemed")
      .eq("code", cleanCode)
      .maybeSingle();

    if (lookupErr || !codeRow) {
      return reply.status(404).send({ error: "Code not found", code: "CODE_NOT_FOUND" });
    }

    if (codeRow.is_redeemed) {
      return reply.status(409).send({
        error: "Cannot revoke: code already redeemed",
        code: "CODE_ALREADY_REDEEMED",
      });
    }

    const { error: revokeErr } = await supabase
      .from("premium_activation_codes")
      .update({ revoked: true })
      .eq("id", codeRow.id);

    if (revokeErr) {
      fastify.log.error({ err: revokeErr }, "admin/codes/revoke: DB update failed");
      return reply.status(500).send({ error: "Failed to revoke code", code: "INTERNAL_ERROR" });
    }

    // Audit — fire-and-forget: audit failure must not fail the action
    supabase.from("premium_audit_log").insert({
      device_id: null,
      event_type: "code_revoked",
      source: "admin",
      metadata: { code: cleanCode, code_id: codeRow.id },
    }).catch(() => {});

    return reply.send({ revoked: true, code: cleanCode });
  });

  /**
   * GET /admin/codes/list
   * Headers: X-Admin-Secret
   * Query: ?status=all|active|redeemed|revoked
   */
  fastify.get("/codes/list", async (request, reply) => {
    if (!requireAdmin(request, reply)) return;

    const status = request.query.status || "all";
    const VALID_STATUSES = ["all", "active", "redeemed", "revoked"];
    if (!VALID_STATUSES.includes(status)) {
      return reply.status(400).send({
        error: `Invalid status. Must be one of: ${VALID_STATUSES.join(", ")}`,
        code: "INVALID_PARAM",
      });
    }

    // Exclude redeemed_by (device_id of the user who redeemed) — PII
    let query = supabase
      .from("premium_activation_codes")
      .select("id, code, type, created_by, assigned_email, notes, expires_at, is_redeemed, redeemed_at, revoked, created_at")
      .order("created_at", { ascending: false })
      .limit(100);

    if (status === "active") {
      query = query.eq("is_redeemed", false).eq("revoked", false);
    } else if (status === "redeemed") {
      query = query.eq("is_redeemed", true);
    } else if (status === "revoked") {
      query = query.eq("revoked", true);
    }

    const { data, error } = await query;

    if (error) {
      return reply.status(500).send({ error: "Failed to list codes", code: "INTERNAL_ERROR" });
    }

    return reply.send({
      count: data.length,
      codes: data,
    });
  });

  /**
   * GET /admin/audit
   * Headers: X-Admin-Secret
   * Query: ?limit=50
   */
  fastify.get("/audit", async (request, reply) => {
    if (!requireAdmin(request, reply)) return;

    const limit = Math.min(Number(request.query.limit) || 50, 200);

    const { data, error } = await supabase
      .from("premium_audit_log")
      .select("*")
      .order("created_at", { ascending: false })
      .limit(limit);

    if (error) {
      return reply.status(500).send({ error: "Failed to list audit log", code: "INTERNAL_ERROR" });
    }

    return reply.send({ count: data.length, events: data });
  });
}
