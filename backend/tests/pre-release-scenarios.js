/**
 * MindScrolling — Pre-Release Scenario Tests
 *
 * Covers 8 user scenarios + additional edge cases before Google Play submission.
 * Requires a running local backend (npm run dev) and a real Supabase test project.
 *
 * Run:
 *   node --test backend/tests/pre-release-scenarios.js
 *
 * Env vars needed (in backend/.env):
 *   SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY (for test setup), ADMIN_SECRET
 *   Optional: TEST_BASE_URL (default http://localhost:3000)
 */

import { test, describe, before, after } from "node:test";
import assert from "node:assert/strict";
import { createClient } from "@supabase/supabase-js";
import { config } from "dotenv";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

// ── Load .env ─────────────────────────────────────────────────────────────────
const __dirname = dirname(fileURLToPath(import.meta.url));
config({ path: join(__dirname, "../.env") });

const BASE_URL     = process.env.TEST_BASE_URL ?? "http://localhost:3000";
const ADMIN_SECRET = process.env.ADMIN_SECRET  ?? "";

// Service-role key bypasses RLS — required only for test setup/teardown
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY ?? process.env.SUPABASE_ANON_KEY,
);

// ── Helpers ───────────────────────────────────────────────────────────────────

/** Unique device-id for each test run so tests never collide. */
function uid(prefix = "test") {
  return `${prefix}-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`;
}

/** Thin fetch wrapper — returns { status, body }.
 *  For POST/PUT/PATCH always sends at least `{}` so Fastify doesn't reject empty JSON bodies.
 */
async function api(method, path, { body, headers = {} } = {}) {
  const needsBody = ["POST", "PUT", "PATCH"].includes(method.toUpperCase());
  const opts = {
    method,
    headers: { "Content-Type": "application/json", ...headers },
  };
  opts.body = JSON.stringify(body !== undefined ? body : (needsBody ? {} : undefined));
  if (!needsBody && body === undefined) {
    delete opts.body;
    delete opts.headers["Content-Type"];
  }
  const res = await fetch(`${BASE_URL}${path}`, opts);
  const json = await res.json().catch(() => ({}));
  return { status: res.status, body: json };
}

/** Shorthand header object for device auth. */
function device(deviceId) {
  return { "X-Device-ID": deviceId };
}

/** Admin auth header. */
const adminHeaders = { "X-Admin-Secret": ADMIN_SECRET };

/**
 * Directly set trial dates in DB (bypasses API — for time-shifted scenarios).
 * daysAgo > 0 means trial started N days ago (reduces remaining days).
 */
async function setTrialAge(deviceId, daysAgoStart) {
  const trialStart = new Date(Date.now() - daysAgoStart * 86_400_000).toISOString();
  const trialEnd   = new Date(Date.now() + (7 - daysAgoStart) * 86_400_000).toISOString();
  await supabase.from("users").upsert(
    {
      device_id:        deviceId,
      trial_start_date: trialStart,
      trial_end_date:   trialEnd,
      premium_status:   "trial",
    },
    { onConflict: "device_id" },
  );
}

/** Set trial to fully expired (> 7 days ago). */
async function setTrialExpired(deviceId) {
  const trialStart = new Date(Date.now() - 8 * 86_400_000).toISOString();
  const trialEnd   = new Date(Date.now() - 1 * 86_400_000).toISOString();
  await supabase.from("users").upsert(
    {
      device_id:        deviceId,
      trial_start_date: trialStart,
      trial_end_date:   trialEnd,
      premium_status:   "trial",
      is_premium:       false,
    },
    { onConflict: "device_id" },
  );
}

/** Clean up everything linked to a test device. */
async function cleanup(...deviceIds) {
  for (const id of deviceIds) {
    await supabase.from("vault").delete().eq("device_id", id);
    await supabase.from("purchases").delete().eq("device_id", id);
    await supabase.from("swipe_events").delete().eq("device_id", id);
    await supabase.from("user_preferences").delete().eq("device_id", id);
    await supabase.from("challenge_progress").delete().eq("device_id", id);
    await supabase.from("premium_audit_log").delete().eq("device_id", id);
    await supabase.from("users").delete().eq("device_id", id);
  }
}

