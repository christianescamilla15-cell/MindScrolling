# MindScrolling — API Contract: Block B — Pack Monetization

**Version:** 1.0
**Date:** 2026-03-18
**Author:** API Architect
**Status:** Approved — ready for implementation
**Scope document:** `SCOPE_BLOCK_B_PACK_MONETIZATION.md`
**Migration:** `backend/src/db/migrations/009_pack_monetization.sql`

---

## 0. Overview and Design Principles

This contract extends the existing REST surface with individual pack entitlements.
All new endpoints follow the patterns established in `API_CONTRACT.md`.

**Non-negotiable invariants carried forward:**
- Every error uses `{ "error": "...", "code": "..." }`.
- Every request requires `X-Device-ID: <uuid-v4>`.
- Rate limit is 60 req/min per IP (migration to per-device-ID is tracked separately).
- Server-side entitlement is the absolute source of truth (BR-05). Clients cache `/premium/status` for a maximum of 5 minutes.
- Pack swipes do NOT count against the Free 20 swipes/day limit (OQ-01, resolved).
- Grandfathering cutoff is `2026-06-01` (OQ-02, resolved). Stored in `pack_prices.released_at` on the `quotes` table.
- Preview quotes are the same for all users within a tier — not personalized (OQ-03, resolved).
- Purchasing Inside immediately supersedes trial state for all access purposes (OQ-04, resolved).

---

## 1. Entitlement Resolution Logic

The following resolution order is used by every pack-aware endpoint. It is documented here once and referenced throughout rather than repeated per endpoint.

```
FUNCTION resolve_pack_entitlement(device_id, pack_id):

  1. Load users row: is_premium, premium_status, trial_start_date, trial_end_date
  2. Load pack_purchases row WHERE device_id = ? AND pack_id = ? AND status IN ('verified','restored')

  INSIDE_USER  := is_premium = true
  PACK_OWNER   := pack_purchases row exists (regardless of Inside status)
  TRIAL_ACTIVE := premium_status = 'trial'
                  AND now() < trial_end_date
                  AND (trial quota not exhausted — checked via swipe count)
  TRIAL_EXPIRED := premium_status = 'trial' AND NOT TRIAL_ACTIVE

  GRANDFATHERED_PACK := quotes.released_at < '2026-06-01'
                        (all three current packs qualify)

  Returns one of:
    "unlocked"     — INSIDE_USER (and GRANDFATHERED_PACK) OR PACK_OWNER
    "trial"        — TRIAL_ACTIVE (preview quota = 15)
    "free"         — all others, including TRIAL_EXPIRED (preview quota = 5)
```

This logic is evaluated server-side on every request. Clients must not replicate
it; they must consume the `access_status` / `is_locked` fields returned by the API.

---

## 2. Modified Endpoints

### `GET /packs`

Returns the pack catalog with per-device access status. Requires entitlement check.

**Auth:** `X-Device-ID` required
**Rate limit:** shared 60 req/min

**Query params:**

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `lang` | `en` \| `es` | No | Content language. Default: `en` |

**Response 200:**
```json
{
  "packs": [
    {
      "id": "stoicism_deep",
      "name": "Stoicism Deep Dive",
      "description": "500 quotes from the greatest Stoic thinkers. Marcus Aurelius, Seneca, Epictetus, and more.",
      "icon": "shield",
      "color": "#14B8A6",
      "quote_count": 500,
      "is_active": true,
      "released_at": "2026-01-01T00:00:00Z",
      "is_grandfathered": true,
      "access_status": "unlocked",
      "price": {
        "usd": "2.99",
        "product_id_ios": "com.mindscrolling.pack.stoicism_deep",
        "product_id_android": "com.mindscrolling.pack.stoicism_deep"
      }
    }
  ],
  "user_state": "inside"
}
```

**Field definitions:**

