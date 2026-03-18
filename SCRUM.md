# MindScrolling — Scrum Document

**Producto:** App anti doom-scrolling filosófico
**Stack:** Flutter (mobile) · Node.js + Fastify + Supabase (backend) · React legacy (web)
**Metodología:** Scrum ligero — sprints de ~2 semanas, sin reuniones formales
**Última actualización:** 2026-03-18

---

## Visión del producto

MindScrolling reemplaza el doom-scrolling con frases filosóficas curadas presentadas como tarjetas interactivas. El usuario desliza en 4 direcciones (una por categoría), construye un hábito de reflexión diaria medido por streaks, guarda favoritos en un Vault y puede donar opcionalmente si la app le aporta valor. Sin cuentas obligatorias. Sin algoritmos opacos. Sin publicidad.

---

## Decisiones de arquitectura

| Decisión | Elegida | Alternativa descartada | Razón |
|---|---|---|---|
| Auth | Anónimo por device_id (UUID en localStorage/SecureStorage) | Firebase Auth | Sin fricción en onboarding |
| Base de datos | PostgreSQL vía Supabase (free tier) | MongoDB Atlas | SQL relacional + RLS + gratis |
| Backend | Node.js + Fastify | Express / Next.js API Routes | Menor overhead, más rápido |
| Hosting backend | Railway o Render | Vercel Edge Functions | Servidor persistente, más predecible |
| Multilenguaje | Columna `lang` en DB + dataset ES estático + i18n propio | i18n framework externo | Mínimo, 2 idiomas, sin dependencias pesadas |
| Recomendación | Adaptive feed con scoring ponderado (affinity + onboarding + novelty) | ML / collaborative filtering | Explicable, escalable, suficiente |
| Monetización | One-time premium unlock ($4.99) + donación voluntaria | Suscripción mensual | Sin fricción, sin recurrencia |
| Costo estimado | $0–5/mes hasta ~500 DAU | — | Supabase free + Railway starter |
| **Cliente móvil** | **Flutter (Sprint 5)** | React Native / Capacitor | Cross-platform nativo, mejor gestos, Riverpod state |

---

## Sprint 0 — Estabilización del prototipo

**Período:** 2026-03-15 (completado)
**Objetivo:** Corregir bugs críticos que impedirían que el MVP funcionara correctamente con datos reales.

### Tareas completadas

| ID | Tarea | Archivo | Estado |
|----|-------|---------|--------|
| S0-01 | Fix: `handleSwipe` incrementaba `reflections` en 2 en vez de 1 (doble `setReflections`) | `MindScroll_MVP.jsx` | ✅ |
| S0-02 | Fix: inicializadores `useState(3)` y `useState(12)` → `useState(0)` | `MindScroll_MVP.jsx` | ✅ |
| S0-03 | Fix: lógica de streak usaba valor ya incrementado → `next % 5 === 0` | `MindScroll_MVP.jsx` | ✅ |
| S0-04 | Fix: counter mostraba "16/15" al ciclar → `(current % deck.length) + 1` | `MindScroll_MVP.jsx` | ✅ |
| S0-05 | Fix: Share button no tenía handler → conectado a `shareQuote()` | `MindScroll_MVP.jsx` | ✅ |
| S0-06 | Fix: toasts se solapaban → `clearTimeout` antes de cada nuevo toast | `MindScroll_MVP.jsx` | ✅ |

---

## Sprint 1 — MVP funcional

**Período:** 2026-03-15 al 2026-03-22 (completado)
**Objetivo:** La app funciona con datos reales (API externa), persiste estado entre sesiones y soporta español.

### Tareas completadas

| ID | Tarea | Archivo | Estado |
|----|-------|---------|--------|
| S1-01 | Persistencia localStorage: vault, liked, streak, reflections | `MindScroll_MVP.jsx` | ✅ |
| S1-02 | Conectar a Quotable.io API — frases ilimitadas en inglés con paginación infinita | `MindScroll_MVP.jsx` | ✅ |
| S1-03 | Detección de idioma: `USER_LANG = navigator.language.slice(0,2)` | `MindScroll_MVP.jsx` | ✅ |
| S1-04 | Dataset ES curado (32 frases, 8 por categoría) servido cuando `USER_LANG === "es"` | `MindScroll_MVP.jsx` | ✅ |
| S1-05 | Share: Web Share API + clipboard fallback | `MindScroll_MVP.jsx` | ✅ |
| S1-06 | Anti-solapamiento de toasts con `toastTimer` ref | `MindScroll_MVP.jsx` | ✅ |
| S1-07 | `ParticleBurst`: `Math.random()` dentro de `useMemo([])` | `MindScroll_MVP.jsx` | ✅ |

---

## Sprint 2 — Estructura del proyecto + Backend

**Período:** 2026-03-15 al 2026-04-04 (completado)
**Objetivo:** Crear estructura de carpetas definitiva, backend Fastify funcional y conexión a Supabase.

### Tareas completadas