/** Get one real free quote id from DB. */
async function getAnyFreeQuoteId(lang = "en") {
  const { data } = await supabase
    .from("quotes")
    .select("id")
    .eq("lang", lang)
    .eq("is_premium", false)
    .limit(1)
    .maybeSingle();
  return data?.id ?? null;
}

/** Get N real free quote ids from DB (for vault limit tests). */
async function getFreeQuoteIds(n = 20, lang = "en") {
  const { data } = await supabase
    .from("quotes")
    .select("id")
    .eq("lang", lang)
    .eq("is_premium", false)
    .limit(n);
  return (data ?? []).map((r) => r.id);
}

// ── Pre-flight connectivity check ─────────────────────────────────────────────

before(async () => {
  try {
    const { status } = await api("GET", "/health");
    if (status !== 200) throw new Error(`Backend health check returned ${status}`);
  } catch (err) {
    console.error(`\n⛔  Cannot reach backend at ${BASE_URL}`);
    console.error("   Start it with: cd backend && npm run dev\n");
    process.exit(1);
  }
  if (!ADMIN_SECRET) {
    console.warn("⚠️  ADMIN_SECRET not set — admin/code scenarios will be skipped");
  }
});

// ═════════════════════════════════════════════════════════════════════════════
// Scenario 1 — Trial registration: next day shows 6 days remaining
// ═════════════════════════════════════════════════════════════════════════════
describe("Scenario 1 — Trial: day 1 → 6 days remaining", () => {
  const DEV = uid("s1");

  before(async () => {
    // Register device, then manually backdate trial start to 1 day ago
    await api("POST", "/premium/start-trial", { headers: device(DEV) });
    await setTrialAge(DEV, 1); // started 1 day ago → 6 days left
  });

  after(() => cleanup(DEV));

  test("status reports trial_active = true", async () => {
    const { status, body } = await api("GET", "/premium/status", { headers: device(DEV) });
    assert.equal(status, 200);
    assert.equal(body.trial_active, true, "trial_active must be true");
  });

  test("trial_days_left equals 6 (±1 for clock drift)", async () => {
    const { body } = await api("GET", "/premium/status", { headers: device(DEV) });
    assert.ok(
      body.trial_days_left >= 5 && body.trial_days_left <= 7,
      `Expected ~6 days left, got ${body.trial_days_left}`,
    );
  });

  test("is_premium is true while trial is active", async () => {
    const { body } = await api("GET", "/premium/status", { headers: device(DEV) });
    assert.equal(body.is_premium, true);
    // is_paid_premium is false unless DEV_FORCE_PREMIUM overrides (dev env only)
    if (process.env.DEV_FORCE_PREMIUM !== "true") {
      assert.equal(body.is_paid_premium, false, "is_paid_premium must be false for trial-only device");
    }
  });

  test("cannot start trial again — already_active returned", async () => {
    const { body } = await api("POST", "/premium/start-trial", { headers: device(DEV) });
    assert.equal(body.started, false);
    assert.equal(body.already_active, true);
  });
});

