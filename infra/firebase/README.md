# Firebase Dev Setup

This directory houses Firebase configuration for the Wen development environment.

- `.firebaserc` — points to the dev project (`wen-dev-noor`); adjust per environment as needed.
- `firebase.json` — emulator + hosting config shared across the repo.
- `firestore.rules`, `storage.rules`, `firestore.indexes.json` — authoritative security policies and indexes.
- `seed/` — lightweight Firestore seeding helpers for the emulator/dev project.

Typical local workflow:

```sh
# Authenticate once
firebase login

# Target the dev project ID
firebase use <your-dev-project-id>

# Start emulators for Auth, Firestore, Storage, Hosting UI
firebase emulators:start --project <your-dev-project-id> --import=./infra/firebase/.data --export-on-exit
```

> The `--import` path keeps emulator state between runs. Create the `.data` folder or change the path as preferred.

### Deploying Firestore indexes

Whenever you adjust `firestore.indexes.json` (for example, to support the geohash + updatedAt queries used by the mobile search flow), redeploy the composite indexes:

```sh
cd infra/firebase
firebase deploy --only firestore:indexes --project <your-dev-project-id>
```

Index builds can take a few minutes on first deploy; Firestore will serve existing data once the build is complete.

### Seeding sample data

1. Install seed dependencies:

   ```sh
   cd infra/firebase/seed
   npm install
   ```

2. With the emulators running (or targeting the dev project with proper credentials), seed Firestore:

   ```sh
   FIREBASE_PROJECT_ID=<your-dev-project-id> FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 npm run seed
   ```

   Omit `FIRESTORE_EMULATOR_HOST` if you want to write directly to the live `wen-dev-noor` environment (requires adequate IAM permissions).

### Hosting stub

The placeholder web admin lives under `infra/hosting/web` (Next.js). To build and deploy it:

```sh
cd infra/hosting/web
npm install
npm run build  # outputs static files to out/

cd ../../firebase
firebase deploy --only hosting --project wen-dev-noor
```

The Firebase Hosting config references the pre-built `out/` directory produced by `npm run build`.