| ID | Tarea | Archivo | Estado |
|----|-------|---------|--------|
| S2-01 | Crear estructura de carpetas completa | Directorio raíz | ✅ |
| S2-02 | Frontend: organizar en módulos (constants, utils, api, data) | `frontend/src/` | ✅ |
| S2-03 | Backend: servidor Fastify con plugins y rutas | `backend/src/` | ✅ |
| S2-04 | Schema SQL completo con migraciones | `001_initial.sql` | ✅ |
| S2-05 | Instalar dependencias (frontend + backend) | `node_modules/` | ✅ |
| S2-06 | Generar `device_id` en frontend y persistir | `frontend/src/utils/storage.js` | ✅ |
| S2-07 | Conectar frontend al backend real | `frontend/src/api/quotes.js` | ✅ |
| S2-08 | Ejecutar migración en Supabase | Supabase Dashboard | ✅ |
| S2-09 | Variables de entorno configuradas | `.env` | ✅ |
| S2-10 | Seed de base de datos: 5500 frases filosóficas | `backend/src/db/seed.js` | ✅ |

### Base de datos sembrada

- **Total:** 5,500 frases en 4 categorías
- stoicism: 1,375 · philosophy: 1,375 · discipline: 1,375 · reflection: 1,375
- Fuentes: Quotable.io (múltiples tags), ZenQuotes.io
- Herramienta: `node src/db/seed.js` (seeder v5, resume-safe, SSL bypass para cert expirado)

---

## Sprint 3 — Integración y testing

**Período:** 2026-04-05 al 2026-04-18 (completado)
**Objetivo:** Frontend conectado al backend real. Tests básicos. App funcional end-to-end.

### Tareas completadas

| ID | Tarea | Archivo | Estado |
|----|-------|---------|--------|
| S3-01 | `device_id` UUID v4 en `getDeviceId()` enviado en cada API call | `utils/storage.js` | ✅ |
| S3-02 | `fetchQuotes` → `GET /quotes/feed` con fallback a Quotable.io + offline | `api/quotes.js` | ✅ |
| S3-03 | Like/unlike → `POST /quotes/:id/like` | `api/quotes.js` + `routes/likes.js` | ✅ |
| S3-04 | Vault → `GET/POST/DELETE /vault` | `api/quotes.js` + `routes/vault.js` | ✅ |
| S3-05 | Stats → `GET /stats` (streak + reflections) | `routes/stats.js` | ✅ |
| S3-06 | 5,500 frases EN en DB | Supabase | ✅ |
| S3-07 | Headers `X-Device-ID` en todos los requests | `api/quotes.js` | ✅ |
| S3-08 | Weighted random feed por categoría (like×3 + swipe + 5) | `routes/quotes.js` | ✅ |
| S3-09 | Health check endpoint | `app.js` | ✅ |
| S3-10 | Rate limiting 60 req/min + CORS configurado | `app.js` | ✅ |

---

## Sprint 4 — Inteligencia adaptativa, personalización y monetización

**Período:** 2026-04-19 al 2026-05-02
**Objetivo:** Transformar el MVP en un producto inteligente con onboarding personalizado, feed adaptativo, mapa filosófico, desafíos diarios y modelo premium.

### Tareas

| ID | Tarea | Archivo(s) | Estado |
|----|-------|-----------|--------|
| S4-01 | Onboarding flow: 3 pantallas (swipe guide → perfil → start) | `components/Onboarding.jsx` | ✅ |
| S4-02 | Tabla `user_profiles` + endpoint `POST/GET /profile` | `migrations/001_initial.sql` · `routes/profile.js` | ✅ |
| S4-03 | Tabla `swipe_events` + endpoint `POST /swipes` con dwell time | `migrations/001_initial.sql` · `routes/swipes.js` | ✅ |
| S4-04 | `user_preferences` extendido (wisdom/discipline/reflection/philosophy scores) | `migrations/001_initial.sql` | ✅ |
| S4-05 | Algoritmo de feed adaptativo (affinity × 0.35 + onboarding × 0.15 + novelty) | `routes/quotes.js` | ✅ |
| S4-06 | Mapa filosófico: barras por categoría + evolución temporal | `components/PhilosophyMap.jsx` · `routes/map.js` | ✅ |
| S4-07 | Snapshots de preferencias para evolución semanal | `migrations/001_initial.sql` · `routes/map.js` | ✅ |
| S4-08 | Desafíos diarios: tabla + progreso + tarjeta en feed | `components/DailyChallenge.jsx` · `routes/challenges.js` | ✅ |
| S4-09 | Modelo premium: tabla `purchases` + `is_premium` en users + endpoint unlock | `routes/premium.js` | ✅ |
| S4-10 | Panel de donación (link externo, sin lógica backend) | `components/DonationPanel.jsx` | ✅ |
| S4-11 | Export quote como imagen (canvas, premium-only) | `utils/exportImage.js` | ✅ |
| S4-12 | Sistema i18n propio (ES/EN) con diccionarios completos | `i18n/index.js` | ✅ |
| S4-13 | Precios localizados (display-only: USD/MXN/BRL/ARS/EUR) | `constants/index.js` | ✅ |
| S4-14 | Panel de Settings con cambio de idioma | `components/Settings.jsx` | ✅ |
| S4-15 | EvolutionCard: tarjeta especial de evolución en feed | `components/EvolutionCard.jsx` | ✅ |
| S4-16 | Refactor App.jsx: orquestador de componentes modulares | `App.jsx` | ✅ |
| S4-17 | `utils/deviceId.js` como re-export explícito | `utils/deviceId.js` | ✅ |
| S4-18 | Premium gating en feed (quotes is_premium = false para free users) | `routes/quotes.js` | ✅ |

