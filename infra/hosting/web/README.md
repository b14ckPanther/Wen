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

The `.env.example` file lists all required Firebase web config keys. Copy it to `.env.local` (for local development) or `.env.production` when building manually, and fill in the values from the Firebase console.

## Build & Deploy

```bash
npm run build
# copy the static export into Firebase hosting folder
rm -rf ../../firebase/web-dist && mkdir -p ../../firebase/web-dist
cp -R out/. ../../firebase/web-dist/
cd ../../firebase
firebase deploy --only hosting --project wen-dev-noor
```

### GitHub Actions secrets

The CI workflows expect these repository secrets so the Next.js build can initialize Firebase:

- `NEXT_PUBLIC_FIREBASE_API_KEY`
- `NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN`
- `NEXT_PUBLIC_FIREBASE_PROJECT_ID`
- `NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET`
- `NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID`
- `NEXT_PUBLIC_FIREBASE_APP_ID`
- `NEXT_PUBLIC_FIREBASE_MEASUREMENT_ID`

## Notes
- Authentication currently allows any Google account; restrict domain in Firebase console.
- Admin actions (approvals & role updates) call Firebase Functions / Firestore directly; see `app/dashboard/page.tsx`.
