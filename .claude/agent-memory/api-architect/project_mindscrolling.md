---
name: MindScrolling project state
description: Core context about the MindScrolling anti-doom-scrolling app — current state, stack, and backend MVP requirements
type: project
---

MindScrolling is an anti-doom-scrolling app that surfaces philosophical quotes via a swipe-card UX (4 directions mapped to categories: philosophy=up, stoicism=left, discipline=right, reflection=down).

**Why:** Replace mindless social scrolling with intentional philosophical reflection. Monetization via optional donations (external link only).

**Current state (as of 2026-03-15):**
- Frontend MVP functional in MindScroll_MVP.jsx (React + CSS-in-JS)
- All data is hardcoded (15 quotes, 4 categories)
- No backend exists yet
- Features in MVP: swipe 4 directions, like (double-tap or button), vault (bookmark), streak counter, category stats bar, toast notifications, particle burst animation

**Categories and their swipe directions:**
- philosophy → swipe up, color #F59E0B
- stoicism → swipe left, color #14B8A6
- discipline → swipe right, color #F97316
- reflection → swipe down, color #A78BFA

**Backend MVP requirements:**
- Infinite scroll of philosophical quotes (paginated)
- Multilanguage: at minimum ES and EN
- Recommendation based on likes (simple: boost categories with more likes)
- Vault persistence (user's saved quotes)
- Anonymous auth via device_id (no complex auth)
- Donations: external link only, no backend logic needed
- Constraints: low cost, simple, no over-engineering

**Agreed backend architecture (2026-03-15):**
- Stack: Node.js + Fastify, PostgreSQL (Supabase free tier), deployed on Railway or Render
- Auth: anonymous device_id passed as header, no JWT needed for MVP
- Recommendation: weighted random by category like-ratio stored in user_preferences table
- Multilanguage: lang column on quotes table + lang query param on feed endpoint

**How to apply:** When designing or implementing backend features, respect the simplicity constraint. No auth middleware, no complex pipelines. Prioritize fast time-to-working over perfect architecture.