### Nuevas tablas (Sprint 4)

| Tabla | Propósito |
|-------|-----------|
| `user_profiles` | Perfil de onboarding (age_range, interest, goal, lang) |
| `swipe_events` | Log de cada swipe con dirección, categoría y dwell time |
| `user_preference_snapshots` | Snapshot semanal de scores para evolución |
| `daily_challenges` | Desafíos diarios con código y fecha activa |
| `challenge_progress` | Progreso por usuario por desafío |
| `purchases` | Registro de compras premium (one-time unlock) |

### Nuevos endpoints (Sprint 4)

| Método | Path | Descripción |
|--------|------|-------------|
| POST | `/profile` | Guardar perfil de onboarding |
| GET | `/profile` | Obtener perfil del usuario |
| POST | `/swipes` | Registrar evento de swipe |
| GET | `/challenges/today` | Desafío del día + progreso |
| POST | `/challenges/:id/progress` | Actualizar progreso del desafío |
| GET | `/map` | Mapa filosófico con scores y snapshot |
| POST | `/map/snapshot` | Guardar snapshot de evolución |
| GET | `/premium/status` | Estado premium del usuario |
| POST | `/premium/unlock` | Desbloquear premium (one-time) |

### Arquitectura del feed adaptativo (Sprint 4)

```
score(quote) =
  (category_affinity * 0.35)         ← like_count×3 + swipe_count + base_weight
  + (onboarding_interest_boost * 0.15) ← match entre interés del perfil y categoría
  + (goal_match * 0.10)               ← match entre objetivo y categoría
  + (like_history_match * 0.10)       ← categorías más likeadas
  + (novelty_bonus * Math.random() * 0.05) ← exploración aleatoria
  - author_repeat_penalty              ← penaliza mismo autor en 3 últimas frases
  - is_premium_gate                    ← excluye premium si usuario free
```

Distribución por batch:
- 60% categoría dominante
- 20% categoría secundaria
- 10% exploración
- 10% tarjetas especiales (challenge, evolution)

### Modelo freemium

| Característica | Free | Premium ($4.99) |
|----------------|------|-----------------|
| Acceso a frases | 200 frases free | 5,000+ frases |
| Vault | ✅ básico | ✅ ilimitado |
| Mapa filosófico | ✅ básico | ✅ con evolución |
| Desafío diario | ✅ | ✅ |
| Compartir | ✅ | ✅ |
| Export como imagen | ❌ | ✅ |
| Packs premium | ❌ | ✅ (stoicism, zen, existential...) |
| Sin anuncios | ✅ siempre | ✅ siempre |

---

## Estructura de archivos (Sprint 4)

```
MindScrolling/
├── frontend/
│   ├── src/
│   │   ├── api/
│   │   │   └── quotes.js              ← +apiSaveProfile, apiRecordSwipe, apiGetMap, apiUnlockPremium...
│   │   ├── components/
│   │   │   ├── Onboarding.jsx         ← [NUEVO] 3-screen onboarding flow
│   │   │   ├── Settings.jsx           ← [NUEVO] settings panel
│   │   │   ├── DonationPanel.jsx      ← [NUEVO] buy me a coffee
│   │   │   ├── PhilosophyMap.jsx      ← [NUEVO] mapa filosófico con barras
│   │   │   ├── DailyChallenge.jsx     ← [NUEVO] tarjeta de desafío diario
│   │   │   └── EvolutionCard.jsx      ← [NUEVO] tarjeta de evolución en feed
│   │   ├── constants/
│   │   │   └── index.js               ← +PREMIUM_PRICE_DISPLAY, PACK_NAMES, CHALLENGE_CODES
│   │   ├── data/
│   │   │   ├── quotes_en.js
│   │   │   └── quotes_es.js
│   │   ├── i18n/
│   │   │   └── index.js               ← [NUEVO] diccionarios ES/EN + t(lang, key)
│   │   ├── utils/
│   │   │   ├── deviceId.js            ← [NUEVO] re-export de getDeviceId
│   │   │   ├── exportImage.js         ← [NUEVO] canvas export premium
│   │   │   ├── shuffle.js
│   │   │   └── storage.js
│   │   ├── App.jsx                    ← refactorizado: orquestador
│   │   └── main.jsx
│   ├── .env                           ← +VITE_DONATION_LINK
│   └── .env.example
│
├── backend/
│   ├── src/
│   │   ├── db/
│   │   │   ├── client.js
│   │   │   ├── migrations/
│   │   │   │   └── 001_initial.sql    ← +6 tablas nuevas
│   │   │   └── seed.js
│   │   ├── plugins/
│   │   │   └── deviceId.js
│   │   └── routes/
│   │       ├── challenges.js          ← [NUEVO]
│   │       ├── likes.js
│   │       ├── map.js                 ← [NUEVO]
│   │       ├── premium.js             ← [NUEVO]
│   │       ├── profile.js             ← [NUEVO]
│   │       ├── quotes.js              ← algoritmo adaptativo
│   │       ├── stats.js
│   │       ├── swipes.js              ← [NUEVO]
│   │       └── vault.js
│   └── src/app.js                     ← +5 nuevas rutas registradas
│
├── SCRUM.md
└── .gitignore
```

