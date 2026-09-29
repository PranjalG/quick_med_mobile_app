---
inclusion: always
---

# QuickMed — Tech Stack & Commands

## Stack

- **Framework:** Flutter (target `3.22.x` / Dart `3.4.x`). SDK constraint:
  `>=3.4.3 <4.0.0`.
- **UI entry:** `MaterialApp.router` in `lib/main.dart`.
- **State management:** `flutter_bloc` / `bloc` with **Cubits and Blocs**,
  `equatable` for value equality. No other state approach — do not introduce
  Provider/Riverpod/GetX/setState-for-shared-state.
- **Routing:** `go_router` (declarative), configured in
  `lib/services/router.dart`.
- **Auth:** `firebase_auth` (phone OTP + email/password).
- **Data / realtime:** `supabase_flutter` (Postgres, Storage, Realtime).
- **Maps:** `google_maps_flutter` for live tracking.
- **Typography:** `google_fonts` (Montserrat, Palanquin Dark).
- **Icons:** `font_awesome_flutter`, `cupertino_icons`.
- **Misc:** `flutter_svg`, `url_launcher`.
- **Lints:** `flutter_lints ^3.0.0` via `analysis_options.yaml`.

`hydrated_bloc` / `path_provider` appear only in commented-out code in
`main.dart`; they are **not** in `pubspec.yaml`. Do not assume persistence is
available.

## Backend architecture (dual backend)

Firebase owns **identity**; Supabase owns **data**. They are bridged so that
Supabase requests run as the signed-in Firebase user:

- `main.dart` initializes Firebase first, then calls
  `SupabaseConfig.initialize()`.
- `SupabaseConfig.initialize` (`lib/services/supabase_config.dart`) passes an
  `accessToken` callback returning `FirebaseAuth.instance.currentUser?.getIdToken()`.
  Every Supabase Postgres/Storage/Realtime call therefore carries the Firebase
  ID token, so **RLS policies are keyed on the Firebase uid**.
- Convention: Supabase `profiles.id` == Firebase `uid`.
- **No Firestore** is used for app data. Do not add Firestore usage.

Supabase tables/channels referenced in code: `profiles`, `medicines`,
`active_deliveries`, and the Realtime broadcast channel `delivery:<orderId>`.

## Setup

Backend credentials are required before the app runs:

1. **Supabase** — `lib/services/supabase_config.dart` holds `url` and
   `publishableKey`. (Committed in this repo; treat as publishable/anon only —
   never put a `service_role` key here.)
2. **Firebase** — `lib/firebase_options.dart` generated via
   `flutterfire configure`.
3. Fetch deps: `flutter pub get`

> Build note: `main.dart` imports `lib/services/app_theme.dart` (`AppTheme.light`),
> which is missing from the repo. Restore that file (or replace the reference
> with a local `ThemeData`) before the app will compile.

## Common commands

```bash
# Install dependencies
flutter pub get

# Static analysis / lint (run before considering a change done)
flutter analyze

# Format
dart format .

# Run tests once (no watch)
flutter test

# Run the app
flutter run                 # debug
flutter run --release       # release

# Upgrade dependencies (careful — pinned ranges)
flutter pub outdated
```

On Windows PowerShell, chain commands with `;` rather than `&&`.

## Verification expectation

After any code change, run `flutter analyze` and, when logic changes, the
relevant `flutter test`. Do not report a change as complete on the basis of a
command exiting 0 alone — confirm the analyzer is clean and behavior matches
the request.
