# MindScrolling — API Contract

**Version:** Sprint 5
**Base URL:** Configured via `API_BASE_URL` env variable (default: `http://localhost:3000`)
**Auth:** All requests must include the header `X-Device-ID: <uuid-v4>`

---

## Error Envelope

All errors use a consistent JSON structure:

```json
{
  "error": "Human-readable description",
  "code": "MACHINE_READABLE_CODE"
}
```

| HTTP | Code | Description |
|---|---|---|
| 400 | `INVALID_BODY` | Body failed schema validation |
| 400 | `MISSING_FIELD` | Required field absent |
| 400 | `INVALID_DIRECTION` | `direction` not in `{up, down, left, right}` |
| 401 | `MISSING_DEVICE_ID` | `X-Device-ID` header absent or empty |
| 404 | `NOT_FOUND` | Resource does not exist |
| 409 | `ALREADY_EXISTS` | Duplicate resource |
| 429 | `RATE_LIMITED` | Exceeded 60 req/min |
| 500 | `INTERNAL_ERROR` | Unexpected server error |

---

## Endpoints

### Health

#### `GET /health`
Returns server status.

**Response 200:**
```json
{ "status": "ok", "ts": "2026-03-15T12:00:00.000Z" }
```

---

### Quotes

#### `GET /quotes/feed`
Returns a paginated adaptive quote feed for the device.

**Query params:**

| Param | Type | Required | Description |
|---|---|---|---|
| `lang` | `en` \| `es` | No | Content language. Default: `en` |
| `limit` | number | No | Items per page. Default: `20` |
| `cursor` | UUID string | No | Cursor from previous response |

**Response 200:**
```json
{
  "data": [
    {
      "id": "uuid",
      "text": "The obstacle is the way.",
      "author": "Marcus Aurelius",
      "category": "stoicism",
      "lang": "en",
      "swipe_dir": "up",
      "pack_name": "free",
      "is_premium": false
    }
  ],
  "next_cursor": "uuid-of-last-item",
  "has_more": true
}
```

**Notes:**
- Excludes quotes already in `seen_quotes` for this device.
- Excludes `is_premium = true` quotes for free users.
- Returns shuffled results from the adaptive scoring algorithm.
- When all quotes have been seen, resets the seen list and restarts.

---

#### `POST /quotes/:id/like`
Toggles like/unlike for a quote.

**Path param:** `id` — quote UUID

**Request body:**
```json
{ "action": "like" }
```
| `action` | Effect |
|---|---|
| `"like"` | Record like, increment like_count |
| `"unlike"` | Remove like, decrement like_count |

**Response 200:**
```json
{ "ok": true }
```

---

### Vault

#### `GET /vault`
Returns all quotes saved by this device.

**Response 200:**
```json
{
  "data": [{ ...QuoteModel }]
}
```

---

#### `POST /vault`
Saves a quote to the vault.

**Request body:**
```json
{ "quote_id": "uuid" }
```

**Response 200 (new save):**
```json
{ "ok": true }
```

**Response 200 (already saved):**
```json
{ "ok": true, "status": "already_saved" }
```

---

#### `DELETE /vault/:id`
Removes a quote from the vault.

**Path param:** `id` — quote UUID

**Response 200:**
```json
{ "ok": true }
```

**Response 404:**
```json
{ "error": "Quote not in vault", "code": "NOT_FOUND" }
```

---

### Stats

#### `GET /stats`
Returns streak and reflection counts for the device.

**Response 200:**
```json
{
  "streak": 7,
  "total_reflections": 142,
  "category_counts": {
    "stoicism": 38,
    "philosophy": 31,
    "discipline": 40,
    "reflection": 33
  }
}
```

---

### Profile

#### `POST /profile`
Saves or updates the onboarding profile.

**Request body:**
```json
{
  "age_range": "25-34",
  "interest": "stoicism",
  "goal": "discipline",
  "preferred_language": "en"
}
```