| Field | Type | Description |
|-------|------|-------------|
| `access_status` | `"unlocked"` \| `"preview_only"` \| `"purchasable"` | Entitlement state for this device. See table below. |
| `is_grandfathered` | boolean | True if the pack's `released_at` < `2026-06-01`. Inside users get these for free. |
| `quote_count` | number | Actual quote count for the requested `lang`. If a pack has fewer than 500 due to translation gaps, the real count is returned (EC-04). |
| `user_state` | `"free"` \| `"trial"` \| `"inside"` \| `"pack_owner"` | Highest entitlement state of the device. `"pack_owner"` is returned when the device owns at least one pack but is not Inside. |

**`access_status` values by user state:**

| User state | `is_grandfathered = true` pack | `is_grandfathered = false` pack |
|------------|-------------------------------|----------------------------------|
| Free | `"preview_only"` | `"purchasable"` |
| Trial (active) | `"preview_only"` | `"purchasable"` |
| Inside | `"unlocked"` | `"purchasable"` |
| Pack owner (this pack) | `"unlocked"` | `"purchasable"` (other packs) |

**Error codes:**
- `401 MISSING_DEVICE_ID` — `X-Device-ID` header absent
- `500 DB_ERROR` — database read failure

**Notes:**
- Packs with `is_active = false` are excluded from the catalog but remain accessible to entitled users via `/packs/:id/feed` (EC-10).
- The `price` block always returns USD. Regional pricing is resolved client-side using the `usd` value as the canonical anchor.
- Response is safe to cache client-side for 24 hours (pack metadata). The `access_status` must be re-evaluated on every app launch against `/premium/status`.

---

### `GET /premium/status`

Modified to include `owned_packs` — the list of pack IDs this device is entitled to access, regardless of how that entitlement was acquired (Inside, individual purchase, or restore). This allows the client to gate content without an additional round-trip on launch.

**Auth:** `X-Device-ID` required
**Rate limit:** shared 60 req/min
**Client cache TTL:** 5 minutes maximum (BR-05). Must be invalidated immediately after any purchase or restore call.

**Response 200:**
```json
{
  "is_premium": false,
  "is_paid_premium": false,
  "plan": null,
  "price": "4.99",
  "currency": "USD",
  "trial_active": true,
  "trial_days_left": 5,
  "trial_expired": false,
  "owned_packs": ["stoicism_deep"],
  "user_state": "trial"
}
```

**New fields:**

| Field | Type | Description |
|-------|------|-------------|
| `owned_packs` | `string[]` | Pack IDs the device can access in full. For Inside users this contains all grandfathered pack IDs. For pack owners it contains only purchased pack IDs. Empty array `[]` for Free and Trial users with no purchases. Never null. |
| `user_state` | `"free"` \| `"trial"` \| `"inside"` \| `"pack_owner"` | Canonical state string. `"pack_owner"` applies when the device owns at least one pack but `is_paid_premium = false`. |

**`owned_packs` resolution:**
- `is_paid_premium = true`: return all pack IDs where `released_at < '2026-06-01'` (grandfathered packs). Future packs not included.
- `is_paid_premium = false`: return all `pack_id` values from `pack_purchases` where `device_id = ? AND status IN ('verified', 'restored')`.

**Backward compatibility:** All previously documented fields are preserved unchanged. `owned_packs` and `user_state` are additive.

**Error codes:**
- `401 MISSING_DEVICE_ID`
- `500 DB_ERROR`

---

### `POST /premium/restore`

Modified to also restore individual pack entitlements. The existing Inside restore behavior is preserved unchanged.

**Auth:** `X-Device-ID` required
**Rate limit:** shared 60 req/min

**Request body:**
```json
{
  "store": "ios",
  "purchase_token": null,
  "transaction_id": "70000123456789"
}
```

Same required fields as the existing contract. `purchase_token` OR `transaction_id` must be present.

**Response 200 — restored (Inside + packs):**
```json
{
  "restored": true,
  "plan": "MindScrolling Inside",
  "restored_packs": ["stoicism_deep", "zen_mindfulness"],
  "message": "Your purchases have been restored: Stoicism Deep Dive, Zen & Mindfulness."
}
```