---

## Cómo ejecutar el proyecto (actualizado)

### Frontend

```bash
cd frontend
cp .env.example .env
# Configurar en .env:
# VITE_API_URL=http://localhost:3000
# VITE_DONATION_LINK=https://buymeacoffee.com/tu-usuario
npm install
npm run dev                   # http://localhost:5173
```

### Backend

```bash
cd backend
cp .env.example .env
# Configurar en .env:
# PORT=3000
# ALLOWED_ORIGIN=http://localhost:5173
# SUPABASE_URL=https://...supabase.co
# SUPABASE_ANON_KEY=...
npm install
# Ejecutar backend/src/db/migrations/001_initial.sql en Supabase SQL Editor
npm run dev                   # http://localhost:3000
```

### Seed de base de datos

```bash
cd backend
node src/db/seed.js
# Siembra 5,500 frases filosóficas en Supabase
# Resume automáticamente desde el estado actual
```

### Verificar que todo funciona

```bash
curl http://localhost:3000/health
# → { "status": "ok", "ts": "..." }

curl -H "X-Device-ID: test-uuid-123" http://localhost:3000/stats
# → { "streak": 0, "total_reflections": 0, "category_counts": {...} }

curl -H "X-Device-ID: test-uuid-123" http://localhost:3000/quotes/feed?lang=en
# → { "data": [...], "next_cursor": "...", "has_more": true }

curl -H "X-Device-ID: test-uuid-123" http://localhost:3000/challenges/today
# → { "challenge": { "title": "...", ... }, "progress": { ... } }

curl -H "X-Device-ID: test-uuid-123" http://localhost:3000/map
# → { "current": { "wisdom": 0, ... }, "snapshot": null }

curl -H "X-Device-ID: test-uuid-123" http://localhost:3000/premium/status
# → { "is_premium": false }
```

---

## Sprint 5 — Migración a Flutter (app móvil nativa)

**Período:** 2026-03-15 al 2026-04-15
**Objetivo:** Reemplazar el frontend React con una app Flutter multiplataforma (iOS + Android) manteniendo el backend intacto. El frontend React se preserva en `frontend_legacy/`.

### Decisiones de arquitectura Flutter

| Capa | Tecnología |
|------|-----------|
| State management | Riverpod 2.x (`@riverpod` annotations) |
| Navegación | GoRouter 13.x |
| HTTP | `http` package + `ApiClient` wrapper |
| Persistencia local | SharedPreferences + flutter_secure_storage |
| Gestos de swipe | flutter_card_swiper |
| Compartir | share_plus |
| Export imagen | screenshot + image_gallery_saver |
| Fuentes | Playfair Display + DM Sans |

### Arquitectura de capas

```
flutter_app/lib/
├── app/           ← Router, tema, localización
├── core/          ← Constantes, utils, network, storage, analytics
├── data/          ← Models, datasources (remote/local), repositories
├── features/      ← Pantallas por feature (bootstrap, onboarding, feed, ...)
└── shared/        ← Widgets reutilizables, extensions
```

### Tareas

| ID | Tarea | Archivo(s) | Estado |
|----|-------|-----------|--------|
| S5-01 | Inicializar proyecto Flutter + pubspec.yaml con dependencias | `flutter_app/pubspec.yaml` | ✅ |
| S5-02 | Capa `app/`: router GoRouter, tema oscuro, localización ES/EN | `app/router.dart` · `app/app.dart` · `app/theme/` · `app/localization/` | ✅ |
| S5-03 | Capa `core/`: constantes, utils (device_id, locale, date), network, storage, analytics | `core/constants/` · `core/utils/` · `core/network/` · `core/storage/` | ✅ |
| S5-04 | Capa `data/` — Modelos: QuoteModel, UserProfileModel, ChallengeModel, PhilosophyMapModel, PremiumStateModel, SwipeEventModel, FeedItemModel | `data/models/` | ✅ |
| S5-05 | Capa `data/` — Datasources remotos: feed, profile, vault, stats, challenge | `data/datasources/remote/` | ✅ |
| S5-06 | Capa `data/` — Datasources locales: feed cache, session, settings | `data/datasources/local/` | ✅ |
| S5-07 | Capa `data/` — Repositories: feed, vault, profile, challenge, premium | `data/repositories/` | ✅ |
| S5-08 | Feature `bootstrap`: splash + init de device_id + redirect lógica | `features/bootstrap/` | ✅ |
| S5-09 | Feature `onboarding`: 3 pantallas (intro → perfil → start) | `features/onboarding/` | ✅ |
| S5-10 | Feature `feed`: FeedScreen + QuoteCard + swipe gestures + action bar | `features/feed/` | 🔄 |
| S5-11 | Feature `swipe`: SwipeController + SwipeDirection + feedback overlay | `features/swipe/` | ✅ |
| S5-12 | Feature `vault`: VaultScreen + VaultController | `features/vault/` | ✅ |
| S5-13 | Feature `philosophy_map`: barras de categoría + snapshots de evolución | `features/philosophy_map/` | 🔄 |
| S5-14 | Feature `challenges`: desafío diario + progreso + ring visual | `features/challenges/` | 🔄 |
| S5-15 | Feature `premium`: pantalla upgrade + comparativa free/premium | `features/premium/` | 🔄 |
| S5-16 | Feature `donations`: pantalla Buy Me a Coffee con url_launcher | `features/donations/` | 🔄 |
| S5-17 | Feature `profile`: stats (streak, reflections) + preferencias | `features/profile/` | 🔄 |
| S5-18 | Feature `settings`: idioma ES/EN + navegación a features + reset onboarding | `features/settings/` | 🔄 |
| S5-19 | Feature `share_export`: share_plus + export canvas como imagen | `features/share_export/` | 🔄 |
| S5-20 | Shared widgets: AppButton, AppLoader, AppErrorView, SectionTitle | `shared/widgets/` | ✅ |
| S5-21 | Shared extensions: BuildContext, String | `shared/extensions/` | 🔄 |
| S5-22 | Archivos de plataforma Android (AndroidManifest, build.gradle, gradle.properties) | `android/` | ✅ |
| S5-23 | Archivos de plataforma iOS (Info.plist, AppDelegate.swift, Runner.xcodeproj) | `ios/` | ✅ |
| S5-24 | Preservar React frontend como `frontend_legacy/` | `frontend_legacy/` | ✅ |
| S5-25 | Actualizar SCRUM.md con sprint Flutter | `SCRUM.md` | ✅ |

