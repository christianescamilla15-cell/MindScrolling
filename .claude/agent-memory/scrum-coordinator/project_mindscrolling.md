---
name: MindScrolling - Scrum backlog context
description: Backlog priorizado por fases generado el 2026-03-15, consolidando outputs de PO, API Architect, Backend Implementer y QA Reviewer
type: project
---

Backlog consolidado generado el 2026-03-15. El archivo autoritativo del backlog vive en:
`c:\Users\Chris\Desktop\MindScrolling\BACKLOG.md`

**Decisiones de producto pendientes al momento del backlog:**
1. ¿Likes van al backend o son solo client-side para MVP? (afecta GET /me/likes y sincronización)
2. Tipo de cursor de paginación para GET /quotes/feed (se propone UUID del último item visto)
3. Comportamiento fallback de idioma cuando no hay frases en el idioma del usuario (se propone fallback a EN)
4. Streak: ¿frontend lo calcula o solo backend? (actualmente ambos lo calculan — CRIT-04)

**Fases del backlog:**
- Sprint 0 (2026-03-15 a 2026-03-21): bugs críticos + decisiones de producto
- Sprint 1 (2026-03-22 a 2026-04-04): RF-07 localStorage, RF-09 idioma, RF-10 Share + 100 frases base
- Sprint 2 (2026-04-05 a 2026-04-18): backend real, API conectada, multilenguaje
- Post-MVP: streak milestones, donación, contenido bilingüe expandido

**Why:** Consolidar trabajo de cuatro agentes especializados en un solo plan ejecutable.
**How to apply:** Usar este contexto para mantener coherencia entre agentes en próximas conversaciones.