**Response 200 — restored (Inside only, no packs):**
```json
{
  "restored": true,
  "plan": "MindScrolling Inside",
  "restored_packs": [],
  "message": "MindScrolling Inside restored."
}
```

**Response 200 — no purchases found:**
```json
{
  "restored": false,
  "restored_packs": [],
  "message": "No purchases found."
}
```

**New fields:**

| Field | Type | Description |
|-------|------|-------------|
| `restored_packs` | `string[]` | Pack IDs restored in this operation. Empty array if none. Never null. |
| `message` | string | Human-readable confirmation, already localized by the client using the returned pack IDs. |

**Restore logic for packs:**
1. Look up `pack_purchases` by `transaction_id` OR `purchase_token` across all device IDs.
2. For each matching pack purchase row found, upsert a new row in `pack_purchases` for the restoring device with `status = 'restored'`.
3. On conflict `(device_id, pack_id)`: update `status = 'restored'`, `updated_at = now()`.
4. Return `restored_packs` containing all successfully restored pack IDs.

**Audit log:** Insert one `pack_purchased` event per restored pack into `premium_audit_log` with `source = 'restore'`.

**Backward compatibility:** All previously documented behavior is preserved. `restored_packs` is a new additive field.

**Error codes:**
- `400 MISSING_FIELD` — `store` absent
- `400 INVALID_FIELD` — `store` not `ios` or `android`
- `400 MISSING_FIELD` — neither `purchase_token` nor `transaction_id` provided
- `401 MISSING_DEVICE_ID`
- `500 DB_ERROR`

---

### `POST /swipes`

Modified to accept optional `source` and `source_pack_id` fields. Existing behavior for `source = 'feed'` (the default) is unchanged.

**Auth:** `X-Device-ID` required
**Rate limit:** shared 60 req/min

**Request body:**
```json
{
  "quote_id": "uuid",
  "direction": "up",
  "category": "stoicism",
  "dwell_time_ms": 4200,
  "source": "pack",
  "source_pack_id": "stoicism_deep"
}
```

**New fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `source` | `"feed"` \| `"pack"` \| `"preview"` | No | `"feed"` | Origin of the swipe. |
| `source_pack_id` | string | Conditional | null | Required when `source` is `"pack"` or `"preview"`. |

**Behavioral differences by source:**

| `source` | Counts against Free 20/day limit | Counts against Trial 1k quota | Updates `user_preferences` weights | Updates preference vector | Recorded in `swipe_events` |
|----------|----------------------------------|-------------------------------|--------------------------------------|--------------------------|----------------------------|
| `"feed"` | Yes | Yes | Yes | Yes (if dwell >= 5s) | Yes |
| `"pack"` | No | No | Yes | Yes (if dwell >= 5s) | Yes |
| `"preview"` | No | No | No | No | Yes (for analytics only) |

**Validation:**
- If `source` is `"pack"` or `"preview"`, `source_pack_id` must be present.
- If `source` is `"pack"`, the server verifies the device is entitled to the pack before recording. If not entitled, returns `403 PACK_NOT_ENTITLED`.
- `source_pack_id` must be a valid pack ID in `('stoicism_deep', 'existentialism', 'zen_mindfulness')`.

**Response 200 (unchanged):**
```json
{ "ok": true }
```

**New error codes:**
- `400 MISSING_FIELD` — `source_pack_id` absent when `source` is `"pack"` or `"preview"`
- `400 INVALID_FIELD` — `source_pack_id` is not a known pack ID
- `403 PACK_NOT_ENTITLED` — device is not entitled to the specified pack (applies only to `source = "pack"`)
- All existing error codes are preserved.

---

## 3. New Endpoints

### `GET /packs/:id/preview`

Returns the curated preview quote set for a pack. The number of quotes returned depends on the device's entitlement state. If the device is entitled to the full pack, this endpoint redirects to the feed (see note below).

**Auth:** `X-Device-ID` required
**Rate limit:** shared 60 req/min

**Path param:** `id` — pack ID (one of `stoicism_deep`, `existentialism`, `zen_mindfulness`)