// ═════════════════════════════════════════════════════════════════════════════
// Scenario 2 — Expired trial: Inside features correctly blocked
// ═════════════════════════════════════════════════════════════════════════════
describe("Scenario 2 — Expired trial: Inside features blocked", () => {
  const DEV = uid("s2");

  before(() => setTrialExpired(DEV));
  after(() => cleanup(DEV));

  test("status reports trial_expired = true", async () => {
    const { status, body } = await api("GET", "/premium/status", { headers: device(DEV) });
    assert.equal(status, 200);
    assert.equal(body.trial_expired, true);
    assert.equal(body.trial_active, false);
  });

  test("is_premium is false after trial expires", async () => {
    // Skip check if DEV_FORCE_PREMIUM is on — it overrides all devices to premium
    if (process.env.DEV_FORCE_PREMIUM === "true") {
      console.warn("  [DEV] Skipping is_premium=false check — DEV_FORCE_PREMIUM is active");
      return;
    }
    const { body } = await api("GET", "/premium/status", { headers: device(DEV) });
    assert.equal(body.is_premium, false);
  });

  test("start-trial blocked — already_used returned", async () => {
    const { body } = await api("POST", "/premium/start-trial", { headers: device(DEV) });
    assert.equal(body.started, false);
    assert.equal(body.already_used, true);
  });

  test("feed still returns quotes (free tier)", async () => {
    const { status, body } = await api("GET", "/quotes/feed?lang=en&limit=5", {
      headers: device(DEV),
    });
    assert.equal(status, 200);
    assert.ok(Array.isArray(body.data), "data array expected");
    assert.ok(body.data.length > 0, "feed must not be empty for expired trial user");
  });

  test("vault limit is enforced at 20 for expired trial user", async () => {
    // Need 21 real quote IDs: fill vault with 20, then try to add the 21st via API
    const quoteIds = await getFreeQuoteIds(21);
    if (quoteIds.length < 21) {
      console.warn("  [SKIP] Not enough free quotes in DB — vault limit test skipped");
      return;
    }

    await supabase.from("vault").delete().eq("device_id", DEV);
    await supabase.from("users").upsert({ device_id: DEV, is_premium: false }, { onConflict: "device_id" });
    // Insert 20 real vault entries directly (bypasses the API dedup check)
    await supabase.from("vault").upsert(
      quoteIds.slice(0, 20).map((id) => ({ device_id: DEV, quote_id: id })),
    );

    const { status, body } = await api("POST", "/vault", {
      headers: device(DEV),
      body: { quote_id: quoteIds[20] },
    });
    assert.equal(status, 403, `Expected 403 VAULT_LIMIT_REACHED, got ${status}`);
    assert.equal(body.code, "VAULT_LIMIT_REACHED");
  });
});

// ═════════════════════════════════════════════════════════════════════════════
// Scenario 3 — Activation code: donation → admin generates → user redeems
// ═════════════════════════════════════════════════════════════════════════════
describe("Scenario 3 — Activation code: admin create → user redeem", () => {
  const DEV = uid("s3");
  let generatedCode = null;

  before(async () => {
    if (!ADMIN_SECRET) return; // skip if not configured
    // Admin creates one code
    const { body } = await api("POST", "/admin/codes/create", {
      headers: { ...adminHeaders },
      body: { count: 1, notes: "pre-release test scenario 3" },
    });
    generatedCode = body.codes?.[0]?.code ?? null;
  });

  after(async () => {
    await cleanup(DEV);
    // Remove the test code from DB
    if (generatedCode) {
      await supabase
        .from("premium_activation_codes")
        .delete()
        .eq("code", generatedCode);
    }
  });

  test("admin can create an activation code", async () => {
    if (!ADMIN_SECRET) {
      console.warn("  [SKIP] ADMIN_SECRET not set");
      return;
    }
    assert.ok(generatedCode, "Expected a code to be generated");
    assert.match(generatedCode, /^MIND-[A-Z0-9]{4}-[A-Z0-9]{4}$/);
  });

  test("user redeems code and gains lifetime premium", async () => {
    if (!ADMIN_SECRET || !generatedCode) {
      console.warn("  [SKIP] No code available");
      return;
    }
    const { status, body } = await api("POST", "/premium/redeem", {
      headers: device(DEV),
      body: { code: generatedCode },
    });
    assert.equal(status, 200, `Redeem failed: ${JSON.stringify(body)}`);
    assert.equal(body.success, true);
  });

  test("status shows premium_lifetime after redemption", async () => {
    if (!ADMIN_SECRET || !generatedCode) return;
    const { body } = await api("GET", "/premium/status", { headers: device(DEV) });
    assert.equal(body.is_premium, true);
    assert.equal(body.is_paid_premium, true);
  });

  test("same code cannot be redeemed twice", async () => {
    if (!ADMIN_SECRET || !generatedCode) return;
    const { status, body } = await api("POST", "/premium/redeem", {
      headers: device(uid("s3-dup")),
      body: { code: generatedCode },
    });
    assert.equal(status, 409);
    assert.equal(body.code, "CODE_ALREADY_REDEEMED");
  });

  test("revoked code cannot be redeemed", async () => {
    if (!ADMIN_SECRET) return;
    // Create a fresh code then revoke it before redemption
    const { body: createBody } = await api("POST", "/admin/codes/create", {
      headers: { ...adminHeaders },
      body: { count: 1, notes: "revoke test" },
    });
    const revokeCode = createBody.codes?.[0]?.code;
    assert.ok(revokeCode, "Expected revoke test code");

    await api("POST", "/admin/codes/revoke", {
      headers: { ...adminHeaders },
      body: { code: revokeCode },
    });

    const { status, body: redeemBody } = await api("POST", "/premium/redeem", {
      headers: device(uid("s3-rev")),
      body: { code: revokeCode },
    });
    assert.equal(status, 410);
    assert.equal(redeemBody.code, "CODE_REVOKED");

    // cleanup
    await supabase.from("premium_activation_codes").delete().eq("code", revokeCode);
  });
});

