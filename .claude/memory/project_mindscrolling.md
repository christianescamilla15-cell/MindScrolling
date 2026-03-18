---
name: MindScrolling project context
description: Estado post-Sprint 7 completo — Bloques A/B/C/D implementados, DB con monetización de packs, preview curation, autores table, swipe navigation.
type: project
---

## Stack
- Backend: Node.js (ESM) + Fastify 4.x + Supabase (PostgreSQL + pgvector)
- Mobile: Flutter (iOS + Android) con Riverpod 2.x + GoRouter
- Embeddings: Voyage AI `voyage-3-lite` (512 dims)
- AI Insights: Anthropic Claude `claude-haiku-4-5-20251001`
- Auth: X-Device-ID header (UUID anónimo)
- Deployment: Railway (backend), GitHub Pages (tester form)
- API Base URL (dev): http://192.168.100.7:3000 (dispositivo físico, NO emulador)
- Repo: https://github.com/christianescamilla15-cell/MindScrolling

## Estado post-Sprint 7 (2026-03-18) — Todos los Bloques A/B/C/D completados

### Commits del sprint (pusheados a origin/main)
- `82b9c6f` — feat: Bloque B pack monetization
- `dfd6e0c` — feat: Bloque C + D swipe navigation y reflection card fixes
- `1dc3f4a` — feat: Bloque A content distribution, authors table, preview curation

### Bloque A — Content & Data ✅
- **assign_pack_quotes.sql**: distribuye 500 EN + 500 ES por pack
  - existentialism: EN=529, ES=500
  - stoicism_deep: EN=554, ES=500
  - zen_mindfulness: EN=583, ES=500
- **curate_preview_quotes.sql**: 90 preview quotes curadas (15×pack×lang, ranks 1-15)
  - Todos los 6 combos: 15 total / 5 free (rank 1-5) / 10 trial (rank 6-15)
- **update_author_bios.sql**: 22 bios reescritas EN+ES
- **Migration 010**: tabla `authors` creada, 432 autores seeded desde all_authors.json
- **data/authors_needs_quotes.json**: 35 autores con ≤3 quotes identificados (acción futura)

### Bloque B — Pack Monetization ✅
**Decisiones resueltas:**
1. Grandfathering parcial: Inside actual → 3 packs actuales incluidos. Packs futuros = compra separada
2. Trial en Packs: 15 quotes curadas + paywall. CTA: "$2.99 este pack" + "O Inside por $4.99"
3. Trial feed: 7 días O 1,000 quotes (lo que llegue primero)
4. Quotes por pack: 500 EN + 500 ES según idioma configurado
5. Free en Packs: 5 quotes preview (rank 1-5) + paywall
6. Grandfathering cutoff: 2026-06-01

**Migraciones aplicadas en Supabase:**
- Migration 009: `pack_purchases`, `pack_prices`, columnas `is_pack_preview/pack_preview_rank/released_at` en quotes, columnas `source/source_pack_id` en swipe_events
- Migration 010: tabla `authors` con RLS

**Archivos backend nuevos/modificados:**
- `backend/src/services/packEntitlement.js` — getPackEntitlement(), resolveUserState(), GRANDFATHERING_CUTOFF='2026-06-01'
- `backend/src/routes/packs.js` — GET /packs, GET /packs/:id/preview, GET /packs/:id/feed, POST /packs/:id/purchase/verify
- `backend/src/routes/premium.js` — GET /premium/status añade owned_packs + user_state; POST /premium/restore añade pack restore
- `backend/src/routes/swipes.js` — source (feed/pack/preview) + source_pack_id + entitlement check
- `backend/src/routes/authors.js` — lee desde DB authors table; GET /authors y GET /authors/:slug

**Archivos Flutter nuevos/modificados:**
- `flutter_app/lib/features/packs/packs_screen.dart` — badges con user_state, navegación directa a feed para entitled
- `flutter_app/lib/features/packs/pack_preview_screen.dart` — maneja redirect/preview/paywall/unavailable
- `flutter_app/lib/features/packs/pack_feed_screen.dart` — feed paginado, swipes con source:"pack", dwell_time_ms
- `flutter_app/lib/features/packs/widgets/paywall_card.dart` — paywall inline, ambos CTAs, precio desde API
- `flutter_app/lib/features/feed/widgets/soft_paywall_card.dart` — card no-bloqueante al swipe 100 del trial
- `flutter_app/lib/app/router.dart` — rutas /packs/:id/preview y /packs/:id/feed

