# Architecture Overview

## High-Level System

```mermaid
flowchart TB
    subgraph clients [Clients]
        Flutter[Flutter App]
    end

    subgraph backend [Backend - NestJS]
        API[REST API /api/v1]
        Auth[Auth Module]
        Courses[Courses Module]
        Market[Marketplace Module]
        Jobs[Jobs Module]
        Book[Bookings Module]
        Game[Gamification Module]
        AI[AI Assistant Module]
        Admin[Admin Module]
    end

    subgraph infra [Infrastructure]
        PG[(PostgreSQL)]
        S3[Cloud Storage]
        FCM[Firebase FCM]
        LLM[OpenAI-compatible API]
    end

    Flutter --> API
    API --> Auth
    API --> Courses
    API --> Market
    API --> Jobs
    API --> Book
    API rate --> Game
    API --> AI
    API --> Admin
    Auth --> PG
    Courses --> PG
    Market --> PG
    Jobs --> PG
    Book --> PG
    Game --> PG
    AI --> LLM
    Courses --> S3
    Market --> S3
    API --> FCM
```

## Flutter Architecture (Feature-First + Clean Layers)

```
lib/
├── main.dart                 # Entry point
├── app.dart                  # MaterialApp + ProviderScope
├── core/
│   ├── config/               # Environment, API base URL
│   ├── constants/            # App-wide constants
│   ├── router/               # go_router routes & guards
│   ├── theme/                # Colors, typography, ThemeData
│   └── utils/                # Extensions, formatters
├── shared/
│   ├── models/               # Shared DTOs / entities
│   ├── services/             # HTTP client, storage, auth token
│   ├── providers/            # Global Riverpod providers
│   └── widgets/              # Reusable UI component library
└── features/
    └── {feature}/
        ├── data/             # Repositories, API calls, mock data
        ├── domain/           # Entities, repository interfaces
        └── presentation/     # Screens, widgets, providers
```

### State Management — Riverpod

| Pattern | Usage |
|---------|-------|
| `Provider` | Stateless services (ApiClient, Theme) |
| `StateNotifierProvider` | Auth session, gamification stats |
| `FutureProvider` | One-shot async (course detail) |
| `StreamProvider` | Real-time (future: chat) |
| `family` | Parameterized providers (course by id) |
}

### Navigation — go_router

- **Auth guard**: redirect unauthenticated users to `/welcome`
- **Role guard**: teacher-only routes under `/teacher/*`
- **Shell route**: bottom nav for main tabs

## Backend Architecture (NestJS Modular)

```
src/
├── main.ts
├── app.module.ts
├── common/           # Guards, decorators, filters, pipes
├── config/           # ConfigModule + env validation
├── prisma/           # PrismaService
└── modules/
    ├── auth/
    ├── users/
    ├── courses/
    ├── marketplace/
    ├── bookings/
    ├── jobs/
    ├── gamification/
    ├── community/
    ├── ai/
    ├── search/
    └── admin/
```

Each module follows:

```
module/
├── {name}.module.ts
├── {name}.controller.ts
├── {name}.service.ts
└── dto/
```

## Authentication Flow

```mermaid
sequenceDiagram
    participant App as Flutter App
    participant API as NestJS API
    participant Google as Google OAuth
    participant DB as PostgreSQL

    App->>API: POST /auth/register {email, password, role}
    API->>DB: Create user + profile + wallet
    API-->>App: {accessToken, refreshToken, user}

    App->>Google: Google Sign-In
    Google-->>App: idToken
    App->>API: POST /auth/google {idToken}
    API->>Google: Verify token
    API->>DB: Upsert user
    API-->>App: {accessToken, refreshToken, user}

    App->>API: GET /users/me (Authorization: Bearer)
    API-->>App: User profile + gamification
}
```

Tokens:

- **Access token**: JWT, 15 min, sent in `Authorization: Bearer`
- **Refresh token**: JWT, 7 days, stored securely; `POST /auth/refresh`

## Payment Architecture (Future-Ready)

```
Order → PaymentIntent (provider-agnostic)
         ├── stripe (ERATION (future)
         ├── paypal (future)
         └── manual/admin (prototype)
```

`PaymentProvider` interface in backend; courses store `priceCents` + `currency`; purchases create `Enrollment` on success webhook.

## Scalability Notes

- Stateless API → horizontal scaling behind load balancer
- PostgreSQL read replicas for search-heavy endpoints
- Redis (future) for session cache, rate limits, leaderboards
- CDN for media from cloud storage
- FCM topic subscriptions per user role
