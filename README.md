<p align="center">
  <h1 align="center">MindScrolling</h1>
  <p align="center">
    <strong>Replace doom-scrolling with philosophy.</strong><br/>
    A swipe-based mobile app that delivers curated philosophical wisdom — one card at a time.
  </p>
  <p align="center">
    <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" />
    <img src="https://img.shields.io/badge/Node.js-Fastify-000000?logo=fastify" />
    <img src="https://img.shields.io/badge/Database-Supabase-3ECF8E?logo=supabase" />
    <img src="https://img.shields.io/badge/Status-Active-brightgreen" />
    <img src="https://img.shields.io/badge/License-MIT-blue" />
  </p>
</p>

---

## The Problem

The average person spends 3–5 hours daily scrolling through content that offers no lasting value. Attention is the most finite resource of the modern era — and it is being consumed at scale by systems optimized for engagement, not growth.

## The Vision

MindScrolling hijacks the dopamine loop of social scrolling and replaces it with something that compounds over time: philosophical wisdom, self-reflection, and intellectual growth.

Same gesture. Different outcome.

---

## What It Does

You swipe cards in 4 directions. Each direction is a category:

```
              ↑ Philosophy / Existential
              │
  Stoicism ←──┼──→ Discipline / Growth
              │
              ↓ Reflection / Life
```

The app learns your preferences through every swipe and surfaces content aligned with your intellectual profile. Over time, it builds a **Philosophy Map** — a visual representation of your intellectual evolution.

---

## Key Features

| Feature | Description |
|---|---|
| **4-direction swipe feed** | Stoicism, Philosophy, Discipline, Reflection |
| **Adaptive algorithm** | Feed personalizes based on swipe history and onboarding profile |
| **Philosophy Map** | Visual score of your intellectual categories, evolving over time |
| **Daily Challenge** | One philosophical challenge per day to build the habit |
| **Vault** | Save quotes that resonate |
| **Multilingual** | English and Spanish, auto-detected from device |
| **Premium tier** | One-time $2.99 unlock — no subscriptions |
| **Donation support** | Optional support via Buy Me a Coffee |
| **Offline fallback** | Bundled quote dataset works without internet |
| **No accounts required** | Anonymous device-based identity |

---

## Architecture Overview

```
┌─────────────────────────────────────────────┐
│              Flutter Mobile App              │
│  (iOS + Android, Riverpod, GoRouter)        │
└───────────────────┬─────────────────────────┘
                    │ HTTP + X-Device-ID header
┌───────────────────▼─────────────────────────┐
│           Node.js + Fastify Backend          │
│  (REST API, rate limiting, device auth)     │
└───────────────────┬─────────────────────────┘
                    │ Supabase client
┌───────────────────▼─────────────────────────┐
│         PostgreSQL via Supabase              │
│  (quotes, users, vault, preferences,        │
│   swipe events, challenges, purchases)      │
└─────────────────────────────────────────────┘
```

---

## Stack

| Layer | Technology |
|---|---|
| Mobile | Flutter 3.x (Dart) |
| State management | Riverpod 2.x |
| Navigation | GoRouter 13.x |
| Backend | Node.js + Fastify 4.x |
| Database | PostgreSQL via Supabase |
| Auth | Anonymous device ID (UUID v4) |
| Storage | SharedPreferences + flutter_secure_storage |
| Fonts | Playfair Display + DM Sans |

---

## Project Structure

```
MindScrolling/
├── flutter_app/               ← Mobile app (Flutter)
│   ├── lib/
│   │   ├── app/               ← Router, theme, localization
│   │   ├── core/              ← Constants, network, storage, utils
│   │   ├── data/              ← Models, datasources, repositories
│   │   ├── features/          ← One folder per screen/feature
│   │   └── shared/            ← Reusable widgets and extensions
│   └── pubspec.yaml
│
├── backend/                   ← REST API (Node.js + Fastify)
│   └── src/
│       ├── routes/            ← quotes, vault, profile, map, challenges...
│       ├── plugins/           ← device ID middleware
│       └── db/
│           ├── migrations/    ← SQL schema
│           └── seed.js        ← 5,500 philosophical quotes seeder
│
├── frontend_legacy/           ← Original React/Vite web app (reference only)
│
├── ARCHITECTURE.md            ← Full system architecture
├── CONTRIBUTING.md            ← How to contribute
├── ROADMAP.md                 ← Product and technical roadmap
├── SCRUM.md                   ← Sprint history and backlog
└── .env.example               ← Environment variables reference
```

