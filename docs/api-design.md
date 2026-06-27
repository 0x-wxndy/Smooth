# REST API Design

Base URL: `/api/v1`  
Auth: `Authorization: Bearer <access_token>` unless marked **Public**

## Response Envelope

```json
{
  "data": { },
  "meta": { "page": 1, "limit": 20, "total": 100 }
}
```

Errors:

```json
{
  "statusCode": 400,
  "message": "Validation failed",
  "errors": [{ "field": "email", "message": "Invalid email" }]
}
```

---

## Authentication

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/auth/register` | Public | Register with email/password + role |
| POST | `/auth/login` | Public | Email/password login |
| POST | `/auth/google` | Public | Google Sign-In (idToken) |
| POST | `/auth/refresh` | Public | Refresh access token |
| POST | `/auth/logout` | User | Invalidate refresh token |
| GET | `/auth/me` | User | Current user + profiles |

### POST /auth/register

```json
{
  "email": "learner@example.com",
  "password": "securePass123",
  "displayName": "Alex Learner",
  "role": "LEARNER"
}
```

### POST /auth/google

```json
{ "idToken": "<google_id_token>" }
```

Response (register/login/google):

```json
{
  "data": {
    "accessToken": "eyJ...",
    "refreshToken": "eyJ...",
    "user": {
      "id": "uuid",
      "email": "...",
      "role": "LEARNER",
      "displayName": "...",
      "avatarUrl": null
    }
  }
}
```

---

## Users & Profiles

| Method | Path | Description |
|--------|------|-------------|
| GET | `/users/me` | Full profile + gamification |
| PATCH | `/users/me` | Update display name, avatar |
| GET | `/users/:id/profile` | Public teacher/freelancer profile |
| PATCH | `/users/me/teacher-profile` | Teacher profile fields |
| GET | `/users/teachers` | List teachers (filters: skill, category) |

---

## Courses

| Method | Path | Description |
|--------|------|-------------|
| GET | `/courses` | List courses (filters: category, difficulty, free, search) |
| GET | `/courses/:id` | Course detail + modules |
| POST | `/courses` | Teacher: create course |
| PATCH | `/courses/:id` | Teacher: update course |
| POST | `/courses/:id/enroll` | Enroll (free or after purchase) |
| GET | `/courses/:id/progress` | Learner progress |
| PATCH | `/courses/:id/progress` | Update last lesson / percent |
| POST | `/courses/:id/bookmark` | Toggle bookmark |
| GET | `/courses/recommended` | Personalized recommendations |

Query params: `?category=SOFTWARE_DEV&difficulty=BEGINNER&isFree=true&sort=popular&page=1&limit=20`

---

## Quizzes

| Method | Path | Description |
|--------|------|-------------|
| GET | `/courses/:courseId/quizzes/:quizId` | Quiz with questions |
| POST | `/courses/:courseId/quizzes/:quizId/submit` | Submit answers → score + coins |

---

## Marketplace (Services)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/services` | List services |
| GET | `/services/:id` | Service detail |
| POST | `/services` | Freelancer: create service |
| PATCH | `/services/:id` | Update service |
| POST | `/services/:id/request` | Client: project request |

---

## Bookings

| Method | Path | Description |
|--------|------|-------------|
| GET | `/bookings` | User's bookings |
| POST | `/bookings` | Create reservation |
| PATCH | `/bookings/:id` | Update status (confirm/cancel) |
| GET | `/bookings/slots` | Available slots (provider + date) |

```json
{
  "bookingType": "MENTORING",
  "providerId": "uuid",
  "scheduledAt": "2026-07-15T14:00:00Z",
  "durationMinutes": 60,
  "notes": "React hooks review"
}
```

---

## Jobs

| Method | Path | Description |
|--------|------|-------------|
| GET | `/jobs` | List job postings |
| GET | `/jobs/:id` | Job detail |
| POST | `/jobs` | Company/admin: post job |
| POST | `/jobs/:id/apply` | Submit application |

Filters: `category`, `location`, `remote`, `salaryMin`, `experienceLevel`, `type`

---

## Gamification

| Method | Path | Description |
|--------|------|-------------|
| GET | `/gamification/wallet` | Coins, XP, level, streak |
| GET | `/gamification/achievements` | User achievements |
| GET | `/gamification/leaderboard` | Top learners (period=week\|month\|all) |
| POST | `/gamification/daily-login` | Claim daily login reward |

---

## Educational Games

| Method | Path | Description |
|--------|------|-------------|
| GET | `/games` | List mini-games |
| GET | `/games/:id` | Game detail |
| POST | `/games/:id/complete` | Submit score → rewards |

---

## AI Assistant

| Method | Path | Description |
|--------|------|-------------|
| GET | `/ai/usage` | Daily usage + remaining |
| POST | `/ai/chat` | Send message (rate-limited) |
| POST | `/ai/coins/unlock` | Spend coins for extra interactions |

```json
{
  "message": "What should I learn for mobile development?",
  "context": { "courseId": "optional-uuid" }
}
```

Prototype returns templated responses; production wires OpenAI-compatible API.

---

## Community

| Method | Path | Description |
|--------|------|-------------|
| POST | `/reviews` | Create review |
| GET | `/reviews?targetType=COURSE&targetId=` | List reviews |
| POST | `/follow/:userId` | Follow teacher |
| DELETE | `/follow/:userId` | Unfollow |
| GET | `/feed` | Activity feed (future) |

---

## Search

| Method | Path | Description |
|--------|------|-------------|
| GET | `/search?q=&type=all` | Global search |

`type`: courses | teachers | services | jobs | all

---

## Admin

Prefix: `/admin` — requires `ADMIN` role.

| Method | Path | Description |
|--------|------|-------------|
| GET | `/admin/users` | List users |
| PATCH | `/admin/users/:id/status` | Activate/deactivate |
| PATCH | `/admin/teachers/:id/approve` | Approve teacher |
| GET | `/admin/courses/pending` | Moderation queue |
| PATCH | `/admin/courses/:id/status` | Approve/reject |
| GET | `/admin/analytics/overview` | Dashboard metrics |
| PATCH | `/admin/settings/ai-limits` | Daily AI cap |
| PATCH | `/admin/settings/commission` | Platform commission % |

---

## Webhooks (Future)

| Method | Path | Description |
|--------|------|-------------|
| POST | `/webhooks/payments/:provider` | Payment confirmation |
