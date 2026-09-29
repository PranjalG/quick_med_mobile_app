---
inclusion: always
---

# QuickMed — Coding Conventions

## Naming

- Files: `snake_case.dart`. Classes: `PascalCase`. Members: `camelCase`.
- `App*` prefix marks the **canonical** design system (`AppColors`,
  `AppTextStyles`). Non-prefixed `ThemeColours` / `TextStyles` are legacy.
- Cubit/Bloc files follow `<name>_cubit.dart` / `<name>_bloc.dart` with matching
  `<name>_state.dart` (and `<name>_event.dart` for Blocs).
- Supabase columns are `snake_case`; Dart model fields are `camelCase`. Do the
  translation inside the model's `fromJson`/`toJson` (see
  `models/medicine_model.dart`).

## Styling — enforced UI rules

These are hard rules for the app and are checked in review:

1. **Figma fidelity** — layout margins/spacing must match the Figma design.
2. **No raw hex colors.** Never write `Color(0x...)` or `Colors.*` at a call
   site. Use a semantic token from `AppColors`. If a needed color is missing,
   add a token to `app_colors.dart` rather than inlining it.
3. **No hardcoded font sizes.** All text scales with screen width via the
   `context.fs(size)` extension (`utils/screen_size.dart`, base width 375).
   Prefer named styles from `AppTextStyles`; when composing inline, still size
   with `context.fs(...)` and color with `AppColors`.
4. **Prefer Cubit over StatefulWidget** for anything beyond trivial local
   animation/controller state. Shared or business state lives in a Cubit/Bloc.

Responsive helpers (from `ScreenExt` on `BuildContext`):
- `context.sw` / `context.sh` — screen width / height.
- `context.fs(size)` — width-relative font/size scaling.

## State management (flutter_bloc)

Follow the **new feature pattern** (see `lib/features/auth/`):

- States extend `Equatable`; model each distinct state as its own class
  (`XxxInitial`, `XxxLoading`, `XxxSuccess`, `XxxFailure`, …) rather than one
  class with a status field. Keep `props` cheap (e.g. key `Success` on
  `user.uid`, not the whole object).
- Cubit constructor injects its repositories with defaults
  (`AuthRepository? repo` → `repo ?? AuthRepository()`) so tests can pass fakes.
- Each async method: `emit(<progress state>)` → call repo → on success emit the
  result state; `catch` the typed domain exception and emit a failure state with
  a user-facing `message`; add a catch-all for unexpected errors.
- In views: provide the Cubit with `BlocProvider` in the `Screen`; consume with
  `BlocConsumer` (listener for navigation/snackbars, builder for UI). Read
  actions via `context.read<Cubit>()`, reactive values via
  `context.watch<Cubit>().state`. A Dart 3 `switch` expression over the state
  hierarchy is the idiomatic builder.

The legacy `enum Status { initial, loading, success, failure }`
(`services/enum.dart`) belongs to the older single-state pattern — don't use it
in new feature slices.

## Repositories & error handling

- Repositories wrap the backend SDK (`firebase_auth`, `supabase_flutter`).
  **Widgets never call Supabase/Firebase directly** — always go
  view → cubit → repository.
- Repositories throw **typed domain exceptions** (see
  `features/auth/repository/auth_exceptions.dart`:
  `AuthException` and subclasses like `InvalidPhoneNumberException`,
  `OtpVerificationFailedException`, `OtpTimeoutException`,
  `NetworkAuthException`). Map raw SDK errors (e.g.
  `FirebaseAuthException.code`) to these inside the repository.
- **Do not** adopt `Either<Failure, T>` / dartz / fpdart unless the whole
  project moves to it. Cubits catch exceptions and emit failure states.

## Data-service resilience

`medicine_service`, `profile_service`, and `live_tracking_repository` all fall
back to local mock data / temp-file cache / simulated GPS when Supabase is
unavailable. Keep this offline-degradation behavior when editing or adding data
services — fail soft, don't crash the UI.

## Navigation

- Use `go_router` via `context.go(...)` for replace-style flow transitions
  (splash → home, auth → home) and `context.push(...)` for stacking (e.g.
  landing → search). Register every route in `lib/services/router.dart`.

## Domain-specific rules

- Phone numbers normalize to Indian E.164: `+91` followed by `[6-9]` and 9
  digits. Reuse the validation/normalization in `AuthRepository`.
- Currency is INR; use the ₹ symbol from `services/strings.dart`.
- Default city is `Kota`.

## Do NOT

- Do not introduce a new state-management library.
- Do not use Firebase Firestore for app data (Supabase is the data store).
- Do not add raw hex colors or hardcoded font sizes.
- Do not put a Supabase `service_role` key in client code.
- Do not add new tokens to `theme_colours.dart` or new styles to
  `text_styles.dart` — those are legacy.