**Query params:**

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `lang` | `en` \| `es` | No | Content language. Default: `en` |

**Response 200:**
```json
{
  "pack": {
    "id": "stoicism_deep",
    "name": "Stoicism Deep Dive",
    "description": "500 quotes from the greatest Stoic thinkers.",
    "color": "#14B8A6",
    "quote_count": 500,
    "access_status": "preview_only",
    "preview_quota": 5,
    "quotes_remaining_after_preview": 495
  },
  "quotes": [
    {
      "id": "uuid",
      "text": "You have power over your mind, not outside events.",
      "author": "Marcus Aurelius",
      "category": "stoicism",
      "lang": "en",
      "swipe_dir": "up",
      "pack_preview_rank": 1,
      "is_locked": false
    }
  ],
  "is_preview_complete": false,
  "paywall": null
}
```

**Response 200 — when preview quota is exhausted (all quotes returned plus paywall payload):**
```json
{
  "pack": {
    "id": "stoicism_deep",
    "name": "Stoicism Deep Dive",
    "description": "500 quotes from the greatest Stoic thinkers.",
    "color": "#14B8A6",
    "quote_count": 500,
    "access_status": "preview_only",
    "preview_quota": 5,
    "quotes_remaining_after_preview": 495
  },
  "quotes": [...],
  "is_preview_complete": true,
  "paywall": {
    "type": "hard",
    "user_state": "free",
    "pack_price_usd": "2.99",
    "product_id_ios": "com.mindscrolling.pack.stoicism_deep",
    "product_id_android": "com.mindscrolling.pack.stoicism_deep",
    "cta_pack": "Get Stoicism Deep Dive — $2.99",
    "cta_inside": "Or unlock everything with Inside — $4.99",
    "inside_value_prop": "3 packs ($8.97 value) + premium features — $4.99"
  }
}
```

**Response 200 — entitled user (Inside or pack owner):**

When the device is entitled to the full pack, the preview endpoint returns the entitlement redirect signal instead of preview quotes. The client must navigate to `GET /packs/:id/feed`.

```json
{
  "pack": {
    "id": "stoicism_deep",
    "name": "Stoicism Deep Dive",
    "description": "500 quotes from the greatest Stoic thinkers.",
    "color": "#14B8A6",
    "quote_count": 500,
    "access_status": "unlocked",
    "preview_quota": null,
    "quotes_remaining_after_preview": null
  },
  "quotes": [],
  "is_preview_complete": false,
  "redirect_to_feed": true,
  "paywall": null
}
```

**Field definitions:**

| Field | Type | Description |
|-------|------|-------------|
| `pack.preview_quota` | `5` \| `15` \| `null` | Maximum preview quotes for this user's state. `null` for entitled users. |
| `pack.quotes_remaining_after_preview` | number \| null | `quote_count - preview_quota`. Used for paywall copy ("485 more quotes"). `null` for entitled users. |
| `quotes[].is_locked` | boolean | Always `false` in this response — all returned quotes are readable. Lock state is communicated via `is_preview_complete` and the `paywall` block. |
| `quotes[].pack_preview_rank` | number | Order rank (1–15). Free users receive ranks 1–5, Trial users receive ranks 1–15. |
| `is_preview_complete` | boolean | True when the full quota has been returned and a paywall should be displayed. |
| `redirect_to_feed` | boolean | Present and `true` only for entitled users. Client uses this to navigate to the feed. |
| `paywall` | object \| null | Non-null only when `is_preview_complete = true`. Contains all data needed for the hard paywall screen. |
| `paywall.type` | `"hard"` | Always `"hard"` for this endpoint (no soft cards on preview screens). |
| `paywall.inside_value_prop` | string | Base value prop. Client may override with owned-pack variant text (US-B08) using `owned_packs` from `/premium/status`. |

**Preview quota by entitlement state:**

