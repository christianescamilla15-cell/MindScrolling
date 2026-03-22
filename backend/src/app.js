import "dotenv/config";
import path from "path";
import { fileURLToPath } from "url";
import * as Sentry from "@sentry/node";
import Fastify from "fastify";
import fastifyStatic from "@fastify/static";
import helmet from "@fastify/helmet";
import cors from "@fastify/cors";
import rateLimit from "@fastify/rate-limit";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

// ─── Sentry (error tracking) ──────────────────────────────────────────────────
// Initialise before any routes so all errors are captured automatically.
// Set SENTRY_DSN in .env (get it at sentry.io → Project → Client Keys).
if (process.env.SENTRY_DSN) {
  Sentry.init({
    dsn:              process.env.SENTRY_DSN,
    environment:      process.env.NODE_ENV ?? "development",
    tracesSampleRate: process.env.NODE_ENV === "production" ? 0.1 : 0,
    release:          process.env.npm_package_version,
  });
}

import quotesRoutes     from "./routes/quotes.js";
import vaultRoutes      from "./routes/vault.js";
import likesRoutes      from "./routes/likes.js";
import statsRoutes      from "./routes/stats.js";
import profileRoutes    from "./routes/profile.js";
import swipesRoutes     from "./routes/swipes.js";
import challengesRoutes from "./routes/challenges.js";
import mapRoutes        from "./routes/map.js";
import premiumRoutes    from "./routes/premium.js";
import insightsRoutes    from "./routes/insights.js";
import mindProfileRoutes from "./routes/mind-profile.js";
import adminRoutes       from "./routes/admin.js";
import authorsRoutes     from "./routes/authors.js";
import packsRoutes       from "./routes/packs.js";
import webhooksRoutes    from "./routes/webhooks.js";
import analyticsRoutes   from "./routes/analytics.js";
import deviceLockRoutes  from "./routes/device-lock.js";
import insightMatchRoutes from "./routes/insight.js";
import exercisesRoutes   from "./routes/exercises.js";
import deviceIdPlugin   from "./plugins/deviceId.js";

const app = Fastify({
  logger: {
    level: process.env.LOG_LEVEL ?? "info",
    redact: {
      paths: [
        "req.headers.authorization",
        "req.headers[\"x-device-id\"]",
        "req.headers.cookie",
      ],
      censor: "[REDACTED]",
    },
  },
});

/* ─── Plugins ──────────────────────────────────────────────────────────────── */
await app.register(helmet, {
  // Content-Security-Policy: tighten for API-only server (no HTML served)
  contentSecurityPolicy: false,
  crossOriginEmbedderPolicy: false,
});

const corsOrigin = process.env.ALLOWED_ORIGIN || "http://localhost:5173";
if (process.env.NODE_ENV === "production" && corsOrigin === "http://localhost:5173") {
  app.log.warn("ALLOWED_ORIGIN not set in production — CORS will reject browser requests");
}
await app.register(cors, { origin: corsOrigin });

await app.register(rateLimit, {
  max:        Number(process.env.RATE_LIMIT_MAX)        || 60,
  timeWindow: Number(process.env.RATE_LIMIT_WINDOW_MS)  || 60_000,
});

await app.register(deviceIdPlugin);

// Serve static audio files from /public/audio/
await app.register(fastifyStatic, {
  root: path.join(__dirname, "..", "public"),
  prefix: "/static/",
  decorateReply: false,
});

/* ─── Routes ───────────────────────────────────────────────────────────────── */
await app.register(quotesRoutes,     { prefix: "/quotes"     });
await app.register(vaultRoutes,      { prefix: "/vault"      });
await app.register(likesRoutes,      { prefix: "/quotes"     });
await app.register(statsRoutes,      { prefix: "/stats"      });
await app.register(profileRoutes,    { prefix: "/profile"    });
await app.register(swipesRoutes,     { prefix: "/swipes"     });
await app.register(challengesRoutes, { prefix: "/challenges" });
await app.register(mapRoutes,        { prefix: "/map"        });
await app.register(premiumRoutes,    { prefix: "/premium"    });
await app.register(insightsRoutes,    { prefix: "/insights"    });
await app.register(mindProfileRoutes, { prefix: "/mind-profile" });
await app.register(adminRoutes,       { prefix: "/admin" });
await app.register(authorsRoutes,     { prefix: "/authors" });
await app.register(packsRoutes,       { prefix: "/packs" });
await app.register(webhooksRoutes,    { prefix: "/webhooks" });
await app.register(analyticsRoutes,   { prefix: "/analytics" });
await app.register(deviceLockRoutes,  { prefix: "/device-lock" });
await app.register(insightMatchRoutes, { prefix: "/insight" });
await app.register(exercisesRoutes,    { prefix: "/exercises" });

/* ─── Health ───────────────────────────────────────────────────────────────── */
app.get("/health", async () => ({ status: "ok", ts: new Date().toISOString() }));

/* ─── Sentry error handler (after routes) ─────────────────────────────────── */
app.setErrorHandler((error, request, reply) => {
  if (process.env.SENTRY_DSN) {
    Sentry.captureException(error, { extra: { url: request.url, method: request.method } });
  }
  app.log.error(error);
  reply.status(error.statusCode ?? 500).send({
    error: error.message ?? "Internal server error",
    code:  error.code    ?? "INTERNAL_ERROR",
  });
});

/* ─── Start ────────────────────────────────────────────────────────────────── */
try {
  await app.listen({ port: Number(process.env.PORT) || 3000, host: "0.0.0.0" });
} catch (err) {
  if (process.env.SENTRY_DSN) Sentry.captureException(err);
  app.log.error(err);
  process.exit(1);
}
