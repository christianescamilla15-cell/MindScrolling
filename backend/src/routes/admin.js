import { supabase } from "../db/client.js";
import crypto from "crypto";

const ADMIN_SECRET = process.env.ADMIN_SECRET;
if (!ADMIN_SECRET && process.env.NODE_ENV === "production") {
  throw new Error("ADMIN_SECRET must be set in production");
}

/**
 * Validates the X-Admin-Secret header.
 */
function requireAdmin(request, reply) {
  if (!ADMIN_SECRET) {
    reply.status(503).send({ error: "Admin not configured", code: "ADMIN_NOT_CONFIGURED" });
    return false;
  }
  const secret = request.headers["x-admin-secret"];
  if (!secret || secret !== ADMIN_SECRET) {
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

    for (let i = 0; i < codeCount; i++) {
      const code = generateCode();
      const { data, error } = await supabase
        .from("premium_activation_codes")
        .insert({
          code,
          type: "lifetime",
          created_by: "admin",
          assigned_email,
          notes,
          expires_at,
        })
        .select("id, code, created_at")
        .single();

      if (error) {
        request.log.error({ err: error }, "admin/codes/create: insert failed");
        continue;
      }
      codes.push(data);
    }

    // Audit
    await supabase.from("premium_audit_log").insert({
      device_id: null,
      event_type: "codes_created",
      source: "admin",
      metadata: {
        count: codes.length,
        assigned_email,
        notes,
        codes: codes.map((c) => c.code),
      },
    });

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

    await supabase
      .from("premium_activation_codes")
      .update({ revoked: true })
      .eq("id", codeRow.id);

    // Audit
    await supabase.from("premium_audit_log").insert({
      device_id: null,
      event_type: "code_revoked",
      source: "admin",
      metadata: { code: cleanCode, code_id: codeRow.id },
    });

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

    let query = supabase
      .from("premium_activation_codes")
      .select("*")
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
      return reply.status(500).send({ error: "Failed to list codes", code: "DB_ERROR" });
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
      return reply.status(500).send({ error: "Failed to list audit log", code: "DB_ERROR" });
    }

    return reply.send({ count: data.length, events: data });
  });
}