### Estructura de directorios Flutter

```
flutter_app/
├── android/
│   └── app/
│       └── src/main/
│           ├── AndroidManifest.xml
│           └── kotlin/com/mindscrolling/
│               └── MainActivity.kt
├── ios/
│   └── Runner/
│       ├── AppDelegate.swift
│       └── Info.plist
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart
│   │   ├── router.dart
│   │   ├── localization/
│   │   │   ├── app_strings.dart
│   │   │   ├── strings_en.dart
│   │   │   └── strings_es.dart
│   │   └── theme/
│   │       ├── app_theme.dart
│   │       ├── colors.dart
│   │       └── typography.dart
│   ├── core/
│   │   ├── analytics/event_logger.dart
│   │   ├── constants/
│   │   │   ├── api_constants.dart
│   │   │   ├── app_constants.dart
│   │   │   ├── feed_constants.dart
│   │   │   └── monetization_constants.dart
│   │   ├── network/
│   │   │   ├── api_client.dart
│   │   │   ├── api_result.dart
│   │   │   └── headers_builder.dart
│   │   ├── providers/core_providers.dart
│   │   ├── storage/
│   │   │   ├── cache_storage.dart
│   │   │   ├── local_storage.dart
│   │   │   └── secure_storage.dart
│   │   └── utils/
│   │       ├── date_utils.dart
│   │       ├── debounce.dart
│   │       ├── device_id.dart
│   │       └── locale_utils.dart
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── local/
│   │   │   │   ├── feed_local_ds.dart
│   │   │   │   ├── session_local_ds.dart
│   │   │   │   └── settings_local_ds.dart
│   │   │   └── remote/
│   │   │       ├── challenge_remote_ds.dart
│   │   │       ├── feed_remote_ds.dart
│   │   │       ├── profile_remote_ds.dart
│   │   │       ├── stats_remote_ds.dart
│   │   │       └── vault_remote_ds.dart
│   │   ├── models/
│   │   │   ├── challenge_model.dart
│   │   │   ├── feed_item_model.dart
│   │   │   ├── philosophy_map_model.dart
│   │   │   ├── premium_state_model.dart
│   │   │   ├── quote_model.dart
│   │   │   ├── swipe_event_model.dart
│   │   │   └── user_profile_model.dart
│   │   └── repositories/
│   │       ├── challenge_repository.dart
│   │       ├── feed_repository.dart
│   │       ├── premium_repository.dart
│   │       ├── profile_repository.dart
│   │       └── vault_repository.dart
│   ├── features/
│   │   ├── bootstrap/
│   │   │   ├── bootstrap_controller.dart
│   │   │   └── bootstrap_screen.dart
│   │   ├── challenges/
│   │   │   ├── challenges_controller.dart
│   │   │   └── challenges_screen.dart
│   │   ├── donations/
│   │   │   └── donations_screen.dart
│   │   ├── feed/
│   │   │   ├── feed_controller.dart
│   │   │   ├── feed_prefetch.dart
│   │   │   ├── feed_queue.dart
│   │   │   ├── feed_screen.dart
│   │   │   ├── feed_state.dart
│   │   │   └── widgets/
│   │   │       ├── action_bar.dart
│   │   │       ├── category_badge.dart
│   │   │       ├── like_button.dart
│   │   │       ├── quote_card.dart
│   │   │       └── swipe_hint.dart
│   │   ├── onboarding/
│   │   │   ├── onboarding_controller.dart
│   │   │   ├── onboarding_screen.dart
│   │   │   └── widgets/
│   │   │       ├── age_selector.dart
│   │   │       ├── goal_selector.dart
│   │   │       ├── interest_selector.dart
│   │   │       └── onboarding_intro.dart
│   │   ├── philosophy_map/
│   │   │   ├── philosophy_map_controller.dart
│   │   │   └── philosophy_map_screen.dart
│   │   ├── premium/
│   │   │   ├── premium_controller.dart
│   │   │   └── premium_screen.dart
│   │   ├── profile/
│   │   │   ├── profile_controller.dart
│   │   │   └── profile_screen.dart
│   │   ├── settings/
│   │   │   ├── settings_controller.dart
│   │   │   └── settings_screen.dart
│   │   ├── share_export/
│   │   │   ├── export_card_widget.dart
│   │   │   └── share_export_service.dart
│   │   ├── swipe/
│   │   │   ├── swipe_controller.dart
│   │   │   ├── swipe_direction.dart
│   │   │   ├── swipe_feedback.dart
│   │   │   └── swipe_gesture_handler.dart
│   │   └── vault/
│   │       ├── vault_controller.dart
│   │       └── vault_screen.dart
│   └── shared/
│       ├── extensions/
│       │   ├── context_extensions.dart
│       │   └── string_extensions.dart
│       └── widgets/
│           ├── app_button.dart
│           ├── app_error_view.dart
│           ├── app_loader.dart
│           └── section_title.dart
├── test/
└── pubspec.yaml
```