| Entitlement | `preview_quota` | Quotes returned |
|-------------|-----------------|-----------------|
| `unlocked` (Inside or pack owner) | `null` | 0 (redirect to feed) |
| `trial` (active) | `15` | ranks 1–15 |
| `free` or expired trial | `5` | ranks 1–5 |

**Quote selection query (server-side):**
```sql
SELECT id, text, author, category, lang, swipe_dir, pack_preview_rank
FROM quotes
WHERE pack_name = :pack_id
  AND lang = :lang
  AND is_pack_preview = true
  AND pack_preview_rank <= :quota   -- 5 or 15
ORDER BY pack_preview_rank ASC
```

**If the pack has fewer than 5 curated preview quotes in the requested language** (EC-04), the endpoint returns what exists and sets `is_preview_complete = true` immediately, with `paywall` populated. It does NOT fall back to non-preview quotes.

**Analytics:** On each call, emit `pack_preview_started` to `premium_audit_log` with `{ device_id, pack_id, user_state, preview_quota, lang }`.

**Error codes:**
- `401 MISSING_DEVICE_ID`
- `404 PACK_NOT_FOUND` — `id` is not a known pack
- `503 PREVIEW_UNAVAILABLE` — pack has zero curated preview quotes in the requested language. Body: `{ "error": "No preview available in this language", "code": "PREVIEW_UNAVAILABLE" }`
- `500 DB_ERROR`

---

### `GET /packs/:id/feed`

Returns a paginated feed of all pack quotes for entitled users. Only accessible to Inside users (grandfathered packs) and pack owners. Applies adaptive ordering scoped to the pack's quote pool (US-B04, BR-07).

**Auth:** `X-Device-ID` required
**Rate limit:** shared 60 req/min

**Path param:** `id` — pack ID

**Query params:**

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `lang` | `en` \| `es` | No | Content language. Default: `en` |
| `limit` | number | No | Quotes per page. Default: `20`. Max: `50`. |
| `cursor` | UUID string | No | Cursor from previous response (`next_cursor`). Omit for first page. |

**Entitlement check:** Before returning quotes, the server runs the entitlement resolution defined in Section 1. If the result is not `"unlocked"`, the endpoint returns `403 PACK_NOT_ENTITLED`.

**Response 200:**
```json
{
  "pack": {
    "id": "stoicism_deep",
    "name": "Stoicism Deep Dive",
    "color": "#14B8A6",
    "quote_count": 500,
    "access_reason": "pack_owner"
  },
  "data": [
    {
      "id": "uuid",
      "text": "The obstacle is the way.",
      "author": "Marcus Aurelius",
      "category": "stoicism",
      "lang": "en",
      "swipe_dir": "up",
      "pack_name": "stoicism_deep",
      "is_premium": true
    }
  ],
  "next_cursor": "uuid-of-last-item",
  "has_more": true,
  "total_in_lang": 500
}
```

**Field definitions:**

| Field | Type | Description |
|-------|------|-------------|
| `pack.access_reason` | `"inside"` \| `"pack_owner"` \| `"grandfathered"` | Why this device has access. `"grandfathered"` is used when `is_paid_premium = true` and the pack predates the cutoff. |
| `total_in_lang` | number | Total quotes available for this pack in the requested language. May be less than 500 if translations are incomplete (EC-04). |
| `next_cursor` | UUID \| null | UUID of the last quote in this batch. `null` on the last page. |
| `has_more` | boolean | False when this is the final page. |

**Pagination:** Cursor-based using `quotes.id` as the cursor value. First page: omit cursor. Subsequent pages: pass `cursor = last_id_from_previous_response`.

**Ordering:** Adaptive scoring identical to the main feed algorithm (`ARCHITECTURE.md` section 8), scoped to `WHERE pack_name = :id AND lang = :lang`. The `seen_quotes` table is NOT used for pack feeds — users may re-encounter pack quotes. Pack feed positions are not recorded to `seen_quotes`.

**Swipe events from this feed:** Clients must set `source = "pack"` and `source_pack_id = :id` when posting swipe events from this feed. The server validates this on `POST /swipes`.

