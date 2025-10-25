# Wen Mobile App

Flutter client for the Wen directory. Key tasks to get a dev instance running:

## Prerequisites
- Flutter 3.35.4 (channel stable) with Dart 3.9.2
- Android Studio/Xcode with simulators configured
- Firebase CLI (`firebase`) and Google Maps API keys (Android + iOS)

## Google Maps API keys
Google Maps widgets require platform API keys. Replace the placeholders with real keys **that stay out of source control**:

### Android
1. Create/obtain an Android Maps API key.
2. Copy `apps/mobile/android/app/src/main/res/values/google_maps_api.xml.example` to
   `apps/mobile/android/app/src/main/res/values/google_maps_api.xml` and replace the placeholder value.
3. The manifest already references `@string/google_maps_api_key` and requests coarse/fine location.

### iOS
1. Create/obtain an iOS Maps API key.
2. Open `apps/mobile/ios/Runner/Info.plist` (local only) and set the value for `GOOGLE_MAPS_API_KEY`.
3. `AppDelegate.swift` reads the key and feeds it to `GMSServices.provideAPIKey`.

The repo tracks `*.example` placeholders; copy them locally and never commit real keys.

## Location & permissions
- The mobile app now relies on `geolocator` for live location. `ACCESS_FINE_LOCATION`/`ACCESS_COARSE_LOCATION` are already declared in `AndroidManifest.xml`, and `Info.plist` contains the `NSLocationWhenInUseUsageDescription` copy required by Apple.
- On Android 12+, ensure the runtime prompt is granted; denied-forever paths expose a Settings shortcut in-app.
- When running in simulators, provide a custom location (e.g., via iOS Simulator > Features > Location > Custom Location) to test radius filtering.
- Automated widget tests can enable `kForceLocationTestMode` / `kForceExploreTestMode` to bypass geolocation calls.

## Firebase configuration
- Copy the example configs shipped with the repo:
  - `apps/mobile/android/app/google-services.json.example` → `apps/mobile/android/app/google-services.json`
  - `apps/mobile/ios/Runner/GoogleService-Info.plist.example` → `apps/mobile/ios/Runner/GoogleService-Info.plist`
- Fill in your project-specific values (auth keys, app IDs, SHA-1s). These real files are ignored by git.
- To run against the local emulator suite, pass Dart defines when running the app:
  ```bash
  flutter run \
    --dart-define=USE_FIREBASE_EMULATOR=true \
    --dart-define=FIREBASE_EMULATOR_HOST=localhost
  ```
  Optional port overrides:
  - `FIREBASE_FIRESTORE_PORT` (default `8080`)
  - `FIREBASE_AUTH_PORT` (default `9099`)
  - `FIREBASE_STORAGE_PORT` (default `9199`)

## Useful commands
| Task | Command |
|------|---------|
| Install dependencies | `flutter pub get` |
| Generate localization files | `flutter gen-l10n` |
| Analyze code | `flutter analyze` |
| Run tests | `flutter test` |
| Launch emulator suite | `cd infra/firebase && firebase emulators:start --import=./.data --export-on-exit` |

## Authentication & roles
- Use the **Profile** tab to sign in or create an account (owners can tick the switch during signup or upgrade later).
- Password reset is available from the “Forgot password?” link inside the sign-in form.
- Once marked as an owner, the **Manage my business** button opens the owner dashboard where you can edit details and upload images.
- Owners see an **Upgrade plan** button that opens a payments stub describing Standard/Premium tiers. Actual checkout will be wired in a future milestone.
- For the detailed payments architecture plan, see `docs/payments-plan.md`.
- The Search tab includes a **Ask Wen AI** beta section that returns mocked recommendations. See `docs/ai-search-plan.md` for the full architecture roadmap.
- To point the app at the Cloud Run AI service, build with
  `--dart-define=USE_AI_SEARCH_API=true --dart-define=AI_SEARCH_BASE_URL=https://<service-url>`.
- Theme and language toggles live on the Profile tab; preferences persist locally via SharedPreferences and update the UI instantly (light/dark + Arabic/English).

## Project structure quick reference
- `lib/app/` – router, theming, localization wiring
- `lib/features/businesses/` – Firestore business repository, providers, widgets
- `lib/features/explore/` – Google Map and list view for nearby businesses
- `lib/features/search/` – Keyword/category search with pagination
- `infra/firebase/` – rules, indexes, emulator config, seed script

Refer to the main repo README for broader Wen platform setup steps.

## AI search backend (work in progress)
- Cloud Functions scaffold lives under `infra/functions/src/ai/`.
- Run `npm install` and `npm run build` inside `infra/functions` to compile TypeScript.
- `firebase emulators:start --only functions` will simulate the Firestore trigger and scheduled job (currently mocked).
- See `docs/ai-search-plan.md` for the ingestion pipeline roadmap.