### Colores de categoría (Flutter)

| Categoría | Color | Dirección swipe |
|-----------|-------|-----------------|
| stoicism | `#6B8F71` | ↑ arriba |
| discipline | `#C17F24` | → derecha |
| reflection | `#9B6B8F` | ← izquierda |
| philosophy | `#7B9BB8` | ↓ abajo |

### Cómo ejecutar la app Flutter

```bash
cd flutter_app
flutter pub get
flutter run                    # emulador o dispositivo conectado
flutter build apk --release    # Android APK
flutter build ios --release    # iOS (requiere Xcode en macOS)
```

---

## Sprint 6 — QA Gate & Correcciones (completado)

**Período:** 2026-03-17 al 2026-03-18
**Objetivo:** Auditoría completa del repositorio (backend + Flutter + docs + dataset). Detectar y corregir todos los bugs críticos, errores de lógica, regresiones de precio, strings no localizados y código muerto antes del lanzamiento en Google Play.

### Expansión de bios de autores

| ID | Tarea | Archivo | Estado |
|----|-------|---------|--------|
| S6-A01 | Crear `author_bios.js` como fuente única para 433 bios EN + ES | `backend/src/data/author_bios.js` | ✅ |
| S6-A02 | Simplificar `getAuthorBio()` a 4 líneas (fallback EN → ES → default) | `backend/src/routes/authors.js` | ✅ |
| S6-A03 | Eliminar bloque `_LEGACY_BIOS` (~165 líneas de código muerto) | `backend/src/routes/authors.js` | ✅ |
| S6-A04 | Verificar cobertura 433/433 autores EN y ES programáticamente | Script Node.js + all_authors.json | ✅ |
| S6-A05 | Eliminar 8 claves duplicadas en el objeto `AUTHOR_BIOS` | `backend/src/data/author_bios.js` | ✅ |

### Correcciones backend (QA gate)

| ID | Severidad | Descripción | Archivo | Estado |
|----|-----------|-------------|---------|--------|
| S6-B01 | CRIT | Challenge: servidor ahora incrementa progreso en 1/llamada; `completed` derivado server-side al alcanzar 8 swipes | `routes/challenges.js` | ✅ |
| S6-B02 | CRIT | Vault: límite de 20 saves para usuarios free (403 `VAULT_LIMIT_REACHED`) | `routes/vault.js` | ✅ |
| S6-B03 | CRIT | Premium insights: gate invertido corregido — nuevos dispositivos ya no pasan como premium | `routes/insights.js` | ✅ |
| S6-B04 | CRIT | Premium iOS source: `premium_source` ahora detecta iOS vs Android correctamente | `routes/premium.js` | ✅ |
| S6-B05 | HIGH | Map: `computeScores()` retorna campos con sufijo `_score` (alineado al contrato de API) | `routes/map.js` | ✅ |
| S6-B06 | HIGH | Profile: `GET /profile` ahora selecciona `device_id` en la query | `routes/profile.js` | ✅ |
| S6-B07 | HIGH | Premium legacy `/unlock`: captura error de update y retorna 500 si falla | `routes/premium.js` | ✅ |
| S6-B08 | HIGH | Mind profile: `CATEGORIES.sort()` → `[...CATEGORIES].sort()` para evitar mutación concurrente | `routes/mind-profile.js` | ✅ |
| S6-B09 | MED | Swipes: validación de categoría permitida (stoicism/philosophy/discipline/reflection) | `routes/swipes.js` | ✅ |
| S6-B10 | MED | Challenge: `GET /challenges/today` retorna `progress: null` para dispositivos sin interacción previa | `routes/challenges.js` | ✅ |
| S6-B11 | MED | Profile: respuesta `POST /profile` cambiada de `{ saved: true }` a `{ ok: true }` | `routes/profile.js` | ✅ |
| S6-B12 | MED | Map snapshot: respuesta cambiada de `{ saved: true }` a `{ ok: true }` | `routes/map.js` | ✅ |
| S6-B13 | MED | Premium status: variable `userErr` no usada eliminada | `routes/premium.js` | ✅ |