**Analytics:** On first-page request (cursor absent), emit `pack_feed_entered` to `premium_audit_log` with `{ device_id, pack_id, access_reason, lang }`.

**Error codes:**
- `401 MISSING_DEVICE_ID`
- `403 PACK_NOT_ENTITLED` — device is not entitled to this pack. Body: `{ "error": "Purchase required to access this pack", "code": "PACK_NOT_ENTITLED" }`
- `404 PACK_NOT_FOUND` — `id` is not a known pack
- `400 INVALID_FIELD` — `limit` out of range (1–50)
- `500 DB_ERROR`

---

### `POST /packs/:id/purchase/verify`

Verifies a receipt from App Store or Play Store for an individual pack purchase. Records the entitlement in `pack_purchases`. This endpoint is the backend gate for all individual pack purchases (BR-05).

**Auth:** `X-Device-ID` required
**Rate limit:** 10 req/min per device (stricter than global — purchase endpoint abuse vector). Implemented as a separate Fastify rate-limit scope.

**Path param:** `id` — pack ID

**Request body:**
```json
{
  "store": "android",
  "product_id": "com.mindscrolling.pack.stoicism_deep",
  "purchase_token": "abcdef123456...",
  "transaction_id": null,
  "amount": 2.99,
  "currency": "USD"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `store` | `"ios"` \| `"android"` | Yes | Payment platform. |
| `product_id` | string | Yes | Must match the canonical product ID for this pack and store in `pack_prices`. |
| `purchase_token` | string \| null | Conditional | Required for `store = "android"`. |
| `transaction_id` | string \| null | Conditional | Required for `store = "ios"`. |
| `amount` | number | Yes | Amount charged. Must be a non-negative number. Server validates against canonical price; mismatches are logged but do NOT fail the request (regional pricing variance). |
| `currency` | string | Yes | ISO 4217 3-letter code. |

**Server-side validation steps:**
1. Verify `id` is a known pack ID.
2. Verify `product_id` matches `pack_prices.product_id_ios` (ios) or `pack_prices.product_id_android` (android) for this `pack_id`.
3. Verify either `purchase_token` (android) or `transaction_id` (ios) is present.
4. Upsert `users` row for `device_id` (create if first request).
5. Check for duplicate: if a `pack_purchases` row already exists for `(device_id, pack_id)` with `status = 'verified'`, return `200` with `{ "status": "already_owned" }` (idempotent — EC-09).
6. Insert `pack_purchases` row (or upsert on `(device_id, pack_id)` conflict).
7. Emit `pack_purchased` event to `premium_audit_log`.

**NOTE on receipt verification:** This endpoint currently trusts the client-provided receipt fields (matching the existing pattern in `POST /premium/purchase/verify`). Full server-side receipt validation against Apple/Google servers is tracked under S7-07 and is a prerequisite for production launch. The `product_id` validation against `pack_prices` provides partial protection.

**Response 201 — new purchase recorded:**
```json
{
  "status": "verified",
  "pack_id": "stoicism_deep",
  "pack_name": "Stoicism Deep Dive",
  "access_granted": true,
  "message": "Stoicism Deep Dive unlocked. 500 quotes ready."
}
```

**Response 200 — already owned (idempotent):**
```json
{
  "status": "already_owned",
  "pack_id": "stoicism_deep",
  "pack_name": "Stoicism Deep Dive",
  "access_granted": true
}
```

**Error codes:**
- `400 MISSING_FIELD` — any required field absent
- `400 INVALID_FIELD` — `store` not `ios` or `android`; or `product_id` does not match canonical value for this pack + store
- `400 INVALID_FIELD` — `purchase_token` required for android but absent; `transaction_id` required for ios but absent
- `401 MISSING_DEVICE_ID`
- `404 PACK_NOT_FOUND` — `:id` is not a known active pack
- `429 RATE_LIMITED` — exceeded 10 req/min purchase limit for this device. Body: `{ "error": "Too many purchase attempts. Retry after 60 seconds.", "code": "RATE_LIMITED" }`
- `500 DB_ERROR`

**EC-05 client retry protocol:** If this endpoint returns `500 DB_ERROR`, the client must retry up to 3 times with exponential backoff (1s, 2s, 4s). If all retries fail, the client displays "Purchase recorded — restart the app to activate." The RevenueCat receipt is retained client-side for the next restore attempt.

---

## 4. Error Code Registry (Block B additions)

The following error codes are added to the global error registry in `API_CONTRACT.md`:

| HTTP | Code | Meaning |
|------|------|---------|
| 403 | `PACK_NOT_ENTITLED` | Device does not have entitlement for this pack |
| 404 | `PACK_NOT_FOUND` | Pack ID does not exist in the catalog |
| 503 | `PREVIEW_UNAVAILABLE` | No curated preview quotes exist in the requested language |

All existing error codes from `API_CONTRACT.md` remain valid and unchanged.

---

## 5. Pack ID Reference

| Pack ID | EN Name | ES Name | Color |
|---------|---------|---------|-------|
| `stoicism_deep` | Stoicism Deep Dive | Estoicismo Profundo | `#14B8A6` |
| `existentialism` | Existentialism | Existencialismo | `#A78BFA` |
| `zen_mindfulness` | Zen & Mindfulness | Zen y Mindfulness | `#22C55E` |