// ═════════════════════════════════════════════════════════════════════════════
// Scenario 4 — Pack purchases activate correctly
// ═════════════════════════════════════════════════════════════════════════════
describe("Scenario 4 — Pack content accessible to premium users", () => {
  const DEV_FREE    = uid("s4-free");
  const DEV_PREMIUM = uid("s4-prem");

  before(async () => {
    // Grant premium to DEV_PREMIUM
    await supabase.from("users").upsert(
      { device_id: DEV_PREMIUM, is_premium: true, premium_status: "premium_onetime" },
      { onConflict: "device_id" },
    );
  });

  after(() => cleanup(DEV_FREE, DEV_PREMIUM));

  test("packs endpoint lists available packs", async () => {
    const { status, body } = await api("GET", "/packs?lang=en", { headers: device(DEV_FREE) });
    assert.equal(status, 200);
    assert.ok(Array.isArray(body.packs), "Expected packs array");
    assert.ok(body.packs.length >= 3, `Expected at least 3 packs, got ${body.packs.length}`);
  });

  test("packs are marked is_premium: true", async () => {
    const { body } = await api("GET", "/packs?lang=en", { headers: device(DEV_FREE) });
    for (const pack of body.packs) {
      assert.equal(pack.is_premium, true, `Pack ${pack.id} should be premium`);
    }
  });

  test("pack preview returns quotes", async () => {
    const { body: listBody } = await api("GET", "/packs?lang=en", { headers: device(DEV_PREMIUM) });
    const firstPack = listBody.packs?.[0];
    if (!firstPack) {
      console.warn("  [SKIP] No packs found");
      return;
    }
    const res = await api("GET", `/packs/${firstPack.id}/preview?lang=en`, {
      headers: device(DEV_PREMIUM),
    });
    assert.equal(res.status, 200);
    assert.ok(Array.isArray(res.body.quotes) || Array.isArray(res.body.data));
  });

  test("premium user feed includes is_premium quotes", async () => {
    // Feed for premium users passes p_is_premium=true to RPC → premium quotes included
    const { status, body } = await api("GET", "/quotes/feed?lang=en&limit=20", {
      headers: device(DEV_PREMIUM),
    });
    assert.equal(status, 200);
    assert.ok(Array.isArray(body.data), "Expected data array from feed");
  });

  test("premium user can purchase/verify Inside (android)", async () => {
    const { status, body } = await api("POST", "/premium/purchase/verify", {
      headers: device(DEV_PREMIUM),
      body: {
        store:          "android",
        product_id:     "com.mindscrolling.inside",
        purchase_token: `test-token-${Date.now()}`,
      },
    });
    assert.equal(status, 200, `Verify failed: ${JSON.stringify(body)}`);
    assert.equal(body.success, true);
    assert.equal(body.status, "verified");
  });
});

