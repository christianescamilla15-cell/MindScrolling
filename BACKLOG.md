# MindScrolling — Backlog Priorizado
Generado: 2026-03-15 | Scrum Coordinator

---

## Decisiones de producto BLOQUEANTES
Estas deben resolverse antes de arrancar Sprint 1. Sin ellas, tareas de backend y sincronización no pueden estimarse.

| # | Pregunta | Impacto |
|---|----------|---------|
| DP-01 | ¿Los likes son solo client-side en MVP o van al backend? | Define si existe GET /me/likes y si hay sincronización entre dispositivos |
| DP-02 | ¿Cursor de paginación en GET /quotes/feed es UUID del último item o número de página? | Define contrato de la API stub y migración futura |
| DP-03 | ¿Fallback de idioma: si no hay frases en el idioma del usuario, mostrar EN o no mostrar nada? | Define comportamiento de fetchQuotes y UX de error |
| DP-04 | ¿Streak lo calcula el frontend, el backend, o solo el backend a partir de Sprint 2? | Resuelve CRIT-04. Para MVP: frontend lo calcula. Backend lo hereda en Sprint 2. |

---

## Sprint 0 — Estabilización (2026-03-15 al 2026-03-21)
Objetivo: dejar el código sin bugs críticos antes de añadir features. Corto, sin scope creep.

| ID | Descripción | Responsable | Criterio de aceptación | Prioridad |
|----|-------------|-------------|------------------------|-----------|
| S0-01 | Corregir doble incremento de `reflections` en `handleSwipe` (CRIT-02) | Frontend | `reflections` sube exactamente 1 por swipe; log manual confirma valor |  P0 |
| S0-02 | Inicializar `streak` y `reflections` en 0, no en valores hardcodeados (CRIT-02) | Frontend | En recarga limpia (localStorage vacío), ambos muestran 0 en pantalla | P0 |
| S0-03 | Corregir lógica streak: usar un solo `setReflections` funcional; modulo sobre el nuevo valor | Frontend | El toast "Streak extended" aparece exactamente al swipe 5, 10, 15... | P0 |
| S0-04 | Fijar counter "16/15": resetear `current` a 0 al agotar el deck o mostrar progreso relativo | Frontend | Al swipear la última carta el counter no muestra un número mayor que el total | P1 |
| S0-05 | Conectar Share button al handler `shareQuote` (MED-02) | Frontend | Tocar Share en cualquier carta activa Web Share API o copia al portapapeles | P1 |
| S0-06 | Decidir DP-01, DP-02, DP-03, DP-04 | Producto | Las 4 decisiones tienen respuesta escrita antes del 2026-03-21 | P0 |

---

## Sprint 1 — MVP Funcional (2026-03-22 al 2026-04-04)
Objetivo: RF-07 + RF-08 + RF-09 + RF-10 completos. App usable y compartible sin backend.

| ID | Descripción | Responsable | Criterio de aceptación | Prioridad |
|----|-------------|-------------|------------------------|-----------|
| S1-01 | Validar persistencia localStorage: vault, liked, streak, reflections (RF-07) | Frontend | Recargar página conserva todos los valores; abrir en incógnito empieza en 0 | P0 |
| S1-02 | Expandir catálogo a 100+ frases en el array estático QUOTES (RF-08) | Contenido | `QUOTES.length >= 100`; distribución equilibrada entre 4 categorías | P0 |
| S1-03 | Validar detección de idioma con `USER_LANG` y fallback "en" (RF-09) | Frontend | En browser con `navigator.language = "es"` el valor USER_LANG es "es"; sin soporte devuelve "en" | P1 |
| S1-04 | Pasar `USER_LANG` a `fetchQuotes` y filtrar frases locales por campo `lang` | Frontend | Con frases etiquetadas `lang: "en"` y `lang: "es"`, solo se muestran las del idioma detectado | P1 |
| S1-05 | Validar Share completo: Web Share API + fallback clipboard (RF-10) | Frontend | En móvil dispara share nativo; en desktop copia texto al portapapeles; toast confirma ambos casos | P0 |
| S1-06 | Evitar toasts solapados: nueva llamada a `showToast` cancela el timeout anterior (MED-03) | Frontend | Dos acciones rápidas muestran solo el último toast, sin apilamiento visible | P2 |
| S1-07 | Mover `Math.random()` de `ParticleBurst` a `useMemo` para evitar re-render continuo (MED-07) | Frontend | Partículas no se regeneran en cada render del padre; visible en React DevTools Profiler | P2 |
| S1-08 | Añadir campo `lang` a todas las frases del array estático | Contenido/Frontend | Cada objeto quote tiene `lang: "en"` (o "es" si aplica); TypeScript/PropTypes no lanza warning | P1 |

