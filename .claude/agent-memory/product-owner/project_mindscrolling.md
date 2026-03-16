---
name: MindScrolling - Estado del proyecto
description: Estado actual del MVP, features implementadas, stack y decisiones de producto tomadas
type: project
---

Proyecto MindScrolling: app anti doom-scrolling filosófico. Fecha de referencia: 2026-03-15.

Frontend React MVP funcional en MindScroll_MVP.jsx con datos hardcodeados (15 frases).
Prototipo HTML estático alternativo en MindScroll-saved(3).html.
No hay backend implementado aún.

Features ya implementadas en el MVP React:
- Swipe en 4 direcciones mapeadas a 4 categorías (left=stoicism, right=discipline, up=philosophy, down=reflection)
- Double-tap para like con animación particle burst
- Vault (guardar frases) con bottom sheet
- Streak counter: +1 cada 5 reflexiones vistas
- Stats bar por categoría (porcentaje de swipes por cat)
- Swipe hints animados (se ocultan tras el primer swipe)
- Toast notifications
- Ghost card de fondo (card siguiente)
- Share button (no funcional aún)
- Estado solo en memoria local (sin persistencia)

Estado en memoria local solamente — sin localStorage, sin backend, sin persistencia entre sesiones.

**Why:** El MVP fue construido para validar la interacción core antes de invertir en infraestructura.

**How to apply:** Las próximas prioridades deben apuntar a persistencia local (localStorage), luego API de frases, luego backend de preferencias. No inventar features fuera de este concepto.