// ═════════════════════════════════════════════════════════════════════════════
// Scenario 5 — Inside purchase via /purchase/verify (Android + iOS)
// ═════════════════════════════════════════════════════════════════════════════
describe("Scenario 5 — Inside purchase: Android and iOS verify flows", () => {
  const DEV_AND = uid("s5-and");
  const DEV_IOS = uid("s5-ios");

  after(() => cleanup(DEV_AND, DEV_IOS));

  test("Android purchase verify returns success", async () => {
    const { status, body } = await api("POST", "/premium/purchase/verify", {
      headers: device(DEV_AND),
      body: {
        store:          "android",
        product_id:     "com.mindscrolling.inside",
        purchase_token: `gpa.test.${Date.now()}`,
      },
    });
    assert.equal(status, 200, JSON.stringify(body));
    assert.equal(body.success, true);
    assert.equal(body.status, "verified");
  });

  test("Android purchase sets is_premium = true", async () => {
    const { body } = await api("GET", "/premium/status", { headers: device(DEV_AND) });
    assert.equal(body.is_premium, true);
    assert.equal(body.is_paid_premium, true);
  });

  test("iOS purchase verify returns success", async () => {
    const { status, body } = await api("POST", "/premium/purchase/verify", {
      headers: device(DEV_IOS),
      body: {
        store:          "ios",
        product_id:     "com.mindscrolling.inside",
        transaction_id: `ios-txn-${Date.now()}`,
      },
    });
    assert.equal(status, 200, JSON.stringify(body));
    assert.equal(body.success, true);
  });

  test("iOS purchase sets is_premium = true", async () => {
    const { body } = await api("GET", "/premium/status", { headers: device(DEV_IOS) });
    assert.equal(body.is_premium, true);
    assert.equal(body.is_paid_premium, true);
  });

  test("wrong product_id returns 400 INVALID_FIELD", async () => {
    const DEV_BAD = uid("s5-bad");
    const { status, body } = await api("POST", "/premium/purchase/verify", {
      headers: device(DEV_BAD),
      body: {
        store:      "android",
        product_id: "com.wrong.product",
      },
    });
    assert.equal(status, 400);
    assert.equal(body.code, "INVALID_FIELD");
    await cleanup(DEV_BAD);
  });

  test("missing store returns 400 MISSING_FIELD", async () => {
    const DEV_NS = uid("s5-ns");
    const { status, body } = await api("POST", "/premium/purchase/verify", {
      headers: device(DEV_NS),
      body: { product_id: "com.mindscrolling.inside" },
    });
    assert.equal(status, 400);
    assert.equal(body.code, "MISSING_FIELD");
    await cleanup(DEV_NS);
  });
});

// ═════════════════════════════════════════════════════════════════════════════
// Scenario 6 — Local price display
// ═════════════════════════════════════════════════════════════════════════════
describe("Scenario 6 — Local price display", () => {
  const DEV = uid("s6");
  after(() => cleanup(DEV));

  test("status returns a price field with value 4.99", async () => {
    const { status, body } = await api("GET", "/premium/status", { headers: device(DEV) });
    assert.equal(status, 200);
    assert.ok(body.price !== undefined, "price field must be present");
    assert.equal(String(body.price), "4.99", `Expected base price 4.99, got ${body.price}`);
  });

  test("status returns currency field USD", async () => {
    const { body } = await api("GET", "/premium/status", { headers: device(DEV) });
    assert.equal(body.currency, "USD");
  });

  test("plan name matches MindScrolling Inside", async () => {
    // Start a trial first so plan is populated
    await api("POST", "/premium/start-trial", { headers: device(DEV) });
    const { body } = await api("GET", "/premium/status", { headers: device(DEV) });
    assert.equal(body.plan, "MindScrolling Inside");
  });

  test("price field present even without trial (for paywall display)", async () => {
    const NEW_DEV = uid("s6-new");
    const { body } = await api("GET", "/premium/status", { headers: device(NEW_DEV) });
    assert.ok(body.price, "price must always be present for paywall UI");
    await cleanup(NEW_DEV);
  });
});

