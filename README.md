# Smooth — Learning & Freelance Ecosystem

A cross-platform prototype connecting **learners**, **teachers/freelancers**, and **clients** in one ecosystem: e-learning, marketplace, AI assistant, gamification, community, job board, and booking.

## Stack

| Layer | Technology |
|-------|------------|
| Mobile / Web UI | Flutter + Riverpod + go_router |
| Backend | NestJS (Node.js) |
| Database | PostgreSQL + Prisma ORM |
| Auth | JWT + Google Sign-In |
| Storage | Cloud Storage (S3-compatible) |
| AI | OpenAI-compatible API |
| Push | Firebase Cloud Messaging |

## Repository Structure

```
Smooth/
├── mobile/          # Flutter app (feature-based architecture)
├── backend/         # NestJS REST API
├── docs/            # Schema, API design, wireframes, roadmap
└── README.md
```

## Quick Start (APK demo — no backend needed)

```bash
cd mobile
flutter pub get
flutter run
# or build APK:
flutter build apk --release
```

**Demo login:** `demo@smooth.app` / `demo1234`

All courses, jobs, services, and games are pre-seeded in a local SQLite database on first launch.

### Backend (optional — for future cloud version)

```bash
cd backend
cp .env.example .env   # requires PostgreSQL running
npm install
npx prisma migrate dev
npm run start:dev
```

## Documentation

- [Database Schema](docs/database-schema.md)
- [REST API Design](docs/api-design.md)
- [Wireframes](docs/wireframes.md)
- [Development Roadmap](docs/roadmap.md)
- [Architecture](docs/architecture.md)

## User Roles

- **Learner** — free & premium courses, AI assistant, games, gamification
- **Teacher / Freelancer** — courses, mentoring, services, portfolio
- **Client** — browse, hire, book, request quotes

## Prototype Scope

This is a **prototype** delivered as a **standalone APK**:

- All data stored locally in SQLite (no server setup for clients)
- AI chatbot uses templated responses with daily limits tracked in SQLite
- Payments are not integrated
- Push notifications are stubbed
- NestJS backend is optional scaffolding for a future cloud version

## License

Proprietary — all rights reserved.
