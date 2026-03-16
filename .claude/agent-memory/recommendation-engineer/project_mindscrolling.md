---
name: MindScrolling - Recommendation Engineer context
description: Feed algorithm v2 full state, signal model, Voyage AI configuration, EMA vectors, pending deployment steps
type: project
---

## Algorithm Version: v2 (Hybrid AI + Behavioural)

Implemented in `backend/src/routes/quotes.js` (fully rewritten Sprint 5).

## Signal Model

| Signal | Weight | Column | Event |
|---|---|---|---|
| Vault save | ×5 | vault_count | POST /vault |
| Like | ×3 | like_count | POST /quotes/:id/like |
| Swipe | ×1 | swipe_count | POST /swipes |
| Skip (dwell < 500ms) | −2 | skip_count | POST /swipes (dwellMs < 500) |
| Dwell time | avg/4000 → 0-1 | total_dwell_ms | POST /swipes |

## EMA Preference Vector

Model: Voyage AI `voyage-3-lite` (512 dimensions)
Table: `user_preference_vectors`
Formula: `v_new = L2_normalize((1-α) × v_current + α × v_quote)`
α values: vault=0.25 | like=0.20 | dwell(≥5s)=0.10
Updates: fire-and-forget via `updatePreferenceVector(...).catch(() => {})`

## Scoring Formulas

**Hybrid (returning users with vector):**
```
score = semantic_similarity × 0.45
      + normalised_affinity × 0.30
      + dwell_signal        × 0.10
      + random()            × 0.10
      + challenge_boost     × 0.05
      − author_penalty (flat −0.15)
```

**Behavioural (new users, no vector):**
```
score = normalised_affinity × 0.50
      + dwell_signal        × 0.20
      + random()            × 0.15
      + challenge_boost     × 0.10
      − author_penalty (flat −0.15)
```

## Diversity Cap

No category fills >60% of a batch. Overflow items backfill.

## Claude Insights

Model: `claude-haiku-4-5-20251001`
Cache: 24h in `ai_insights` table
Route: `GET /insights/weekly`
Service: `backend/src/services/insights.js`

## Deployment Status (as of 2026-03-16)

- ✅ `embeddings.js` service created
- ✅ `insights.js` service created
- ✅ `quotes.js` rewritten with hybrid mode
- ✅ `likes.js` fires vector update on like
- ✅ `swipes.js` fires vector update on long dwell + skip detection
- ✅ `vault.js` fires vector update on vault
- ✅ `004_ai_feed.sql` migration written
- ❌ `004_ai_feed.sql` NOT yet run in Supabase (requires pgvector extension)
- ❌ `npm run embed-quotes` NOT yet run (requires migration first)
- ❌ `@anthropic-ai/sdk` NOT yet installed (`npm install` needed)

**Why:** Full algorithm v2 implementation during Sprint 5.
**How to apply:** Reference before any algorithm change to understand current state and deployment blockers.