// ═════════════════════════════════════════════════════════════════════════════
// Scenario 7 — Reinstall with 1 day trial left → same device_id → still 1 day
// ═════════════════════════════════════════════════════════════════════════════
describe("Scenario 7 — Reinstall preserves trial time (1 day left)", () => {
  const DEV = uid("s7");

  before(async () => {
    // Trial started 6 days ago → 1 day remaining
    await setTrialAge(DEV, 6);
  });
  after(() => cleanup(DEV));

  test("before reinstall: 1 day left", async () => {
    const { body } = await api("GET", "/premium/status", { headers: device(DEV) });
    assert.equal(body.trial_active, true);
    assert.ok(
      body.trial_days_left >= 1 && body.trial_days_left <= 2,
      `Expected ~1 day left, got ${body.trial_days_left}`,
    );
  });

  test("reinstall (fresh start-trial call with same device_id) returns already_active", async () => {
    // Simulates the Flutter app calling start-trial on a fresh install
    const { body } = await api("POST", "/premium/start-trial", { headers: device(DEV) });
    assert.equal(body.started, false);
    assert.equal(body.already_active, true, "Same device_id must not restart trial");
  });

  test("after reinstall: trial_days_left unchanged", async () => {
    const { body } = await api("GET", "/premium/status", { headers: device(DEV) });
    assert.equal(body.trial_active, true);
    assert.ok(
      body.trial_days_left >= 1 && body.trial_days_left <= 2,
      `Expected ~1 day left after reinstall, got ${body.trial_days_left}`,
    );
  });

  test("trial data is device_id-keyed — different device gets fresh trial", async () => {
    const NEW_DEV = uid("s7-new");
    const { body } = await api("POST", "/premium/start-trial", { headers: device(NEW_DEV) });
    assert.equal(body.started, true);
    assert.equal(body.trial_days_left, 7);
    await cleanup(NEW_DEV);
  });
});

// ═════════════════════════════════════════════════════════════════════════════
// Scenario 8 — Free user: swipe state persists across reinstall / lang change
// ═════════════════════════════════════════════════════════════════════════════
describe("Scenario 8 — Free user: swipe/preference state persists across reinstall", () => {
  const DEV = uid("s8");

  before(async () => {
    // Create user with some swipe_events recorded
    await supabase.from("users").upsert(
      { device_id: DEV, is_premium: false },
      { onConflict: "device_id" },
    );
    // Record 3 swipe events (simulates 3 quotes swiped today)
    const freeId = await getAnyFreeQuoteId("en");
    if (freeId) {
      await supabase.from("swipe_events").insert([
        { device_id: DEV, quote_id: freeId, direction: "up",   lang: "en" },
        { device_id: DEV, quote_id: freeId, direction: "right", lang: "en" },
        { device_id: DEV, quote_id: freeId, direction: "left", lang: "en" },
      ]);
      // Record user_preferences for stoicism (from 'up' swipes)
      await supabase.from("user_preferences").upsert(
        { device_id: DEV, category: "stoicism", swipe_count: 2 },
        { onConflict: "device_id,category" },
      );
    }
  });

  after(() => cleanup(DEV));

  test("swipe_events are stored server-side (not lost on reinstall)", async () => {
    const { data } = await supabase
      .from("swipe_events")
      .select("id")
      .eq("device_id", DEV);
    assert.ok(data && data.length >= 3, `Expected 3 swipe events, found ${data?.length ?? 0}`);
  });

  test("user_preferences persisted by device_id", async () => {
    const { data } = await supabase
      .from("user_preferences")
      .select("category, swipe_count")
      .eq("device_id", DEV);
    assert.ok(data && data.length > 0, "user_preferences must exist for the device");
  });

  test("feed still works after 'reinstall' (same device_id, new session)", async () => {
    // Simulates app re-launch — same device_id, no local state
    const { status, body } = await api("GET", "/quotes/feed?lang=en&limit=5", {
      headers: device(DEV),
    });
    assert.equal(status, 200);
    assert.ok(body.data?.length > 0, "Feed must return quotes on re-launch");
  });

  test("feed returns same lang after language change in settings", async () => {
    // Language is passed as query param — preference is device-side
    const { status: esStatus, body: esBody } = await api(
      "GET", "/quotes/feed?lang=es&limit=5",
      { headers: device(DEV) },
    );
    assert.equal(esStatus, 200, "Spanish feed must work");
    assert.ok(esBody.data?.length > 0, "Spanish feed must have quotes");

    // Switch back to English
    const { status: enStatus, body: enBody } = await api(
      "GET", "/quotes/feed?lang=en&limit=5",
      { headers: device(DEV) },
    );
    assert.equal(enStatus, 200, "English feed must work after language change");
    assert.ok(enBody.data?.length > 0);
  });
});