---

## Quick Start — Backend

```bash
# 1. Install dependencies
cd backend
npm install

# 2. Configure environment
cp ../.env.example .env
# Fill in SUPABASE_URL and SUPABASE_ANON_KEY

# 3. Run the schema migration
# Open Supabase SQL Editor and run:
# backend/src/db/migrations/001_initial.sql

# 4. Seed 5,500 philosophical quotes
node src/db/seed.js

# 5. Start the server
npm run dev
# → http://localhost:3000

# 6. Verify
curl http://localhost:3000/health
# → { "status": "ok" }
```

---

## Quick Start — Flutter App

**Prerequisites:** Flutter SDK 3.x installed ([install guide](https://docs.flutter.dev/get-started/install))

```bash
# 1. Install dependencies
cd flutter_app
flutter pub get

# 2. Check setup
flutter doctor

# 3. List available devices
flutter devices

# 4. Run on emulator or physical device
flutter run

# Build release APK
flutter build apk --release

# Build for iOS (requires macOS + Xcode)
flutter build ios --release
```

---

## Environment Variables

Copy `.env.example` to `.env` in the root and in `backend/`:

| Variable | Description |
|---|---|
| `SUPABASE_URL` | Your Supabase project URL |
| `SUPABASE_ANON_KEY` | Supabase anon/public API key |
| `PORT` | Backend port (default: 3000) |
| `ALLOWED_ORIGIN` | CORS allowed origin |
| `API_BASE_URL` | Backend URL used by Flutter |
| `PREMIUM_BASE_PRICE_USD` | Base price for premium unlock |
| `DONATION_LINK` | External donation URL |
| `APP_DEFAULT_LANGUAGE` | Default language (`en` or `es`) |

---

## API Endpoints

| Method | Path | Description |
|---|---|---|
| GET | `/health` | Server health check |
| GET | `/quotes/feed` | Adaptive philosophical feed |
| POST | `/quotes/:id/like` | Like or unlike a quote |
| GET | `/vault` | User's saved quotes |
| POST | `/vault` | Save a quote to vault |
| DELETE | `/vault/:id` | Remove from vault |
| GET | `/stats` | Streak and reflection counts |
| POST | `/profile` | Save onboarding profile |
| GET | `/profile` | Get user profile |
| POST | `/swipes` | Record swipe event |
| GET | `/challenges/today` | Today's daily challenge |
| POST | `/challenges/:id/progress` | Update challenge progress |
| GET | `/map` | Philosophy map scores |
| POST | `/map/snapshot` | Save evolution snapshot |
| GET | `/premium/status` | Premium status |
| POST | `/premium/unlock` | Unlock premium |

---

## Roadmap Summary

- **Phase 1–3** ✅ MVP, backend, Flutter migration
- **Phase 4** 🔄 Philosophy map, evolution tracking
- **Phase 5** 🔜 Premium, donations, content packs
- **Phase 6** 📅 Scale to 100k users
- **Phase 7** 📅 Scale to 1M+ users

See [ROADMAP.md](ROADMAP.md) for the full plan.

---

## Contributing

We welcome contributions from developers, content curators, and philosophers.

See [CONTRIBUTING.md](CONTRIBUTING.md) for setup instructions, branch conventions, and code standards.

---

## License

MIT License — see [LICENSE](LICENSE) for details.

---

<p align="center">
  <em>"The impediment to action advances action. What stands in the way becomes the way."</em><br/>
  <strong>— Marcus Aurelius</strong>
</p>