| Field | Allowed values |
|---|---|
| `age_range` | `18-24`, `25-34`, `35-44`, `45+` |
| `interest` | `philosophy`, `stoicism`, `personal_growth`, `mindfulness`, `curiosity` |
| `goal` | `calm_mind`, `discipline`, `meaning`, `emotional_clarity` |
| `preferred_language` | `en`, `es` |

**Response 200:**
```json
{ "ok": true }
```

---

#### `GET /profile`
Returns the profile for this device, or `null` if none exists.

**Response 200:**
```json
{
  "device_id": "uuid",
  "age_range": "25-34",
  "interest": "stoicism",
  "goal": "discipline",
  "preferred_language": "en",
  "created_at": "2026-03-15T10:00:00Z",
  "updated_at": "2026-03-15T10:00:00Z"
}
```

**Response 200 (no profile):**
```json
null
```

---

### Swipes

#### `POST /swipes`
Records a swipe event. Fire-and-forget — client does not need to await a meaningful response.

**Request body:**
```json
{
  "quote_id": "uuid",
  "direction": "up",
  "category": "stoicism",
  "dwell_time_ms": 4200
}
```

| `direction` | Category |
|---|---|
| `"up"` | stoicism |
| `"right"` | discipline |
| `"left"` | reflection |
| `"down"` | philosophy |

**Response 200:**
```json
{ "ok": true }
```

---

### Challenges

#### `GET /challenges/today`
Returns today's daily challenge and the device's current progress.

**Response 200:**
```json
{
  "challenge": {
    "id": "uuid",
    "code": "stoic_morning_reflection",
    "title": "Morning Stoic",
    "description": "Before checking your phone, recall one thing you are grateful for.",
    "active_date": "2026-03-15"
  },
  "progress": {
    "progress": 0,
    "completed": false
  }
}
```

**Notes:**
- If no challenge is scheduled for today, returns a hardcoded default challenge.
- `progress` is `null` if the device has not interacted with this challenge yet.

---

#### `POST /challenges/:id/progress`
Updates progress on a challenge.

**Path param:** `id` — challenge UUID

**Request body:**
```json
{
  "progress": 1,
  "completed": true
}
```

**Response 200:**
```json
{ "ok": true }
```

---

### Philosophy Map

#### `GET /map`
Returns normalized category scores (0–100) and the latest snapshot for comparison.

**Response 200:**
```json
{
  "current": {
    "wisdom_score": 72,
    "discipline_score": 45,
    "reflection_score": 58,
    "philosophy_score": 31
  },
  "snapshot": {
    "wisdom_score": 60,
    "discipline_score": 30,
    "reflection_score": 50,
    "philosophy_score": 20,
    "created_at": "2026-03-08T00:00:00Z"
  }
}
```

**Notes:**
- `snapshot` is `null` if no snapshot has been saved yet.
- Scores are normalized 0–100 relative to the device's own max.

---

#### `POST /map/snapshot`
Saves current scores as a timestamped snapshot for future evolution comparison.

**Response 200:**
```json
{ "ok": true }
```

---

### Premium

#### `GET /premium/status`
Returns premium status for this device.

**Response 200:**
```json
{ "is_premium": false }
```

---

#### `POST /premium/unlock`
Unlocks premium. Idempotent — safe to call multiple times.

**Request body:**
```json
{
  "purchase_type": "premium_unlock",
  "amount": 2.99,
  "currency": "USD"
}
```

**Response 200:**
```json
{ "ok": true, "is_premium": true }
```

---

## Rate Limiting

All endpoints share a global rate limit of **60 requests per minute per IP address**.

Response when limit is exceeded:

**HTTP 429:**
```json
{
  "error": "Too many requests. Retry after 60 seconds.",
  "code": "RATE_LIMITED"
}
```

---

## Swipe Direction Reference

| Direction | Category | Theme |
|---|---|---|
| `up` | stoicism | Resilience, virtue, inner strength |
| `right` | discipline | Growth, habits, achievement |
| `left` | reflection | Life, emotion, meaning |
| `down` | philosophy | Existential, ideas, truth |