**Note:** The current implementation in `packs.js` uses `zen_mindfulness` as the key in the `PACK_META` object. The scope document uses both `zen` and `zen_mindfulness` in different places. The canonical ID is `zen_mindfulness` (matches the `pack_name` column values in the database and the `pack_prices` seed in migration 009). The implementation must align to this.

---

## 6. Security Considerations

### Entitlement bypass prevention

The primary entitlement gate is server-side, evaluated on every request to `/packs/:id/feed` and `/packs/:id/purchase/verify`. The following measures are layered:

1. **Service role only.** All Supabase queries from the Fastify backend use the service role key. Clients cannot query `pack_purchases` or `users` directly via the Supabase anon key. RLS on `pack_purchases` enforces row-level device isolation as a defense-in-depth measure.

2. **`product_id` validation.** The `POST /packs/:id/purchase/verify` endpoint validates that the provided `product_id` matches the canonical value in `pack_prices` for the given `pack_id` and `store`. This prevents a client from claiming purchase of pack B with a receipt from pack A.

3. **No client-side entitlement decisions.** The `access_status` field returned by `GET /packs` and `GET /packs/:id/preview` is informational and must not be used by the client to unlock content. All content access flows through server endpoints that independently verify entitlement.

4. **Idempotent upsert on conflict.** The `UNIQUE (device_id, pack_id)` constraint on `pack_purchases` prevents any race condition from creating duplicate entitlement rows (EC-09). The upsert is the only write path.

5. **Pack swipe entitlement check.** `POST /swipes` with `source = "pack"` validates entitlement server-side before recording. A client that spoofs a pack swipe without entitlement receives `403 PACK_NOT_ENTITLED` and the swipe is not recorded.

### Rate limiting on purchase endpoints

`POST /packs/:id/purchase/verify` is subject to a per-device rate limit of 10 requests per minute, separate from the global 60 req/min IP limit. This limit is applied via a dedicated Fastify rate-limit scope keyed by `X-Device-ID`. This prevents brute-force product_id enumeration and receipt replay loops.

`POST /premium/restore` retains the existing global rate limit. No stricter limit is applied because restore is a legitimate user flow with high retry intent.

---

## 7. i18n Key Requirements

The following keys must be added to `strings_en.dart` and `strings_es.dart` before UI implementation (US-B10):

