import fp from "fastify-plugin";

/**
 * Reads X-Device-ID header and attaches it to the request.
 * Returns 400 if the header is missing.
 */
async function deviceIdPlugin(fastify) {
  fastify.addHook("preHandler", async (request, reply) => {
    // Health check doesn't need device ID
    if (request.url === "/health") return;

    const deviceId = request.headers["x-device-id"];
    if (!deviceId || deviceId.trim() === "") {
      return reply.status(400).send({ error: "Missing X-Device-ID header", code: "MISSING_DEVICE_ID" });
    }
    request.deviceId = deviceId.trim();
  });
}

export default fp(deviceIdPlugin);
