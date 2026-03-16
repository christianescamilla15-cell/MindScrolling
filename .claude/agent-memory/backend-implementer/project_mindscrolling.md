---
name: MindScrolling project state
description: Architecture decisions, MVP state, and backend roadmap for MindScrolling
type: project
---

MindScrolling is a swipeable quote/reflection app. The frontend is a single React component at `MindScroll_MVP.jsx`.

**Current MVP state:**
- 15 hardcoded quotes in JSX, no persistence, no backend
- streak and reflections are initialized with fake values (3 and 12) — placeholder data
- Share button exists in UI but has no handler

**Agreed architecture (from API Architect):**
- Backend: Node.js + Fastify + PostgreSQL via Supabase
- Endpoints: GET /quotes/feed, POST /quotes/:id/like, GET|POST|DELETE /vault, GET /stats
- Anonymous device ID (no auth required)
- Multilanguage via `lang` column + query param

**Why:** The next step after frontend prep is building the Fastify backend. Frontend changes are intentionally minimal — only wire up localStorage, language detection, share, and a stub fetchQuotes() to avoid rework when the real API lands.

**How to apply:** Keep all backend changes additive. Do not break existing UI. fetchQuotes() stub must match the signature the real API will use so the caller never needs to change.