| Key | EN value | ES value |
|-----|----------|----------|
| `packIncludedInInside` | "Included in Inside" | "Incluido en Inside" |
| `packGetFor` | "Get for $2.99" | "Obtener por $2.99" |
| `packPaywallPrimary` | "Get {packName} — $2.99" | "Obtener {packName} — $2.99" |
| `packPaywallSecondaryInside` | "Or unlock everything with Inside — $4.99" | "O desbloquea todo con Inside — $4.99" |
| `packTrialPaywallPrimary` | "485 more quotes — $2.99" | "485 frases más — $2.99" |
| `packTrialPaywallSecondary` | "Or get all 3 packs with Inside — $4.99" | "O consigue los 3 packs con Inside — $4.99" |
| `packConfirmationUnlocked` | "{packName} unlocked. {count} quotes ready." | "{packName} desbloqueado. {count} frases listas." |
| `packNewNotIncluded` | "New — not included in existing Inside" | "Nuevo — no incluido en Inside existente" |
| `insideValueProp` | "3 packs ($8.97 value) + premium features — $4.99" | "3 packs (valor $8.97) + funciones premium — $4.99" |
| `insideValuePropOwn1` | "You already own 1 pack. Get the other 2 + premium features for $4.99." | "Ya tienes 1 pack. Obtén los otros 2 + funciones premium por $4.99." |
| `insideValuePropOwn2` | "You own 2 packs. Complete your library + premium features for $4.99." | "Tienes 2 packs. Completa tu biblioteca + funciones premium por $4.99." |

---

## 8. Analytics Events Reference

All events are written to `premium_audit_log`. The `metadata` JSONB column carries event-specific fields. Events are fire-and-forget — they must never block the API response.

| Event type | Trigger endpoint | Required metadata fields |
|------------|-----------------|--------------------------|
| `pack_catalog_viewed` | `GET /packs` | `user_state`, `lang`, `pack_count` |
| `pack_preview_started` | `GET /packs/:id/preview` | `pack_id`, `user_state`, `preview_quota`, `lang` |
| `pack_preview_completed` | `GET /packs/:id/preview` (when `is_preview_complete = true`) | `pack_id`, `user_state` |
| `pack_paywall_shown` | `GET /packs/:id/preview` (when `paywall != null`) | `pack_id`, `user_state`, `cta_shown: "both"` |
| `pack_purchased` | `POST /packs/:id/purchase/verify` (201) | `pack_id`, `store`, `amount`, `currency`, `product_id` |
| `pack_feed_entered` | `GET /packs/:id/feed` (cursor absent) | `pack_id`, `access_reason`, `lang` |

Note: `pack_purchase_started` is a client-side event emitted when the user taps a purchase CTA. It is not emitted by the backend. The client must POST this via a separate analytics endpoint if one exists, or log it locally.

---

## 9. DB Migration Summary

Migration file: `backend/src/db/migrations/009_pack_monetization.sql`

| Change | Table | Details |
|--------|-------|---------|
| New table | `pack_purchases` | Entitlement records per `(device_id, pack_id)`. UNIQUE constraint prevents duplicates. |
| New table | `pack_prices` | Canonical prices per `(pack_id, currency)`. Seeded with USD, EUR, CAD, BRL for all 3 packs. |
| New columns | `quotes` | `is_pack_preview BOOLEAN`, `pack_preview_rank INT (1-15)`, `released_at TIMESTAMPTZ` |
| New columns | `swipe_events` | `source VARCHAR(10) DEFAULT 'feed'`, `source_pack_id VARCHAR(50)` |
| New indexes | Multiple | See migration file for full list |
| RLS | `pack_purchases` | Row-level isolation by `device_id` |
| Backfill | `quotes` | `released_at = '2026-01-01'` for existing 3 packs |

---

## 10. Open Items and Pre-Launch Gates

The following items are tracked outside this contract and must be resolved before production launch:

| ID | Item | Owner | Blocking |
|----|------|-------|---------|
| S7-07 | Full server-side receipt validation against Apple/Google APIs | Backend | Yes — purchase flow is trusted-client-only until this ships |
| S8-14 | iOS App Store submission | Platform | Yes for iOS |
| OQ-05 | Regional pricing sign-off (MXN, COP, ARS tiers) | Product Owner | Yes for regional launch |
| Content | 15 curated preview quotes per pack per language (90 total) designated via `pack_preview_rank` | Content/Admin | Yes for QA sign-off on preview flow |
