import fp from "fastify-plugin";
import { UUID_RE } from "../utils/validation.js";

const EXEMPT_EXACT    = ["/health"];
const EXEMPT_PREFIXES = ["/static/", "/admin/", "/webhooks/"];

/**
 * Reads X-Device-ID header and attaches it to the request.
 * Returns 401 if the header is missing or not a valid UUID.
 */
async function deviceIdPlugin(fastify) {
  fastify.addHook("preHandler", async (request, reply) => {
    // Public routes don't need device ID
    if (EXEMPT_EXACT.includes(request.url) ||
        EXEMPT_PREFIXES.some(p => request.url.startsWith(p))) return;

    const deviceId = request.headers["x-device-id"]?.trim();
    if (!deviceId) {
      return reply.status(401).send({ error: "Missing X-Device-ID header", code: "MISSING_DEVICE_ID" });
    }
    if (!UUID_RE.test(deviceId)) {
      return reply.status(400).send({ error: "X-Device-ID must be a valid UUID", code: "INVALID_DEVICE_ID" });
    }
    request.deviceId = deviceId;
  });
}

export default fp(deviceIdPlugin);
