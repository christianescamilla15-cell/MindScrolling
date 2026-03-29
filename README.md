# MindScrolling

AI-powered mobile product designed to reduce doom-scrolling through reflective content and adaptive recommendation logic.

## Overview
MindScrolling is a mobile-first philosophical discovery product built with Flutter, Fastify, and Supabase. Instead of optimizing for addictive engagement, it explores how recommendation systems can support intentional reflection.

## Product Problem
Most feeds optimize for attention capture. MindScrolling explores the opposite: a feed designed to encourage reflection, curiosity, and healthier digital behavior.

## Core Product Thesis
- Reflective scrolling instead of addictive scrolling
- Behavioral recommendation instead of pure click optimization
- Mobile-first product experience
- Optional premium model without ad dependence

## AI / Recommendation Architecture

```text
Flutter App
    ↓
Fastify Backend
    ↓
Recommendation Engine
    ↓
Behavioral Signals + pgvector Similarity
    ↓
Supabase / PostgreSQL
```

## Key Features
- Adaptive philosophical feed with 13,000+ quotes
- Swipe-based behavioral signals
- Philosophy map for content exploration
- Multilingual support (EN/ES)
- Premium packs / monetization layer
- Challenge engine for user engagement

## Engineering Decisions

### Why Flutter?
To support a unified mobile product across Android and iOS with a single codebase.

### Why Fastify?
To keep backend APIs lightweight, modular, and high-performance.

### Why behavioral weighting?
To personalize the feed using interaction patterns (swipes, likes, saves, reading time) rather than pure click-through rates.

## Tech Stack
| Layer | Technology |
|-------|-----------|
| Mobile | Flutter / Dart |
| Backend | Node.js / Fastify |
| Database | Supabase / PostgreSQL |
| AI | pgvector + EMA hybrid recommendation |
| CI/CD | 14 pipelines |
| Distribution | Google Play Store |

## Repo Structure
```
backend/          # Fastify API
flutter_app/      # Flutter mobile app
docs/             # Architecture docs
data/             # Quote datasets
store-assets/     # Play Store materials
scripts/          # Build & deploy scripts
testers/          # Test utilities
```

## Key Metrics
| Metric | Value |
|--------|-------|
| Commits | 140+ |
| Platforms | Android / iOS |
| Public Releases | 3 |
| Quotes | 13,000+ |
| CI/CD Pipelines | 14 |

## How to Run

### Backend
```bash
cd backend
npm install
npm run dev
```

### Mobile app
```bash
cd flutter_app
flutter pub get
flutter run
```

## Product Documents
- [ARCHITECTURE.md](docs/ARCHITECTURE.md)
- [FEED_ALGORITHM.md](docs/FEED_ALGORITHM.md)
- [DATASET_PIPELINE.md](docs/DATASET_PIPELINE.md)
- [BACKLOG.md](docs/BACKLOG.md)

## Roadmap
- [ ] Better recommendation explainability
- [ ] Offline caching improvements
- [ ] Feed analytics dashboard
- [ ] Reflection notifications

---
Built by [Christian Hernandez](https://ch65-portfolio.vercel.app) · AI Engineer
