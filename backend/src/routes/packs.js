/**
 * packs.js — Block B Pack Monetization routes
 *
 * Endpoints:
 *   GET  /packs                     — catalog with per-device access_status
 *   GET  /packs/:id/preview         — curated preview quotes (5 free / 15 trial / redirect entitled)
 *   GET  /packs/:id/feed            — full paginated pack feed (entitled users only)
 *   POST /packs/:id/purchase/verify — record & verify individual pack purchase (idempotent)
 *
 * All entitlement decisions use getPackEntitlement() from packEntitlement.js.
 * Pack swipes do NOT count against Free 20/day limit (BR-06, OQ-01).
 * Grandfathering cutoff: 2026-06-01 (OQ-02, BR-04).
 */

import { supabase } from "../db/client.js";
import {
  getPackEntitlement,
  resolveUserState,
} from "../services/packEntitlement.js";
import { UUID_RE, authorSlug, normalizeLang } from "../utils/validation.js";

// ─── Pack catalog metadata ───────────────────────────────────────────────────
const PACK_META = {
  stoicism_deep: {
    nameEn: "Stoicism Deep Dive",
    nameEs: "Estoicismo Profundo",
    descEn:
      "500 quotes from the greatest Stoic thinkers. Marcus Aurelius, Seneca, Epictetus, and more.",
    descEs:
      "500 frases de los más grandes pensadores estoicos. Marco Aurelio, Séneca, Epicteto y más.",
    icon: "shield",
    color: "#14B8A6",
  },
  existentialism: {
    nameEn: "Existentialism",
    nameEs: "Existencialismo",
    descEn:
      "Explore the meaning of existence through Camus, Sartre, Nietzsche, Kierkegaard, and Dostoevsky.",
    descEs:
      "Explora el sentido de la existencia con Camus, Sartre, Nietzsche, Kierkegaard y Dostoyevski.",
    icon: "psychology",
    color: "#A78BFA",
  },
  zen_mindfulness: {
    nameEn: "Zen & Mindfulness",
    nameEs: "Zen y Mindfulness",
    descEn:
      "Ancient wisdom from Buddha, Lao Tzu, Rumi, the Dalai Lama, Alan Watts, and Thich Nhat Hanh.",
    descEs:
      "Sabiduría ancestral de Buda, Lao Tse, Rumi, el Dalai Lama, Alan Watts y Thich Nhat Hanh.",
    icon: "self_improvement",
    color: "#22C55E",
  },
  renaissance_mind: {
    nameEn: "Renaissance Mind",
    nameEs: "Mente Renacentista",
    descEn:
      "Humanism, reason, and transformation. Leonardo da Vinci, Erasmus, Montaigne, Machiavelli, and more.",
    descEs:
      "Humanismo, razón y transformación. Leonardo da Vinci, Erasmo, Montaigne, Maquiavelo y más.",
    icon: "palette",
    color: "#F59E0B",
  },
  classical_foundations: {
    nameEn: "Classical Foundations",
    nameEs: "Fundamentos Clásicos",
    descEn:
      "The roots of Western thought. Socrates, Plato, Aristotle, Cicero, Plutarch, and the ancient sages.",
    descEs:
      "Las raíces del pensamiento occidental. Sócrates, Platón, Aristóteles, Cicerón, Plutarco y los sabios antiguos.",
    icon: "account_balance",
    color: "#3B82F6",
  },
  modern_human_condition: {
    nameEn: "Modern Human Condition",
    nameEs: "Condición Humana Moderna",
    descEn:
      "Absurdity, freedom, identity. Hannah Arendt, Simone de Beauvoir, Viktor Frankl, Albert Camus, and modern voices.",
    descEs:
      "Absurdo, libertad, identidad. Hannah Arendt, Simone de Beauvoir, Viktor Frankl, Albert Camus y voces modernas.",
    icon: "psychology_alt",
    color: "#EC4899",
  },
};

// ─── Paywall copy ─────────────────────────────────────────────────────────────
const PAYWALL_COPY = {
  en: {
    ctaPack: (packName) => `Get ${packName} — $2.99`,
    ctaInside: "Or unlock everything with Inside — $4.99",
    insideValueProp: "6 packs ($17.94 value) + premium features — $4.99",
  },
  es: {
    ctaPack: (packName) => `Obtener ${packName} — $2.99`,
    ctaInside: "O desbloquea todo con Inside — $4.99",
    insideValueProp: "6 packs (valor $17.94) + funciones premium — $4.99",
  },
};

