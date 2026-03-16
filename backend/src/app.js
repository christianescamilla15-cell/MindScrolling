import "dotenv/config";
import Fastify from "fastify";
import cors from "@fastify/cors";
import rateLimit from "@fastify/rate-limit";

import quotesRoutes     from "./routes/quotes.js";
import vaultRoutes      from "./routes/vault.js";
import likesRoutes      from "./routes/likes.js";
import statsRoutes      from "./routes/stats.js";
import profileRoutes    from "./routes/profile.js";
import swipesRoutes     from "./routes/swipes.js";
import challengesRoutes from "./routes/challenges.js";
import mapRoutes        from "./routes/map.js";
import premiumRoutes    from "./routes/premium.js";
import deviceIdPlugin   from "./plugins/deviceId.js";

const app = Fastify({ logger: true });

/* ─── Plugins ─────────────────────────────────────────────────────────────────── */
await app.register(cors, {
  origin: process.env.ALLOWED_ORIGIN || "http://localhost:5173",
});

await app.register(rateLimit, {
  max: 60,
  timeWindow: "1 minute",
});

await app.register(deviceIdPlugin);

/* ─── Routes ──────────────────────────────────────────────────────────────────── */
await app.register(quotesRoutes,     { prefix: "/quotes"     });
await app.register(vaultRoutes,      { prefix: "/vault"      });
await app.register(likesRoutes,      { prefix: "/quotes"     });
await app.register(statsRoutes,      { prefix: "/stats"      });
await app.register(profileRoutes,    { prefix: "/profile"    });
await app.register(swipesRoutes,     { prefix: "/swipes"     });
await app.register(challengesRoutes, { prefix: "/challenges" });
await app.register(mapRoutes,        { prefix: "/map"        });
await app.register(premiumRoutes,    { prefix: "/premium"    });

/* ─── Health check ────────────────────────────────────────────────────────────── */
app.get("/health", async () => ({ status: "ok", ts: new Date().toISOString() }));

/* ─── Start ───────────────────────────────────────────────────────────────────── */
try {
  await app.listen({ port: Number(process.env.PORT) || 3000, host: "0.0.0.0" });
} catch (err) {
  app.log.error(err);
  process.exit(1);
}
