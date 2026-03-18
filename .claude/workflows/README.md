# MindScrolling — Engineering Workflows

## Overview

This directory contains the workflow definitions for the MindScrolling multi-agent development system. These workflows enforce a disciplined engineering process to minimize bugs, prevent agent conflicts, and ensure stable releases.

## Workflow Files

| File | Purpose |
|------|---------|
| `feature_workflow.md` | How new features move from request to completion |
| `bug_workflow.md` | How bugs are triaged, fixed, and validated |
| `release_workflow.md` | How stable versions are prepared and approved |

## Template Files

| File | Purpose |
|------|---------|
| `../templates/handoff_template.md` | Standard report format when an agent completes work |
| `../templates/qa_checklist.md` | Comprehensive checklist for QA review passes |

## Agent Team

| Agent | Ownership |
|-------|-----------|
| Product Owner | Product scope, user stories, priorities |
| Scrum Coordinator | Sprint planning, task breakdown, sequencing |
| API Architect | Backend contracts, DB schema, architecture |
| Backend Implementer | Fastify routes, services, DB logic |
| Flutter Mobile Engineer | Flutter screens, widgets, state, navigation |
| Recommendation Engineer | Feed algorithm, scoring, embeddings |
| Data Content Engineer | Quote dataset, translations, quality pipeline |
| DevOps Engineer | Deployment, migrations, environment config |
| Documentation Writer | All project documentation |
| QA Reviewer | Code review, testing, regression detection |
| Performance Engineer | Performance optimization across full stack |
| Agent Orchestrator | Coordination, sequencing, conflict prevention |
| Security Engineer | Security audits, hardening, RLS, secret scanning |
| Analytics Engineer | KPIs, metrics, user behavior analysis, launch readiness |
| Product Experience Designer | Visual/sensory/emotional experience audits, pack themes |
| Philosophical Content Curator | Quote quality, author balance, pack coherence, editorial |
| Testing Intelligence Lead | Human tester feedback triage, pattern detection, version analysis |

## Core Rules

1. No implementation without scope definition
2. No implementation without API contracts (when APIs are involved)
3. Backend before Flutter when APIs are involved
4. Every specialist produces a handoff report
5. No feature closes without QA validation
6. No release ships without all gates passed