### Correcciones Flutter (QA gate)

| ID | Severidad | Descripción | Archivo | Estado |
|----|-----------|-------------|---------|--------|
| S6-F01 | CRIT | `unlock()` usaba `amount: 2.99` → `MonetizationConstants.basePriceUsd` (4.99) | `premium_controller.dart` | ✅ |
| S6-F02 | CRIT | `successMessage` hardcodeado en inglés → key `'purchaseSuccess'` (i18n) | `premium_controller.dart` | ✅ |
| S6-F03 | CRIT | Offline fallback en challenges usaba `ChallengeModel` hardcodeado en inglés → `challenge: null` (UI fallback localizado) | `challenges_controller.dart` | ✅ |
| S6-F04 | HIGH | Eliminado widget `_ActionButton` dead code (282–314) | `challenges_screen.dart` | ✅ |
| S6-F05 | HIGH | `'$quoteCount quotes'` → `context.tr.nQuotes(quoteCount)` (nuevo método i18n) | `packs_screen.dart` | ✅ |
| S6-F06 | HIGH | `'${_data!['total_quotes']} quotes'` → `context.tr.nQuotes(...)` | `author_detail_screen.dart` | ✅ |
| S6-F07 | HIGH | Categorías como slug raw → `context.tr.categoryLabels[cat]` | `author_detail_screen.dart` | ✅ |
| S6-F08 | HIGH | `'MindScrolling Inside'` hardcodeado → `context.tr.premium` | `packs_screen.dart` | ✅ |
| S6-F09 | HIGH | `'MindScroll'` hardcodeado → `context.tr.appName` | `feed_screen.dart` | ✅ |
| S6-F10 | MED | Fallback de precio `r'$2.99'` → `r'$4.99'` | `premium_screen.dart` | ✅ |
| S6-F11 | LOW | Typo `'proximamente'` → `'próximamente'` | `strings_es.dart` | ✅ |
| S6-I01 | i18n | Método `nQuotes(int n)` añadido a `AppStrings`, `StringsEn` y `StringsEs` | `app_strings.dart` + impls | ✅ |

### Correcciones de documentación

| ID | Descripción | Archivo | Estado |
|----|-------------|---------|--------|
| S6-D01 | Precio actualizado `$2.99` → `$4.99` | `ARCHITECTURE.md`, `SCRUM.md`, `ROADMAP.md` | ✅ |
| S6-D02 | Conteo de quotes actualizado `5,500` → `~13,000` | `ARCHITECTURE.md` | ✅ |
| S6-D03 | Arquitectura del challenge documentada (8 swipes server-side) | `ARCHITECTURE.md` | ✅ |
| S6-D04 | Versión actualizada Sprint 5 → Sprint 6 + fecha | `ARCHITECTURE.md` | ✅ |
| S6-D05 | Header `author_bios.js` actualizado 432 → 433 autores | `author_bios.js` | ✅ |
| S6-D06 | Dirección de swipes corregida en tabla de categorías | `SCRUM.md` | ✅ |

### Sistema de workflow QA implementado (Control Tower)

| ID | Descripción | Archivo | Estado |
|----|-------------|---------|--------|
| S6-W01 | Blind test targets, checklist y resultados (Sprint 6 baseline) | `cloud/testing/` | ✅ |
| S6-W02 | Control Tower: dashboard, build/qa/blind_test status, blockers, release status | `cloud/control_tower/` | ✅ |
| S6-W03 | Historial automático: build_history, score_history, qa_history, regression_log | `cloud/control_tower/` | ✅ |
| S6-W04 | Protocolo self-debugging con loop detect→classify→assign→fix→verify | `cloud/workflows/` | ✅ |
| S6-W05 | Workflows: QA, Blind Test, Product Brain, Sprint Planner, Roadmap, Release | `cloud/workflows/` | ✅ |
| S6-W06 | Debugging log: B-01..B-04 como blockers activos | `cloud/debugging/` | ✅ |

### Blockers arquitecturales (requieren DevOps — no bloquearon QA gate)

| ID | Descripción | Severidad | Owner |
|----|-------------|-----------|-------|
| B-01 | Receipt validation real (RevenueCat webhook) en `/purchase/verify` | Critical | DevOps + Backend |
| B-02 | Rate-limit admin persistente + `crypto.timingSafeEqual` | Major | Backend Implementer |
| B-03 | TOCTOU race en `POST /premium/start-trial` | Major | Backend Implementer |
| B-04 | Campos `swipe_dir` + `is_premium` faltantes en preview de packs | Minor | Backend Implementer |

### Estado del Build al cerrar Sprint 6

| Métrica | Valor |
|---------|-------|
| Build Quality Score | **82/100** |
| Estado | 🟡 Stable — Needs Stabilization before release |
| Micro QA | ✅ PASS |
| Feature QA | ✅ PASS |
| Integration QA | ✅ PASS |
| Release QA | ⏳ Pendiente (bloqueado por B-01) |
| Regressions | 0 |

