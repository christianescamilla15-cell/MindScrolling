/**
 * receiptValidation.js — Shared RevenueCat receipt validation service
 *
 * Used by both premium.js (Inside purchases + restore) and packs.js (pack purchases).
 * Fails CLOSED on network error — invalid receipts are never silently accepted.
 */

const RC_API_KEY = process.env.REVENUECAT_API_KEY;
const RC_API_URL = "https://api.revenuecat.com/v1";

// Loud warning if RC key is missing in production
if (!RC_API_KEY && process.env.NODE_ENV === "production") {
  console.error(
    "CRITICAL: REVENUECAT_API_KEY not set in production — purchase verification DISABLED"
  );
}

/**
 * Validate a purchase receipt with RevenueCat.
 *
 * @param {string} deviceId       - The device/app_user_id to check entitlements for
 * @param {string} store          - "android" | "ios"
 * @param {string|null} purchaseToken  - Google Play purchase token (android)
 * @param {string|null} transactionId - App Store transaction ID (ios)
 * @returns {{ valid: boolean, reason: string, entitlement?: object, dev?: boolean }}
 *
 * Returns { valid: true } on success.
 * Returns { valid: false, reason } on any failure, including network errors.
 * When REVENUECAT_API_KEY is absent (dev/test mode), returns valid: true with dev: true.
 */
export async function validateReceiptWithRevenueCat(
  deviceId,
  store,
  purchaseToken,
  transactionId
) {
  if (!RC_API_KEY) {
    // M-04: In production, fail closed when RC key is missing
    if (process.env.NODE_ENV === "production") {
      return { valid: false, reason: "rc_not_configured" };
    }
    // Dev mode — skip validation
    return { valid: true, reason: "rc_not_configured", dev: true };
  }

  try {
    const body = {
      app_user_id: deviceId,
      fetch_token: store === "android" ? purchaseToken : transactionId,
    };

    const response = await fetch(`${RC_API_URL}/receipts`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${RC_API_KEY}`,
        "Content-Type": "application/json",
        "X-Platform": store === "android" ? "android" : "ios",
      },
      body: JSON.stringify(body),
    });

    if (!response.ok) {
      const errBody = await response.text().catch(() => "");
      return {
        valid: false,
        reason: `rc_error_${response.status}`,
        detail: errBody.slice(0, 200),
      };
    }

    const data = await response.json();
    const subscriber = data?.subscriber;
    const entitlements = subscriber?.entitlements;

    // Check for active "premium", "inside", or "pro" entitlement
    const premiumEntitlement =
      entitlements?.premium ?? entitlements?.inside ?? entitlements?.pro;

    if (premiumEntitlement && premiumEntitlement.expires_date === null) {
      // Lifetime / non-consumable — valid
      return { valid: true, reason: "rc_verified", entitlement: premiumEntitlement };
    }

    if (
      premiumEntitlement &&
      new Date(premiumEntitlement.expires_date) > new Date()
    ) {
      return { valid: true, reason: "rc_verified", entitlement: premiumEntitlement };
    }

    // No active entitlement found — purchase may be fraudulent
    return { valid: false, reason: "no_active_entitlement" };
  } catch (_err) {
    // Fail CLOSED on network error — IAP system will re-deliver the unfinished
    // transaction on next app launch for retry.
    return { valid: false, reason: "rc_network_error" };
  }
}