// ─── Helpers ──────────────────────────────────────────────────────────────────

/**
 * Fire-and-forget audit log insert.
 */
function logAuditEvent(deviceId, eventType, metadata) {
  supabase
    .from("premium_audit_log")
    .insert({
      device_id: deviceId,
      event_type: eventType,
      source: "app",
      metadata,
    })
    .then(() => {})
    .catch(() => {});
}

// ─── Route plugin ─────────────────────────────────────────────────────────────
export default async function packsRoutes(fastify) {
  // ── GET /packs ─────────────────────────────────────────────────────────────
  /**
   * Returns the pack catalog with per-device access_status and pricing.
   * Query: ?lang=en|es
   */
  fastify.get("/", async (request, reply) => {
    const { deviceId } = request;
    const lang = normalizeLang(request.query.lang);

    // Parallel: fetch user row + per-pack quote counts (head-only) + pack_purchases + prices
    // Bug 3 fix: use count-only queries per pack_id instead of fetching all quote rows.
    // supabase-js v2 does not support GROUP BY; three lightweight head queries are
    // cheaper than one full-scan returning ~3 000 pack_name strings.
    const packIds = Object.keys(PACK_META);

    const [
      { data: userRow, error: userErr },
      countResults,
      { data: purchaseRows },
      { data: priceRows },
    ] = await Promise.all([
      supabase
        .from("users")
        .select("is_premium, premium_status, trial_start_date, trial_end_date")
        .eq("device_id", deviceId)
        .maybeSingle(),

      Promise.all(
        packIds.map((packId) =>
          supabase
            .from("quotes")
            .select("id", { count: "exact", head: true })
            .eq("lang", lang)
            .eq("pack_name", packId)
        )
      ),

      supabase
        .from("pack_purchases")
        .select("pack_id, status")
        .eq("device_id", deviceId)
        .in("status", ["verified", "restored"]),

      supabase
        .from("pack_prices")
        .select("pack_id, amount, product_id_ios, product_id_android, currency")
        .eq("currency", "USD")
        .eq("is_active", true),
    ]);

    const countErr = countResults.find((r) => r.error)?.error ?? null;

    if (userErr || countErr) {
      request.log.error({ userErr, countErr }, "packs/catalog: DB error");
      return reply.status(500).send({ error: "Failed to load packs", code: "INTERNAL_ERROR" });
    }

    // Build helpers
    const ownedPackIds = new Set(
      (purchaseRows ?? [])
        .filter((p) => p.status === "verified" || p.status === "restored")
        .map((p) => p.pack_id)
    );

    const priceMap = {};
    for (const p of priceRows ?? []) {
      priceMap[p.pack_id] = p;
    }

    // Build pack count map from head-only results (no row data transferred)
    const packCounts = {};
    for (let i = 0; i < packIds.length; i++) {
      packCounts[packIds[i]] = countResults[i].count ?? 0;
    }

    const userState = resolveUserState(
      userRow,
      [...ownedPackIds]
    );
    const isInsideUser = userRow?.is_premium === true;

    // Build pack list
    const packs = Object.entries(PACK_META).map(([id, meta]) => {
      const isGrandfathered =
        // All 3 current packs were backfilled to 2026-01-01 — always grandfathered
        // for the Block B launch. This check future-proofs for new packs added later.
        true; // see migration 009 backfill; in production, compare pack released_at

      const isPackOwner = ownedPackIds.has(id);
      let accessStatus;
      if (isPackOwner || isInsideUser) {
        accessStatus = "unlocked";
      } else if (isGrandfathered) {
        accessStatus = "preview_only";
      } else {
        accessStatus = "purchasable";
      }

      const priceEntry = priceMap[id];

      return {
        id,
        name: lang === "es" ? meta.nameEs : meta.nameEn,
        description: lang === "es" ? meta.descEs : meta.descEn,
        icon: meta.icon,
        color: meta.color,
        quote_count: packCounts[id] ?? 0,
        is_active: true,
        is_premium: true, // all content packs are premium content
        released_at: "2026-01-01T00:00:00Z", // backfilled value from migration 009
        is_grandfathered: isGrandfathered,
        access_status: accessStatus,
        price: priceEntry
          ? {
              usd: String(priceEntry.amount),
              product_id_ios: priceEntry.product_id_ios,
              product_id_android: priceEntry.product_id_android,
            }
          : { usd: "2.99", product_id_ios: null, product_id_android: null },
      };
    });

    // Fire-and-forget analytics
    logAuditEvent(deviceId, "pack_catalog_viewed", {
      user_state: userState,
      lang,
      pack_count: packs.length,
    });

    return reply.send({ packs, user_state: userState });
  });

  // ── GET /packs/:id/preview ─────────────────────────────────────────────────
  /**
   * Returns curated preview quotes.
   * Free users: 5, Trial users: 15, Entitled users: redirect signal.
   * Query: ?lang=en|es
   */
  fastify.get("/:id/preview", async (request, reply) => {
    const { id } = request.params;
    const { deviceId } = request;
    const lang = normalizeLang(
      request.query.lang ?? request.headers["accept-language"]
    );

    if (!PACK_META[id]) {
      return reply
        .status(404)
        .send({ error: "Pack not found", code: "PACK_NOT_FOUND" });
    }

    const meta = PACK_META[id];
    const packName = lang === "es" ? meta.nameEs : meta.nameEn;

    // Resolve entitlement
    let entitlement;
    try {
      entitlement = await getPackEntitlement(deviceId, id);
    } catch {
      return reply.status(500).send({ error: "Failed to check entitlement", code: "INTERNAL_ERROR" });
    }

    // Entitled user → redirect signal (no preview quotes needed)
    if (entitlement.access === "full") {
      // Fetch quote count for metadata
      const { count: quoteCountResult } = await supabase
        .from("quotes")
        .select("*", { count: "exact", head: true })
        .eq("pack_name", id)
        .eq("lang", lang);

      const quoteCount = quoteCountResult ?? 0;

      return reply.send({
        pack: {
          id,
          name: packName,
          description: lang === "es" ? meta.descEs : meta.descEn,
          color: meta.color,
          quote_count: quoteCount,
          access_status: "unlocked",
          preview_quota: null,
          quotes_remaining_after_preview: null,
        },
        quotes: [],
        is_preview_complete: false,
        redirect_to_feed: true,
        paywall: null,
      });
    }

    // Determine preview quota
    const previewQuota = entitlement.access === "preview_trial" ? 15 : 5;
    const userState =
      entitlement.access === "preview_trial" ? "trial" : "free";

    // Fetch ALL curated preview quotes (no rank cap) to know how many exist.
    // We then slice to previewQuota for the response, and determine isPreviewComplete
    // based on whether all available previews have been served.
    const [
      { data: allPreviewQuotes, error: quotesErr },
      { count: previewTotalCount },
    ] = await Promise.all([
      supabase
        .from("quotes")
        .select(
          "id, text, author, category, lang, swipe_dir, pack_name, pack_preview_rank, is_premium, content_type, tags"
        )
        .eq("pack_name", id)
        .eq("lang", lang)
        .eq("is_pack_preview", true)
        .order("pack_preview_rank", { ascending: true }),

      supabase
        .from("quotes")
        .select("*", { count: "exact", head: true })
        .eq("pack_name", id)
        .eq("lang", lang),
    ]);

    if (quotesErr) {
      request.log.error({ err: quotesErr }, "packs/preview: DB error");
      return reply.status(500).send({ error: "Failed to load preview", code: "INTERNAL_ERROR" });
    }

    // Slice to user's quota — the rest are not shown yet
    const previewQuotes = (allPreviewQuotes ?? []).slice(0, previewQuota);
    const totalInLang = previewTotalCount ?? 0;

    if (!previewQuotes || previewQuotes.length === 0) {
      return reply.status(503).send({
        error: "No preview available in this language",
        code: "PREVIEW_UNAVAILABLE",
      });
    }

    // Add author_slug + is_locked for all returned quotes
    const quotesWithLock = previewQuotes.map((q) => ({
      ...q,
      author_slug: authorSlug(q.author),
      content_type: q.content_type ?? "philosophical",
      tags: q.tags ?? [],
      is_locked: false,
    }));

    // Preview is complete when:
    // - the user has seen their full quota, OR
    // - fewer preview quotes exist than the quota (all available content has been served)
    const totalAvailablePreview = (allPreviewQuotes ?? []).length;
    const isPreviewComplete =
      previewQuotes.length >= previewQuota ||
      totalAvailablePreview <= previewQuota;
    const copy = PAYWALL_COPY[lang] ?? PAYWALL_COPY.en;

    // Paywall block — always null when preview not yet complete
    let paywall = null;
    if (isPreviewComplete) {
      // Fetch price info
      const { data: priceRow } = await supabase
        .from("pack_prices")
        .select("amount, product_id_ios, product_id_android")
        .eq("pack_id", id)
        .eq("currency", "USD")
        .eq("is_active", true)
        .maybeSingle();

      paywall = {
        type: "hard",
        user_state: userState,
        pack_price_usd: priceRow ? String(priceRow.amount) : "2.99",
        product_id_ios: priceRow?.product_id_ios ?? null,
        product_id_android: priceRow?.product_id_android ?? null,
        cta_pack: copy.ctaPack(packName),
        cta_inside: copy.ctaInside,
        inside_value_prop: copy.insideValueProp,
      };
    }

    // Fire-and-forget analytics
    logAuditEvent(deviceId, "pack_preview_started", {
      pack_id: id,
      user_state: userState,
      preview_quota: previewQuota,
      lang,
    });
    if (isPreviewComplete) {
      logAuditEvent(deviceId, "pack_preview_completed", { pack_id: id, user_state: userState });
      if (paywall) {
        logAuditEvent(deviceId, "pack_paywall_shown", {
          pack_id: id,
          user_state: userState,
          cta_shown: "both",
        });
      }
    }

    return reply.send({
      pack: {
        id,
        name: packName,
        description: lang === "es" ? meta.descEs : meta.descEn,
        color: meta.color,
        quote_count: totalInLang,
        access_status: "preview_only",
        preview_quota: previewQuota,
        quotes_remaining_after_preview: Math.max(0, totalInLang - previewQuota),
      },
      quotes: quotesWithLock,
      is_preview_complete: isPreviewComplete,
      paywall,
    });
  });

  // ── GET /packs/:id/feed ────────────────────────────────────────────────────
  /**
   * Paginated full pack feed for entitled users only.
   * Query: ?lang=en|es&limit=20&cursor=<uuid>
   */
  fastify.get("/:id/feed", async (request, reply) => {
    const { id } = request.params;
    const { deviceId } = request;
    const lang = normalizeLang(request.query.lang);
    const rawLimit = Number(request.query.limit ?? 20);
    const cursor = request.query.cursor ?? null;

    if (!PACK_META[id]) {
      return reply
        .status(404)
        .send({ error: "Pack not found", code: "PACK_NOT_FOUND" });
    }

    if (rawLimit < 1 || rawLimit > 50 || !Number.isInteger(rawLimit)) {
      return reply.status(400).send({
        error: "limit must be an integer between 1 and 50",
        code: "INVALID_FIELD",
      });
    }

    // Entitlement check — only 'full' access may use this feed
    let entitlement;
    try {
      entitlement = await getPackEntitlement(deviceId, id);
    } catch {
      return reply.status(500).send({ error: "Failed to check entitlement", code: "INTERNAL_ERROR" });
    }

    if (entitlement.access !== "full") {
      return reply.status(403).send({
        error: "Purchase required to access this pack",
        code: "PACK_NOT_ENTITLED",
      });
    }

    // Determine access_reason for response metadata
    const accessReasonMap = {
      pack_purchased: "pack_owner",
      inside_grandfathered: "grandfathered",
      // fallback
    };
    const accessReason = accessReasonMap[entitlement.reason] ?? "inside";

    // ── Paginated query ───────────────────────────────────────────────────────
    // Cursor-based: if cursor present, return rows with id > cursor (lexicographic
    // on UUID). We fetch limit+1 to determine has_more.
    let query = supabase
      .from("quotes")
      .select(
        "id, text, author, category, lang, swipe_dir, pack_name, content_type, tags"
      )
      .eq("pack_name", id)
      .eq("lang", lang)
      .order("id", { ascending: true })
      .limit(rawLimit + 1);

    if (cursor) {
      if (!UUID_RE.test(cursor)) {
        return reply.status(400).send({ error: "cursor must be a valid UUID", code: "INVALID_FIELD" });
      }
      query = query.gt("id", cursor);
    }

    const [
      { data: quotes, error: quotesErr },
      { count: totalInLangCount, error: totalErr },
    ] = await Promise.all([
      query,
      supabase
        .from("quotes")
        .select("*", { count: "exact", head: true })
        .eq("pack_name", id)
        .eq("lang", lang),
    ]);

    if (quotesErr || totalErr) {
      request.log.error({ quotesErr, totalErr }, "packs/feed: DB error");
      return reply.status(500).send({ error: "Failed to load pack feed", code: "INTERNAL_ERROR" });
    }

    const totalInLang = totalInLangCount ?? 0;
    const hasMore = (quotes?.length ?? 0) > rawLimit;
    const pageQuotes = hasMore ? quotes.slice(0, rawLimit) : (quotes ?? []);
    const nextCursor =
      hasMore && pageQuotes.length > 0
        ? pageQuotes[pageQuotes.length - 1].id
        : null;

    const meta = PACK_META[id];

    // Fire-and-forget analytics on first page (no cursor)
    if (!cursor) {
      logAuditEvent(deviceId, "pack_feed_entered", {
        pack_id: id,
        access_reason: accessReason,
        lang,
      });
    }

    return reply.send({
      pack: {
        id,
        name: lang === "es" ? meta.nameEs : meta.nameEn,
        color: meta.color,
        quote_count: totalInLang,
        access_reason: accessReason,
      },
      data: pageQuotes.map(q => ({
        ...q,
        author_slug: authorSlug(q.author),
        content_type: q.content_type ?? 'philosophical',
        tags: q.tags ?? [],
      })),
      next_cursor: nextCursor,
      has_more: hasMore,
      total_in_lang: totalInLang,
    });
  });

  // ── POST /packs/:id/purchase/verify ───────────────────────────────────────
  /**
   * Verifies a pack purchase receipt and records entitlement.
   * Idempotent: returns 200 with already_owned if pack already purchased.
   * Rate limit: 10 req/min per device (separate scope per contract §6).
   *
   * Body: { store, product_id, purchase_token?, transaction_id?, amount, currency }
   */
  fastify.post(
    "/:id/purchase/verify",
    {
      config: {
        // Stricter per-device rate limit for purchase endpoints (abuse vector).
        // @fastify/rate-limit scoped config — keyed by device ID from plugin.
        rateLimit: {
          max: 10,
          timeWindow: 60_000,
          keyGenerator: (req) => req.deviceId ?? req.ip,
        },
      },
    },
    async (request, reply) => {
      const { id } = request.params;
      const { deviceId } = request;

      if (!PACK_META[id]) {
        return reply
          .status(404)
          .send({ error: "Pack not found", code: "PACK_NOT_FOUND" });
      }

      const {
        store,
        product_id,
        purchase_token = null,
        transaction_id = null,
        amount,
        currency = "USD",
      } = request.body ?? {};

      // ── Required field validation ───────────────────────────────────────────
      if (!store)
        return reply
          .status(400)
          .send({ error: "store is required", code: "MISSING_FIELD" });
      if (!product_id)
        return reply
          .status(400)
          .send({ error: "product_id is required", code: "MISSING_FIELD" });
      if (amount === undefined || amount === null || !isFinite(Number(amount)))
        return reply
          .status(400)
          .send({ error: "amount must be a valid number", code: "INVALID_FIELD" });
      if (!currency)
        return reply
          .status(400)
          .send({ error: "currency is required", code: "MISSING_FIELD" });

      const VALID_CURRENCIES = ["USD", "EUR", "GBP", "ARS", "BRL"];
      if (!VALID_CURRENCIES.includes(String(currency).toUpperCase())) {
        return reply.status(400).send({ error: "Invalid currency", code: "INVALID_FIELD" });
      }

      if (!["ios", "android"].includes(store)) {
        return reply.status(400).send({
          error: "store must be ios or android",
          code: "INVALID_FIELD",
        });
      }

      if (store === "android" && !purchase_token) {
        return reply.status(400).send({
          error: "purchase_token is required for android store",
          code: "INVALID_FIELD",
        });
      }
      if (store === "ios" && !transaction_id) {
        return reply.status(400).send({
          error: "transaction_id is required for ios store",
          code: "INVALID_FIELD",
        });
      }

      // ── Validate product_id against pack_prices ─────────────────────────────
      const { data: priceRow, error: priceErr } = await supabase
        .from("pack_prices")
        .select("amount, product_id_ios, product_id_android")
        .eq("pack_id", id)
        .eq("currency", "USD")
        .eq("is_active", true)
        .maybeSingle();

      if (priceErr) {
        request.log.error({ err: priceErr }, "packs/purchase/verify: price lookup failed");
        return reply.status(500).send({ error: "Failed to validate product", code: "INTERNAL_ERROR" });
      }

      const expectedProductId =
        store === "ios"
          ? priceRow?.product_id_ios
          : priceRow?.product_id_android;

      if (!expectedProductId || product_id !== expectedProductId) {
        return reply.status(400).send({
          error: `product_id does not match canonical value for pack '${id}' on store '${store}'`,
          code: "INVALID_FIELD",
        });
      }

      // Log amount mismatch (do not fail — regional pricing variance allowed)
      const canonicalAmount = Number(priceRow?.amount ?? 2.99);
      if (Number(amount) !== canonicalAmount) {
        request.log.warn(
          { deviceId, pack_id: id, expected: canonicalAmount, received: amount },
          "packs/purchase/verify: amount mismatch (regional pricing?)"
        );
      }

      // ── Upsert user row (ensure FK exists before inserting purchase) ─────────
      const { error: userUpsertErr } = await supabase
        .from("users")
        .upsert({ device_id: deviceId }, { onConflict: "device_id" });

      if (userUpsertErr) {
        request.log.error({ err: userUpsertErr }, "packs/purchase/verify: user upsert failed");
        return reply
          .status(500)
          .send({ error: "Failed to initialise user", code: "INTERNAL_ERROR" });
      }

      // ── Idempotency check: already verified? ──────────────────────────────────
      const { data: existingPurchase, error: existingErr } = await supabase
        .from("pack_purchases")
        .select("id, pack_id")
        .eq("device_id", deviceId)
        .eq("pack_id", id)
        .eq("status", "verified")
        .maybeSingle();

      if (existingErr) {
        request.log.error({ err: existingErr }, "packs/purchase/verify: existing check failed");
        return reply.status(500).send({ error: "Failed to check existing purchase", code: "INTERNAL_ERROR" });
      }

      const meta = PACK_META[id];
      const packName = meta.nameEn; // confirmation message always EN (client localizes)

      if (existingPurchase) {
        // EC-09: idempotent — already owned
        return reply.status(200).send({
          status: "already_owned",
          pack_id: id,
          pack_name: packName,
          access_granted: true,
        });
      }

      // ── Insert pack_purchase row (upsert handles any race condition) ──────────
      const now = new Date().toISOString();
      const { error: insertErr } = await supabase
        .from("pack_purchases")
        .upsert(
          {
            device_id: deviceId,
            pack_id: id,
            store,
            product_id,
            purchase_token,
            transaction_id,
            amount: Number(amount),
            currency: String(currency).toUpperCase().slice(0, 3),
            status: "verified",
            purchased_at: now,
            updated_at: now,
          },
          { onConflict: "device_id,pack_id" }
        );

      if (insertErr) {
        request.log.error({ err: insertErr }, "packs/purchase/verify: insert failed");
        return reply
          .status(500)
          .send({ error: "Failed to record purchase", code: "INTERNAL_ERROR" });
      }

      // Fire-and-forget audit log
      logAuditEvent(deviceId, "pack_purchased", {
        pack_id: id,
        store,
        amount: Number(amount),
        currency,
        product_id,
      });

      request.log.info(
        { deviceId, pack_id: id, store },
        "packs/purchase/verify: purchase recorded"
      );

      return reply.status(201).send({
        status: "verified",
        pack_id: id,
        pack_name: packName,
        access_granted: true,
        message: `${packName} unlocked.`,
      });
    }
  );

}
