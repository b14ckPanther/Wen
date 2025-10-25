# Wen Admin Portal Plan

## Goals
- Provide a browser-based onboarding and moderation console for Wen staff.
- Support Firebase Authentication (Google SSO) + role checks.
- Surface Firestore data (businesses, users) for quick review and action stubs.
- Deploy via Firebase Hosting alongside the mobile backend.

## Architecture
- **Frontend**: Next.js (app router) hosted in `infra/hosting/web`.
- **Auth**: Firebase Web SDK + Google provider (limited to staff Google accounts via console restrictions).
- **Data**: Firestore `businesses`, `users` collections, read-only in the initial milestone.
- **Routing**:
  - `/` – Sign-in landing page.
  - `/dashboard` – Admin home with tables & upcoming tasks.
  - Future routes: `/onboarding` (wizard), `/businesses/[id]`, `/analytics`.

## Flow
1. Staff visits `/` and authenticates via Google.
2. Auth state persists client-side; authorized users are routed to `/dashboard`.
3. Dashboard lists latest businesses/users (with plan/role badges) and placeholder actions (approve/ban etc.).
4. Hosting build outputs static bundle; Cloud Run/Functions provide APIs later if needed.

## Roadmap
- Milestone G2 (current): Sign-in, dashboard layout, Firestore reads.
- Milestone G3: Implement moderation actions (approve business, change plan) via callable Cloud Functions.
- Milestone G4: Owner onboarding wizard + analytics widgets.

## Non-goals (for now)
- Server-side rendering of protected routes (handled on client).
- Complex role management UI (use Firestore manually for now).
- Styling beyond bespoke CSS (Tailwind optional later).