### Bloque C — Swipe Navigation ✅
- `flutter_app/lib/shared/widgets/swipe_back_wrapper.dart` — GestureDetector, swipe desde borde izq (20dp), velocity>300px/s o offset>100px → context.pop()
- Vault: envuelta en SwipeBackWrapper, removido _CloseButton
- Author Detail: URL usa slug (name.toLowerCase() con replaceAll non-alphanum)
- Philosophy Map: envuelta en SwipeBackWrapper, removido leading
- Conservados: botón back en RedeemCode y Premium (flujos de compra)

### Bloque D — Reflection Card + Límite Swipes ✅
- Reflection card NO cuenta hacia límite de 20 swipes
- Auto-dismiss 4s timer
- Swipes horizontales en reflection card ignorados (solo vertical)
- Contador solo incrementa al swipear quote card real

## Datos clave del proyecto
- **DB**: ~13K quotes bilingüe (EN + ES) + ~1,500 nuevas de packs, 432 autores en tabla `authors`
- **Packs**: 3 packs — stoicism_deep ($2.99), existentialism ($2.99), zen_mindfulness ($2.99)
- **Premium**: MindScrolling Inside — $4.99 one-time, lifetime (grandfathers 3 packs actuales)
- **Free limit**: 20 swipes/día (client-side Flutter), 20 quotes en vault
- **Trial**: 7 días server-side, O 1,000 quotes (lo que llegue primero)
- **Swipe directions feed**: UP=stoicism, RIGHT=discipline, LEFT=reflection, DOWN=philosophy

## Pending / Bloque E (sprint futuro)
- Tarjetas temáticas por pack (ThemeData/PackTheme en Flutter)
- Audio ambiental por pack: 3 loops ~60s MP3 bundled (~4.5 MB extra)
- RevenueCat integration (stub actual muestra SnackBar "Próximamente")
- Trial 1,000-quote limit enforcement (actualmente solo time-based)
- Pack feed ordering by adaptive scoring (actualmente UUID order)
- Apple/Google receipt validation completa (S7-07 pre-launch gate)
- Consolidar autores duplicados (Cheng Yen, Sam Keen, Etty Hillesum)
- Expandir 35 autores con ≤3 quotes a mínimo 10 (ver data/authors_needs_quotes.json)
- Fastify v4→v5 upgrade (vuln DoS conocida, Dependabot abrirá PR)

## Sistema de 12 Agentes
product-owner, scrum-coordinator, api-architect, backend-implementer, qa-reviewer,
flutter-mobile-engineer, recommendation-engineer, data-content-engineer,
devops-engineer, documentation-writer, performance-engineer, agent-orchestrator

## Archivos clave actualizados
- `backend/src/services/packEntitlement.js` — lógica de acceso a packs
- `backend/src/routes/packs.js` — endpoints de packs completos
- `backend/src/routes/premium.js` — trial + purchase + redeem + owned_packs
- `backend/src/routes/swipes.js` — source tracking
- `backend/src/routes/authors.js` — desde DB authors table
- `backend/src/db/migrations/009_pack_monetization.sql` — schema Block B
- `backend/src/db/migrations/010_authors_table.sql` — tabla authors + 432 seeds
- `flutter_app/lib/shared/widgets/swipe_back_wrapper.dart` — swipe-to-go-back
- `flutter_app/lib/features/feed/feed_screen.dart` — reflection card fixes
- `flutter_app/lib/app/localization/` — 20+ nuevas keys para packs/paywall
- `flutter_app/lib/app/router.dart` — rutas completas incluyendo packs
- `scripts/assign_pack_quotes.sql` — distribución de quotes por pack
- `scripts/curate_preview_quotes.sql` — curation 15 preview quotes por combo
- `scripts/update_author_bios.sql` — 22 bios reescritas

## Notas técnicas
- API URL dispositivo físico: 192.168.100.7:3000 (NO 10.0.2.2)
- GoRouter: context.push() para sub-pantallas, context.go() solo para reemplazar stack
- DEV_FORCE_PREMIUM=true en .env local (remover para producción)
- Author slugs: name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-+|-+$'), '')
- pack_preview_rank constraint: 1-15 (no 16+)
- released_at en quotes tiene DEFAULT now() — backfill siempre debe ser UPDATE sin WHERE released_at IS NULL

**Why:** Sprint 7 completado. Todos los bloques A/B/C/D implementados y pusheados. DB aplicada con migrations 009 y 010. Listo para testing con testers.
**How to apply:** Próximo sprint enfocado en Bloque E (premium experience) y pre-launch gates (RevenueCat, receipt validation). No volver a tocar migrations 009/010 — ya aplicadas en producción.
