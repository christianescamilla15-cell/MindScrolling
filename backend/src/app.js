import "dotenv/config";
import path from "path";
import { fileURLToPath } from "url";
import Fastify from "fastify";
import fastifyStatic from "@fastify/static";
import cors from "@fastify/cors";
import rateLimit from "@fastify/rate-limit";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

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
import deviceIdPlugin   from "./plugins/deviceId.js";

const app = Fastify({ logger: true });

/* ─── Plugins ──────────────────────────────────────────────────────────────── */
await app.register(cors, {
  origin: process.env.ALLOWED_ORIGIN || "http://localhost:5173",
});

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

/* ─── Health ───────────────────────────────────────────────────────────────── */
app.get("/health", async () => ({ status: "ok", ts: new Date().toISOString() }));

/* ─── Start ────────────────────────────────────────────────────────────────── */
try {
  await app.listen({ port: Number(process.env.PORT) || 3000, host: "0.0.0.0" });
} catch (err) {
  app.log.error(err);
  process.exit(1);
}
