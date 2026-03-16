/**
 * Embedding service — Voyage AI
 *
 * Model: voyage-3-lite
 *   - 512 dimensions
 *   - Best-in-class retrieval for short philosophical texts
 *   - 4× cheaper than voyage-3 with comparable quality for this domain
 *
 * Preference Vector Updates
 *   - High-signal events (like, vault, long dwell) trigger an async EMA update
 *   - The blending happens inside Postgres via upsert_preference_vector RPC
 *   - Callers fire-and-forget: `updatePreferenceVector(...).catch(() => {})`
 */

import { supabase } from "../db/client.js";

const VOYAGE_API_URL  = "https://api.voyageai.com/v1/embeddings";
const VOYAGE_MODEL    = "voyage-3-lite";
const VOYAGE_API_KEY  = process.env.VOYAGE_API_KEY;

// Learning rates per signal type (α in the EMA: higher = learns faster from this event)
const ALPHA = {
  vault:  0.25,   // strongest: deliberate save for later
  like:   0.20,   // strong: explicit approval
  dwell:  0.10,   // moderate: long reading session (≥ 5 s)
};

// ─── Public API ───────────────────────────────────────────────────────────────

/**
 * Generate a single embedding vector for a text string.
 * Returns Float32Array(512) or throws on error.
 */
export async function generateEmbedding(text) {
  if (!VOYAGE_API_KEY) {
    throw new Error("VOYAGE_API_KEY not configured");
  }

  const response = await fetch(VOYAGE_API_URL, {
    method:  "POST",
    headers: {
      "Authorization": `Bearer ${VOYAGE_API_KEY}`,
      "Content-Type":  "application/json",
    },
    body: JSON.stringify({
      input: [text],
      model: VOYAGE_MODEL,
    }),
  });

  if (!response.ok) {
    const body = await response.text();
    throw new Error(`Voyage AI error ${response.status}: ${body}`);
  }

  const json = await response.json();
  return json.data[0].embedding;   // number[]
}

/**
 * Generate embeddings for a batch of texts in a single API call.
 * Voyage AI supports up to 128 inputs per request.
 * Returns number[][] (array of 512-dim vectors).
 */
export async function generateEmbeddingBatch(texts) {
  if (!VOYAGE_API_KEY) {
    throw new Error("VOYAGE_API_KEY not configured");
  }
  if (texts.length === 0) return [];

  const response = await fetch(VOYAGE_API_URL, {
    method:  "POST",
    headers: {
      "Authorization": `Bearer ${VOYAGE_API_KEY}`,
      "Content-Type":  "application/json",
    },
    body: JSON.stringify({
      input: texts,
      model: VOYAGE_MODEL,
    }),
  });

  if (!response.ok) {
    const body = await response.text();
    throw new Error(`Voyage AI error ${response.status}: ${body}`);
  }

  const json = await response.json();
  // Preserve input order (API may reorder if batched)
  return json.data
    .sort((a, b) => a.index - b.index)
    .map(d => d.embedding);
}

/**
 * Asynchronously update a device's semantic preference vector.
 * Designed for fire-and-forget: caller should not await.
 *
 * @param {string} deviceId
 * @param {string} quoteId    - UUID of the quote that triggered the signal
 * @param {'like'|'vault'|'dwell'} signalType
 */
export async function updatePreferenceVector(deviceId, quoteId, signalType) {
  // 1. Fetch the quote's stored embedding
  const { data: quote, error } = await supabase
    .from("quotes")
    .select("embedding")
    .eq("id", quoteId)
    .maybeSingle();

  if (error || !quote?.embedding) {
    // Quote not yet embedded — skip silently (embedding script runs async)
    return;
  }

  const alpha = ALPHA[signalType] ?? ALPHA.dwell;

  // 2. Delegate blending + normalisation to Postgres RPC (atomic, no race conditions)
  await supabase.rpc("upsert_preference_vector", {
    p_device_id: deviceId,
    p_new_vec:   quote.embedding,
    p_alpha:     alpha,
  });
}

/**
 * Fetch the current preference vector for a device.
 * Returns number[] or null if the device has no vector yet.
 */
export async function getPreferenceVector(deviceId) {
  const { data } = await supabase
    .from("user_preference_vectors")
    .select("vector")
    .eq("device_id", deviceId)
    .maybeSingle();

  return data?.vector ?? null;
}
