---
name: Multi-agent workflow enforcement
description: El usuario quiere un flujo de trabajo disciplinado con 12 agentes, pipelines de feature/bug/release, handoff reports, y QA gates obligatorios
type: feedback
---

El usuario estableció un sistema profesional de multi-agentes con workflows estrictos para evitar bugs.

**Rules:**
1. No implementation sin scope definition (Product Owner primero)
2. No implementation sin API contracts (API Architect) cuando hay APIs involucradas
3. Backend ANTES de Flutter cuando hay APIs involucradas
4. Cada agente especialista produce un handoff report al terminar
5. No feature se cierra sin QA validation
6. No release sale sin pasar todos los gates
7. Si dos agentes podrían colisionar, pausar y reasignar ownership

**Why:** Sesiones anteriores tuvieron múltiples bugs (pantalla negra, navegación rota, idioma no aplicado, tiles en blanco) que habrían sido prevenidos con un flujo ordenado de scope → contract → implementation → QA.

**How to apply:** Antes de implementar cualquier feature nueva, seguir el pipeline de 9 pasos en `.claude/workflows/feature_workflow.md`. Para bugs, seguir `.claude/workflows/bug_workflow.md`. Usar handoff reports y QA checklists de `.claude/templates/`.