---

## Sprint 2 — Backend Real (2026-04-05 al 2026-04-18)
Objetivo: conectar frontend al backend Fastify + Supabase. Reemplazar stubs por llamadas reales.

| ID | Descripción | Responsable | Criterio de aceptación | Prioridad |
|----|-------------|-------------|------------------------|-----------|
| S2-01 | Crear schema Supabase: tablas `quotes`, `users`, `likes`, `vault`, `user_preferences`, `seen_quotes` | Backend | Migraciones corren sin error; `device_id` generado en frontend (UUID v4) y enviado en headers | P0 |
| S2-02 | Implementar `GET /quotes/feed?lang=&cursor=` con weighted random (likes x3, swipes x1, base 5) | Backend | Respuesta contiene `{ quotes: [...], nextCursor }` con frases no repetidas para el device_id | P0 |
| S2-03 | Implementar `GET /vault` y `POST /vault` con manejo de duplicados (MED-05) | Backend | POST de quote ya guardada devuelve 200 + mensaje "already saved", no duplica el registro | P1 |
| S2-04 | Implementar `DELETE /vault/:quote_id` con coerción de tipo (MED-04) | Backend | quote_id se parsea a integer en el handler; DELETE de ID inexistente devuelve 404 | P1 |
| S2-05 | Definir contrato de errores 4xx/5xx para todos los endpoints (MED-06) | Backend | Cada endpoint tiene respuesta `{ error: string, code: string }` documentada en un archivo `API_CONTRACT.md` | P1 |
| S2-06 | Implementar `GET /stats` (streak backend): desactivar cálculo de streak en frontend (CRIT-04) | Ambos | Frontend lee streak de `/stats`; el cálculo local en `handleSwipe` se elimina | P1 |
| S2-07 | Generar y persistir `device_id` (UUID v4) en localStorage al primer arranque (EC-05) | Frontend | `loadState()` incluye `device_id`; si no existe, genera uno nuevo y lo persiste | P0 |
| S2-08 | Reemplazar stub `fetchQuotes` por llamada real a `GET /quotes/feed` con cursor | Frontend | App carga frases desde la API; al llegar al final del deck pide `nextCursor`; sin backend muestra error toast | P0 |
| S2-09 | Implementar `POST /quotes/:id/like` (condicional a DP-01) | Backend | Si DP-01 = backend: endpoint persiste like/unlike por device_id; idempotente | P1 |
| S2-10 | Añadir 50+ frases en español a la base de datos (RF-12 parcial) | Contenido | `SELECT COUNT(*) FROM quotes WHERE lang = 'es'` devuelve >= 50 | P2 |

---

## Post-MVP (sin fecha fija)
Solo se planifican cuando Sprint 2 está completo y validado con usuarios reales.

| ID | Descripción | Responsable | Criterio de aceptación | Prioridad |
|----|-------------|-------------|------------------------|-----------|
| PM-01 | Streak milestone visual: animación especial en 7, 14, 30 días (RF-14) | Frontend | Al llegar a streak 7 aparece animación distinta al particle burst normal | P3 |
| PM-02 | Botón de donación Ko-fi / Buy Me a Coffee (RF-13) | Frontend | Link visible en settings o footer; no interfiere con el flujo principal de swipe | P3 |
| PM-03 | Contenido bilingüe expandido a 500+ frases ES+EN (RF-12 completo) | Contenido | `SELECT COUNT(*) FROM quotes` >= 500 con distribución >= 40% cada idioma | P3 |
| PM-04 | Fallback offline: mostrar frases cacheadas si la API no responde (EC-08) | Frontend | Con Network offline en DevTools, la app muestra las últimas frases descargadas sin pantalla en blanco | P3 |

---

## Descartado del MVP (Won't Have)
Autenticación, sync cloud, notificaciones push, feed social, ML de recomendación, UGC, suscripción de pago.
No se planifican ni se estiman hasta que Post-MVP esté en revisión.

---

## Resumen de responsables

| Rol | Tareas principales |
|-----|-------------------|
| **Frontend** | S0-01 a S0-05, S1-01, S1-03 a S1-07, S2-07, S2-08 |
| **Backend** | S2-01 a S2-06, S2-09 |
| **Contenido** | S1-02, S1-08, S2-10, PM-03 |
| **Ambos** | S2-06 |
| **Producto** | S0-06 (decisiones DP-01 a DP-04) |
