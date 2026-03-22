/**
 * packEntitlement.js
 * Server-side entitlement resolution for individual content packs.
 * Called by packs.js, premium.js, and swipes.js.
 *
 * Resolution order (from API_CONTRACT_BLOCK_B.md §1):
 *   1. PACK_OWNER   — pack_purchases row exists for (device_id, pack_id)
 *   2. INSIDE_USER  — is_premium = true AND pack is grandfathered (released_at < CUTOFF)
 *   3. TRIAL_ACTIVE — premium_status = 'trial' AND now() < trial_end_date
 *   4. free / expired
 *
 * BR-04: Grandfathering is permanent. INSIDE_USER access to current 3 packs
 * is determined by the pack's released_at date, not the user's premium_since date.
 */

import { supabase } from "../db/client.js";

/** ISO date string — packs released before this are grandfathered for Inside users. */
export const GRANDFATHERING_CUTOFF = "2026-06-01T00:00:00Z";

/** Canonical pack IDs — original 3 grandfathered + 3 new expansion packs. */
export const KNOWN_PACK_IDS = new Set([
  "stoicism_deep",
  "existentialism",
  "zen_mindfulness",
  "renaissance_mind",
  "classical_foundations",
  "modern_human_condition",
]);

/**
 * Resolve pack entitlement for a given device and pack.
 *
 * @param {string} deviceId
 * @param {string} packId
 * @param {import('@supabase/supabase-js').SupabaseClient} [client] - defaults to singleton
 * @returns {Promise<{
 *   access: 'full' | 'preview_trial' | 'preview_free' | 'locked',
 *   reason: 'pack_purchased' | 'inside_grandfathered' | 'trial' | 'free' | 'expired'
 * }>}
 */
export async function getPackEntitlement(deviceId, packId, client = supabase) {
  // Parallel: fetch user row + pack_purchases row for this pack
  const [
    { data: userRow, error: userErr },
    { data: purchaseRow, error: purchaseErr },
  ] = await Promise.all([
    client
      .from("users")
      .select("is_premium, premium_status, trial_start_date, trial_end_date")
      .eq("device_id", deviceId)
      .maybeSingle(),

    client
      .from("pack_purchases")
      .select("id, pack_id, status")
      .eq("device_id", deviceId)
      .eq("pack_id", packId)
      .in("status", ["verified", "restored"])
      .maybeSingle(),
  ]);

  if (userErr || purchaseErr) {
    // Surface errors to caller; caller decides HTTP response.
    throw new Error("DB_ERROR");
  }

  // ── PACK_OWNER — explicit purchase (highest priority, even over Inside) ───
  if (purchaseRow) {
    return { access: "full", reason: "pack_purchased" };
  }

  // ── INSIDE_USER + GRANDFATHERED_PACK ─────────────────────────────────────
  // is_premium is the source of truth for Inside status (BR-05).
  // Grandfathering: pack must have been released before the cutoff.
  // All 3 current packs are backfilled to 2026-01-01 in migration 009.
  if (userRow?.is_premium === true) {
    // Performance: KNOWN_PACK_IDS are all backfilled to 2026-01-01 (pre-cutoff).
    // Skip the quotes table scan for known packs — return full access directly.
    if (KNOWN_PACK_IDS.has(packId)) {
      return { access: "full", reason: "inside_grandfathered" };
    }

    // Unknown (future) pack: query DB to determine grandfathering.
    const { data: packRow } = await client
      .from("quotes")
      .select("released_at")
      .eq("pack_name", packId)
      .not("released_at", "is", null)
      .limit(1)
      .maybeSingle();

    const releasedAt = packRow?.released_at ?? null;
    const isGrandfathered =
      releasedAt !== null &&
      new Date(releasedAt) < new Date(GRANDFATHERING_CUTOFF);

    if (isGrandfathered) {
      return { access: "full", reason: "inside_grandfathered" };
    }

    // Inside user but pack is post-cutoff — must purchase separately.
    // Falls through to trial / free check.
  }

  // ── TRIAL_ACTIVE ──────────────────────────────────────────────────────────
  if (
    userRow?.premium_status === "trial" &&
    userRow?.trial_end_date &&
    new Date() < new Date(userRow.trial_end_date)
  ) {
    return { access: "preview_trial", reason: "trial" };
  }

  // ── TRIAL_EXPIRED ─────────────────────────────────────────────────────────
  if (
    userRow?.premium_status === "trial" &&
    userRow?.trial_end_date &&
    new Date() >= new Date(userRow.trial_end_date)
  ) {
    return { access: "preview_free", reason: "expired" };
  }

  // ── FREE (default) ────────────────────────────────────────────────────────
  return { access: "preview_free", reason: "free" };
}

/**
 * Resolve the canonical user_state string used in API responses.
 *
 * @param {object} userRow - row from users table (may be null)
 * @param {string[]} ownedPackIds - pack IDs from pack_purchases
 * @returns {'free' | 'trial' | 'inside' | 'pack_owner'}
 */
export function resolveUserState(userRow, ownedPackIds = []) {
  if (userRow?.is_premium === true) return "inside";

  const trialActive =
    userRow?.premium_status === "trial" &&
    userRow?.trial_end_date &&
    new Date() < new Date(userRow.trial_end_date);

  if (trialActive) return "trial";

  if (ownedPackIds.length > 0) return "pack_owner";

  return "free";
}

/**
 * Fetch all pack IDs a device is entitled to (used by GET /premium/status).
 *
 * For Inside users: all grandfathered pack IDs.
 * For others: pack_purchases rows with status verified|restored.
 *
 * @param {string} deviceId
 * @param {object} userRow - already fetched users row (to avoid extra query)
 * @param {import('@supabase/supabase-js').SupabaseClient} [client]
 * @returns {Promise<string[]>}
 */
export async function getOwnedPackIds(deviceId, userRow, client = supabase) {
  if (userRow?.is_premium === true) {
    // All known packs were released on 2026-01-01 — always before the
    // grandfathering cutoff (2026-06-01). Return the static set directly
    // to avoid a full table scan fetching ~13K quote rows.
    return [...KNOWN_PACK_IDS];
  }

  // Non-Inside: return individual purchases.
  const { data: purchases } = await client
    .from("pack_purchases")
    .select("pack_id")
    .eq("device_id", deviceId)
    .in("status", ["verified", "restored"]);

  return (purchases ?? []).map((p) => p.pack_id);
}
