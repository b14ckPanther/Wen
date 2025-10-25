# Wen Admin Portal (web)

Next.js app that powers the Wen staff dashboard. Features:
- Google Sign-In (Firebase Auth)
- Firestore-backed business & user summaries
- Gradient UI with reusable admin shell

## Setup

```bash
cd infra/hosting/web
npm install
cp .env.example .env.local  # fill with Firebase web config
npm run dev
```

## Build & Deploy

```bash
npm run build
# copy the out/ directory into infra/firebase/web-dist or deploy directly with CI
cd ../../firebase
firebase deploy --only hosting --project wen-dev-noor
```

## Notes
- Authentication currently allows any Google account; restrict domain in Firebase console.
- Moderation actions are read-only stubs for now (see `docs/admin-portal-plan.md` for roadmap).
