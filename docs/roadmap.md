# Development Roadmap

Phased delivery for Smooth prototype → MVP → production.

---

## Phase 0 — Foundation (Weeks 1–2) ✅ Prototype

**Goal**: Architecture, design system, auth skeleton, core navigation.

| Milestone | Deliverables |
|-----------|--------------|
| M0.1 | Monorepo structure, README, docs (schema, API, wireframes) |
| M0.2 | Flutter feature architecture + Riverpod + go_router |
| M0.3 | Design tokens, theme, reusable component library |
| M0.4 | NestJS bootstrap, Prisma schema, JWT auth |
| M0.5 | Welcome, role selection, login/register UI |
| M0.6 | Main shell with bottom navigation |

**Exit criteria**: User can register, log in (mock or API), navigate all main tabs with placeholder content.

---

## Phase 1 — Learning Core (Weeks 3–5)

| Milestone | Deliverables |
|-----------|--------------|
| M1.1 | Course CRUD API + seed data |
| M1.2 | Course library UI (filters, search) |
| M1.3 | Course detail + curriculum |
| M1.4 | Enrollment + progress tracking |
| M1.5 | Free resources (YouTube embed, external links/T>
| M1.6 | Bookmarks + continue watching |

**Exit criteria**: Learner browses, enrolls, tracks progress on free courses.

---

## Phase 2 — Teachers & Marketplace (Weeks 6–8)

| Milestone | Deliverables |
|-----------|--------------|
| M2.1 | Teacher profile pages (public) |
| M2.2 | Teacher dashboard (course list, stats stub) |
| M2.3 | Service listings API + UI |
| M2.4 | Client browse + service detail + quote request |
| M2.5 | Reviews & ratings |
| M2.6 | Follow instructors |

**Exit criteria**: Teacher publishes course draft; client browses services and views profiles.

---

## Phase 3 — Gamification & Games (Weeks 9–10)

| Milestone | Deliverables |
|-----------|--------------|
| M3.1 | Wallet, XP, levels, streaks backend |
| M3.2 | Daily login rewards |
| M3.3 | Quiz completion → coins |
| M3.4 | Educational games section (2–3 mini-games) |
| M3.5 | Achievements + badges UI |
| M3.6 | Leaderboard |

**Exit criteria**: Completing actions awards coins/XP visible in profile.

---

## Phase 4 — AI Assistant (Weeks 11–12)

| Milestone | Deliverables |
|-----------|--------------|
| M4.1 | AI usage limits + coin unlock |
| M4.2 | Chat UI with history |
| M4.3 | OpenAI-compatible provider integration |
| M4.4 | Context-aware prompts (course, goals) |
| M4.5 | Quick actions (study plan, quiz gen stub) |

**Exit criteria**: Learner chats with AI; daily limit enforced; coins unlock extras.

---

## Phase 5 — Booking & Jobs (Weeks 13–15)

| Milestone | Deliverables |
|-----------|--------------|
| M5.1 | Booking model + availability slots |
| M5.2 | Mentoring / service booking flow |
| M5.3 | Classroom reservation (training center) |
| M5.4 | Job board CRUD + search filters |
| M5.5 | Job applications |
| M5.6 | Booking & job notifications (FCM) |

**Exit criteria**: End-to-end booking confirmation; job search and apply.

---

## Phase 6 — Premium & Payments (Weeks 16–18)

| Milestone | Deliverables |
|-----------|--------------|
| M6.1 | Paid course purchase flow (architecture) |
| M6.2 | Payment provider adapter (Stripe first) |
| M6.3 | Platform commission calculation |
| M6.4 | Enrollment unlock on payment webhook |
| M6.5 | Teacher payout ledger (stub) |

**Exit criteria**: Test-mode purchase unlocks premium course.

---

## Phase 7 — Admin & Polish (Weeks 19–21)

| Milestone | Deliverables |
|-----------|--------------|
| M7.1 | Admin REST endpoints complete |
| M7.2 | Admin web dashboard (optional React/Nest) |
| M7.3 | Content moderation queue |
| M7.4 | Analytics overview |
| M7.5 | Global search (PostgreSQL FTS) |
| M7.6 | Performance pass, accessibility audit |

---

## Phase 8 — Production Hardening (Weeks 22+)

- E2E tests (Patrol / integration_test)
- CI/CD (GitHub Actions)
- Error monitoring (Sentry)
- Rate limiting, Redis cache
- Certificate generation (PDF)
- i18n / localization
- Tablet & web responsive layouts

---

## Risk & Dependencies

| Risk | Mitigation |
|------|------------|
| Scope creep | Strict phase gates; prototype defers payments & deep AI |
| Media storage costs | CDN + transcoding pipeline in Phase 6+ |
| AI API costs | Daily caps + coin economy from day one |
| Multi-role UX complexity | Role-based home tab config |

---

## Team Suggestion (MVP)

| Role | Focus |
|------|-------|
| 1 Flutter dev | UI, state, features |
| 1 Backend dev | NestJS, Prisma, integrations |
| 1 Designer | Brand, component specs (Phase 0–1) |
| 0.5 DevOps | CI, staging, DB (Phase 7+) |