---

## Sprint 7 — Google Play Launch + Retention (en progreso)

**Período:** 2026-03-18 → 2026-04-04
**Objetivo:** Lanzar en Google Play, desplegar backend en producción, activar pgvector para el feed AI, instrumentar el funnel trial→paid y añadir notificaciones push.

### Tareas

| ID | Tarea | Owner | Estado |
|----|-------|-------|--------|
| S7-01 | Resolver B-01: Receipt validation real con RevenueCat webhook | Backend Implementer + DevOps | 🔴 Pendiente |
| S7-02 | Resolver B-02: Rate-limit admin persistente + timing-safe comparison | Backend Implementer | 🟠 Pendiente |
| S7-03 | Resolver B-03: TOCTOU race en trial start (constraint DB o advisory lock) | Backend Implementer | 🟠 Pendiente |
| S7-04 | Resolver B-04: Añadir `swipe_dir` + `is_premium` al select de packs preview | Backend Implementer | 🟡 Pendiente |
| S7-05 | Desplegar backend en Railway producción (health check + no cold starts) | DevOps | 🔴 Pendiente |
| S7-06 | Habilitar pgvector en Supabase + activar feed AI | Recommendation Engineer | 🔴 Pendiente |
| S7-07 | Instrumentar funnel: `trial_started` / `trial_expired` / `premium_purchased` (server-side) | Backend Implementer | 🟠 Pendiente |
| S7-08 | Notificaciones push: recordatorio diario a hora configurable por el usuario | Flutter Mobile Engineer | 🟠 Pendiente |
| S7-09 | Notificación semanal: "Tu mapa filosófico está listo" | Flutter Mobile Engineer | 🟠 Pendiente |
| S7-10 | Export del Vault como texto plano (free — growth loop) | Flutter Mobile Engineer | 🟡 Pendiente |
| S7-11 | Auditoría de precios localizados: MXN / BRL / ARS / COP | Product Owner | 🟡 Pendiente |
| S7-12 | Sentry en backend (error tracking producción) | DevOps | 🟠 Pendiente |
| S7-13 | Optimización de queries: partial indexes en feed | Backend Implementer | 🟡 Pendiente |
| S7-14 | Submisión a Google Play Store | DevOps + Product Owner | 🔴 Pendiente |
| S7-15 | Smoke test en build de producción (APK release) | QA Reviewer | 🔴 Pendiente |

### Criterio de "Done" para Sprint 7

- Build Quality Score ≥ 90
- Release QA completado
- B-01 resuelto (no hay release sin receipt validation real)
- Backend en Railway producción respondiendo `/health`
- APK release firmado y subido a Google Play
- Blind test completo en build de producción: 0 FAIL, 0 REGRESSION

---

## Post-MVP (sin fecha)

| ID | Feature |
|----|---------|
| PM-01 | Animación especial en streak 7/14/30 días |
| PM-02 | 500+ frases ES + packs en español |
| PM-03 | Service Worker / offline cache |
| PM-04 | Auth real (Google/Apple) para sync cross-device |
| PM-05 | Notificaciones push para hábito diario |
| PM-06 | Analytics básico: retention, frases más likeadas |
| PM-07 | Vault collections (carpetas temáticas) |
| PM-08 | Modo oscuro absoluto / modo claro opcional |
| PM-09 | Widget iOS/Android |
| PM-10 | API pública para devs filosóficos |

---

## Definición de "Done"

Una tarea se considera terminada cuando:
1. El código está escrito y no rompe funcionalidades existentes
2. Los edge cases obvios están manejados (errores de red, datos vacíos, backend caído)
3. No hay bugs nuevos introducidos
4. Si tiene UI: funciona en el dispositivo móvil target (Android + iOS)
5. Las variables de entorno necesarias están documentadas en `.env.example`
6. Pasa el QA level correspondiente al tamaño del cambio (Micro / Feature / Integration)
7. Si es feature visible: pasa el blind test (no se confía en el código, se verifica como usuario)
8. `cloud/control_tower/dashboard.md` actualizado con el nuevo estado

## Sistema de calidad (QA Workflow)

El proyecto opera bajo un sistema de QA por niveles. Ver `cloud/workflows/qa_workflow.md` para el protocolo completo.

| Nivel | Cuándo aplicar | Checks clave |
|-------|---------------|--------------|
| Micro QA | Después de cualquier cambio | App corre, `/health` ok, feed carga, sin crash |
| Feature QA | Después de cada feature | Feature funciona end-to-end, sin regresión en flows principales |
| Integration QA | Cambios multi-sistema | Frontend + backend alineados, todos los sistemas core intactos |
| Release QA | Antes de deploy/APK | Validación completa, localization, premium/free, performance |

**Regla crítica:** Si el QA falla → el workflow se detiene inmediatamente.

**Release gate:** Build Quality Score ≥ 90 + 0 Critical issues + 0 Regressions + Release QA completo.

Ver estado actual en `cloud/control_tower/dashboard.md`.

---

*Documento generado y mantenido con Claude Code — actualizar al cerrar cada sprint.*
