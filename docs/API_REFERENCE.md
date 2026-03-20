# MindScrolling API Reference

> Auto-generated on 2026-03-20

Base URL: `https://mindscrolling.onrender.com/api`

## Endpoints

### Admin (`/api/admin`)

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/api/admin/codes/create` | Create/update codes/create |
| `POST` | `/api/admin/codes/revoke` | Create/update codes/revoke |
| `GET` | `/api/admin/codes/list` | Retrieve codes/list |
| `GET` | `/api/admin/audit` | Retrieve audit |

### Analytics (`/api/analytics`)

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/api/analytics/event` | Create/update event |

### Authors (`/api/authors`)

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/authors` | Retrieve resource |
| `GET` | `/api/authors/:slug` | Retrieve {id} |

### Challenges (`/api/challenges`)

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/challenges/today` | Retrieve today |
| `POST` | `/api/challenges/:id/progress` | Create/update {id}/progress |

### Device Lock (`/api/device-lock`)

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/api/device-lock/register` | Create/update register |

### Insights (`/api/insights`)

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/insights/weekly` | Retrieve weekly |

### Likes (`/api/likes`)

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/api/likes/:id/like` | POST /quotes/:id/like  body: { action: "like" | "unlike" } |

### Map (`/api/map`)

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/map` | Retrieve resource |
| `POST` | `/api/map/snapshot` | Create/update snapshot |

### Mind Profile (`/api/mind-profile`)

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/mind-profile/daily` | Retrieve daily |

### Packs (`/api/packs`)

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/packs` | ── GET /packs ───────────────────────────────────────────────────────────── |
| `GET` | `/api/packs/:id/preview` | Retrieve {id}/preview |
| `GET` | `/api/packs/:id/feed` | ── GET /packs/:id/feed ──────────────────────────────────────────────────── |
| `POST` | `/api/packs/:id/purchase/verify` | Create/update {id}/purchase/verify |

### Premium (`/api/premium`)

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/premium/status` | Retrieve status |
| `POST` | `/api/premium/start-trial` | ── POST /premium/start-trial ───────────────────────────────────────────── |
| `POST` | `/api/premium/purchase/verify` | Create/update purchase/verify |
| `POST` | `/api/premium/restore` | Create/update restore |
| `POST` | `/api/premium/unlock` | ── POST /premium/unlock (legacy — backward compatibility) ──────────────── |
| `POST` | `/api/premium/redeem` | ── POST /premium/redeem ────────────────────────────────────────────────── |

### Profile (`/api/profile`)

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/api/profile` | Create/update resource |
| `GET` | `/api/profile` | Retrieve resource |

### Quotes (`/api/quotes`)

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/quotes/feed` | Retrieve feed |

### Stats (`/api/stats`)

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/stats` | GET /stats — user streak + reflections + category distribution |

### Swipes (`/api/swipes`)

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/api/swipes` | Create/update resource |

### Vault (`/api/vault`)

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/vault` | GET /vault — list saved quotes |
| `POST` | `/api/vault` | POST /vault — save a quote |
| `DELETE` | `/api/vault/:id` | DELETE /vault/:id — remove a quote |

### Webhooks (`/api/webhooks`)

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/api/webhooks/revenuecat` | www.revenuecat.com/docs/webhooks#sample-events |

## Authentication

All endpoints require `x-device-id` header (UUID v4).
Premium endpoints additionally check entitlement status.

## Rate Limits

| Endpoint | Limit |
|----------|-------|
| POST /api/swipes | 120/min |
| GET /api/quotes/feed | 60/min |
| POST /api/insights/weekly | 10/min |
| All others | 100/min |