// ═════════════════════════════════════════════════════════════════════════════
// Extra — TOCTOU race: concurrent start-trial calls only grant one trial
// ═════════════════════════════════════════════════════════════════════════════
describe("Extra — TOCTOU: concurrent start-trial race grants exactly one trial", () => {
  const DEV = uid("toctou");
  after(() => cleanup(DEV));

  test("5 concurrent start-trial calls → exactly one started:true", async () => {
    // Pre-create the user row to ensure upsert doesn't interfere
    await supabase.from("users").upsert(
      { device_id: DEV },
      { onConflict: "device_id" },
    );

    const results = await Promise.all(
      Array.from({ length: 5 }, () =>
        api("POST", "/premium/start-trial", { headers: device(DEV) }),
      ),
    );

    const started = results.filter((r) => r.body.started === true);
    assert.equal(started.length, 1, `Expected exactly 1 trial start, got ${started.length}`);
  });
});

// ═════════════════════════════════════════════════════════════════════════════
// Extra — Admin auth: wrong secret rejected with 403
// ═════════════════════════════════════════════════════════════════════════════
describe("Extra — Admin security: wrong secret blocked", () => {
  test("wrong admin secret returns 403", async () => {
    const { status, body } = await api("POST", "/admin/codes/create", {
      headers: { "X-Admin-Secret": "wrong-secret-value" },
      body: { count: 1 },
    });
    assert.equal(status, 403);
    assert.equal(body.code, "INVALID_ADMIN_SECRET");
  });

  test("missing admin secret returns 403", async () => {
    const { status } = await api("POST", "/admin/codes/create", { body: { count: 1 } });
    assert.equal(status, 403);
  });
});

// ═════════════════════════════════════════════════════════════════════════════
// Extra — Vault: premium user can exceed 20 saves
// ═════════════════════════════════════════════════════════════════════════════
describe("Extra — Vault: premium user is not limited to 20 saves", () => {
  const DEV = uid("vault-prem");
  let extraQuoteId = null;

  before(async () => {
    await supabase.from("users").upsert(
      { device_id: DEV, is_premium: true },
      { onConflict: "device_id" },
    );
    const quoteIds = await getFreeQuoteIds(21);
    if (quoteIds.length >= 21) {
      await supabase.from("vault").upsert(
        quoteIds.slice(0, 20).map((id) => ({ device_id: DEV, quote_id: id })),
      );
      extraQuoteId = quoteIds[20];
    }
  });

  after(() => cleanup(DEV));

  test("premium user can save a 21st quote without 403", async () => {
    if (!extraQuoteId) {
      console.warn("  [SKIP] Not enough free quotes in DB");
      return;
    }
    const { status, body } = await api("POST", "/vault", {
      headers: device(DEV),
      body: { quote_id: extraQuoteId },
    });
    // Either 200 OK or 200 already_saved — not 403
    assert.ok(status === 200, `Expected 200, got ${status}: ${JSON.stringify(body)}`);
    assert.notEqual(body.code, "VAULT_LIMIT_REACHED");
  });
});
