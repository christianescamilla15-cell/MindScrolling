/**
 * stripe.js — Stripe Checkout integration for web payments
 *
 * Endpoints:
 *   POST /stripe/checkout     — create a Stripe Checkout session
 *   POST /stripe/webhook      — handle Stripe webhook events
 *   GET  /stripe/prices       — list available prices
 *
 * Mobile payments still go through RevenueCat (iOS/Android).
 * Stripe handles web-based purchases and future subscription upgrades.
 */

import Stripe from "stripe";
import { supabase } from "../db/client.js";

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

// Stripe Price IDs (created in test mode)
const PRICE_MAP = {
  inside:                  process.env.STRIPE_PRICE_INSIDE || "price_1THbEoQqMY6dT0VmtlBEeQoK",
  stoicism_deep:           process.env.STRIPE_PRICE_STOICISM || "price_1THbEoQqMY6dT0Vm8ERJ7xrD",
  existentialism:          process.env.STRIPE_PRICE_EXISTENTIALISM || "price_1THbEpQqMY6dT0VmFAWkcZLY",
  zen_mindfulness:         process.env.STRIPE_PRICE_ZEN || "price_1THbEqQqMY6dT0Vm3XduY5P5",
  renaissance_mind:        process.env.STRIPE_PRICE_RENAISSANCE || "price_1THbEqQqMY6dT0VmTlca5qYq",
  classical_foundations:   process.env.STRIPE_PRICE_CLASSICAL || "price_1THbErQqMY6dT0VmAeU7edkf",
  modern_human_condition:  process.env.STRIPE_PRICE_MODERN || "price_1THbErQqMY6dT0VmrD0Bkpdu",
};

const WEBHOOK_SECRET = process.env.STRIPE_WEBHOOK_SECRET || "";

export default async function stripeRoutes(fastify) {

  // ── POST /stripe/checkout ─────────────────────────────────────────────────
  fastify.post("/checkout", async (request, reply) => {
    const deviceId = request.deviceId;
    const { product } = request.body || {};

    if (!product || !PRICE_MAP[product]) {
      return reply.status(400).send({
        error: `Invalid product. Valid: ${Object.keys(PRICE_MAP).join(", ")}`,
        code: "INVALID_PRODUCT",
      });
    }

    if (!process.env.STRIPE_SECRET_KEY) {
      return reply.status(503).send({ error: "Stripe not configured", code: "STRIPE_UNAVAILABLE" });
    }

    const priceId = PRICE_MAP[product];
    const isInside = product === "inside";

    try {
      const session = await stripe.checkout.sessions.create({
        mode: "payment",
        line_items: [{ price: priceId, quantity: 1 }],
        metadata: {
          device_id: deviceId,
          product,
          type: isInside ? "premium_unlock" : "pack_purchase",
        },
        success_url: `${process.env.APP_URL || "https://mindscrolling.onrender.com"}/payment/success?session_id={CHECKOUT_SESSION_ID}`,
        cancel_url: `${process.env.APP_URL || "https://mindscrolling.onrender.com"}/payment/cancel`,
      });

      return reply.send({ url: session.url, session_id: session.id });
    } catch (err) {
      fastify.log.error("Stripe checkout error:", err.message);
      return reply.status(500).send({ error: "Failed to create checkout", code: "STRIPE_ERROR" });
    }
  });

  // ── POST /stripe/webhook ──────────────────────────────────────────────────
  fastify.post("/webhook", {
    config: { rawBody: true },
  }, async (request, reply) => {
    const sig = request.headers["stripe-signature"];
    let event;

    try {
      event = stripe.webhooks.constructEvent(request.rawBody || request.body, sig, WEBHOOK_SECRET);
    } catch (err) {
      fastify.log.error("Stripe webhook signature failed:", err.message);
      return reply.status(400).send({ error: "Invalid signature" });
    }

    if (event.type === "checkout.session.completed") {
      const session = event.data.object;
      const { device_id, product, type } = session.metadata || {};

      if (!device_id) {
        fastify.log.warn("Stripe webhook: no device_id in metadata");
        return reply.send({ received: true });
      }

      fastify.log.info(`Stripe payment: ${type} ${product} for ${device_id}`);

      if (type === "premium_unlock") {
        // Unlock premium
        await supabase
          .from("users")
          .update({ is_premium: true, premium_source: "stripe" })
          .eq("device_id", device_id);

        await supabase.from("purchases").insert({
          device_id,
          purchase_type: "premium_unlock",
          amount: session.amount_total / 100,
          currency: session.currency?.toUpperCase() || "USD",
        });
      } else if (type === "pack_purchase" && product) {
        // Record pack purchase
        await supabase.from("pack_purchases").insert({
          device_id,
          pack_id: product,
          store: "stripe",
          transaction_id: session.payment_intent,
          price_paid: session.amount_total / 100,
          currency: session.currency?.toUpperCase() || "USD",
        });
      }

      // Audit log
      await supabase.from("premium_audit_log").insert({
        device_id,
        event_type: type === "premium_unlock" ? "stripe_premium" : "stripe_pack",
        metadata: { product, session_id: session.id, amount: session.amount_total },
      });
    }

    return reply.send({ received: true });
  });

  // ── GET /stripe/prices ────────────────────────────────────────────────────
  fastify.get("/prices", async (request, reply) => {
    const prices = Object.entries(PRICE_MAP).map(([product, priceId]) => ({
      product,
      price_id: priceId,
      amount: product === "inside" ? 4.99 : 2.99,
      currency: "USD",
      type: product === "inside" ? "premium_unlock" : "pack_purchase",
    }));
    return reply.send({ prices });
  });
}
