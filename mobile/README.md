# Smooth Mobile App

**Offline-first prototype** — all data lives in a local SQLite database. No backend or internet connection required. Ideal for APK delivery to non-technical clients.

## Demo account

| Email | Password |
|-------|----------|
| `demo@smooth.app` | `demo1234` |

Additional seeded accounts (same password `demo1234`): teachers, client, service providers — see `database_seeder.dart`.

## What's pre-loaded

On first launch the app automatically seeds:

- **8 courses** with curriculum (Flutter course has full modules + lesson progress for demo user)
- **5 marketplace services**
- **5 job postings**
- **5 educational games**
- **10 users** (learners, teachers, clients, freelancers)
- **Gamification** — demo user has 420 coins, level 5, 7-day streak

## Run / build APK

```bash
flutter pub get
flutter run

# Release APK
flutter build apk --release
```

APK output: `build/app/outputs/flutter-apk/app-release.apk`

## Architecture

```
lib/
├── shared/data/database/   # SQLite schema, seeder, AppDatabase
├── shared/providers/       # Riverpod providers (read from DB)
└── features/               # UI screens
```

Data flow: **UI → Riverpod → AppDatabase (SQLite)** — no network calls.

## Backend (optional)

The NestJS backend in `../backend/` is **not required** for the APK. It remains available for a future cloud-connected version.
