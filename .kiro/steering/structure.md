---
inclusion: always
---

# QuickMed — Project Structure

The codebase is **mid-migration** between two architectures. New work should
follow the **feature-first** pattern under `lib/features/`; the older
horizontally-layered code under `lib/blocs`, `lib/screens`, `lib/services`,
`lib/models`, `lib/custom_components` is legacy and being migrated incrementally.

## Directory map

```
lib/
├── main.dart                  # Entry: init Firebase → Supabase, MaterialApp.router
├── firebase_options.dart      # Generated FlutterFire config
│
├── features/                  # NEW — feature-first vertical slices (preferred)
│   └── auth/
│       ├── bloc/              # phone_auth_cubit.dart, phone_auth_state.dart
│       ├── repository/        # auth_repository.dart, profile_repository.dart,
│       │                      #   auth_exceptions.dart
│       └── view/              # auth_screen.dart, phone_entry_screen.dart,
│                              #   otp_entry_screen.dart
│
├── blocs/                     # LEGACY — one folder per bloc/cubit
│   ├── email_auth_cubit/  home_bloc/  landing_screen_bloc/
│   ├── live_tracking_cubit/  login_bloc/  onboarding_cubit/
│   ├── phone_auth_cubit/      # duplicate of the new features/auth cubit — legacy
│   ├── profile_cubit/  splash_cubit/
│
├── screens/                   # LEGACY — screen widgets grouped by feature
│   ├── splash_screen.dart  onboarding_screen.dart  home_screen.dart
│   ├── landing_screen.dart  search_screen.dart
│   ├── login/ (login_screen, logo_widget, profile_setup_screen)
│   ├── profile/profile_screen.dart
│   ├── cart/ (cart_screen, cart_item_card, quantity_selector)
│   └── tracking/live_tracking_screen.dart
│
├── services/                  # Catch-all: config, data services, AND design system
│   ├── router.dart            # go_router config (all routes)
│   ├── supabase_config.dart   # Supabase init + Firebase-token bridge
│   ├── supabase_service.dart  # static client getter
│   ├── auth.dart              # email/password FirebaseAuth wrapper (legacy)
│   ├── auth_service.dart      # static identity accessors (currentUserId, …)
│   ├── medicine_service.dart  # Supabase `medicines` query + local fallback
│   ├── profile_service.dart   # UserProfile model + Supabase/temp-file cache
│   ├── live_tracking_repository.dart  # Realtime GPS + simulated fallback
│   ├── enum.dart              # Status, UserLogin enums
│   ├── strings.dart           # UI copy constants
│   ├── app_colors.dart        # CANONICAL palette + Material 3 ColorScheme
│   ├── theme_colours.dart     # LEGACY palette (scheduled for deletion)
│   ├── app_text_styles.dart   # CANONICAL text styles (GoogleFonts + tokens)
│   ├── text_styles.dart       # legacy/plainer text styles
│   └── app_theme.dart         # MISSING — imported by main.dart, not in repo
│
├── models/
│   └── medicine_model.dart    # hand-written fromJson/toJson (snake_case ↔ camelCase)
│
├── custom_components/         # 16 reusable widgets (buttons, fields, navbar, …)
└── utils/
    └── screen_size.dart       # ScreenExt: context.sw / context.sh / context.fs
```

## The two architectures

**NEW — feature-first (use this for new work).** A vertical slice
`lib/features/<feature>/`:
- `bloc/` — a Cubit + an Equatable state hierarchy (one class per state).
- `repository/` — repositories wrapping Firebase/Supabase, with a domain
  exception hierarchy; injected into the cubit with sensible defaults for
  testability.
- `view/` — a `Screen` widget that provides the Cubit via `BlocProvider`, and a
  `View` widget that consumes it (`BlocConsumer` / `context.read` /
  `context.watch`).

Only `auth` has been migrated so far.

**LEGACY — horizontal layers.** `blocs/` + `screens/` + `services/` +
`models/` + `custom_components/`. The `services/` folder mixes real services,
config, and the design system together.

## Placement rules for new code

- New feature → create `lib/features/<feature>/{bloc,repository,view}/`.
- Shared model → prefer a `lib/data/models/` (feature-first target) or, for now,
  `lib/models/`. Keep hand-written `fromJson`/`toJson` translating snake_case DB
  columns to camelCase Dart.
- Data access → a repository that wraps `supabase_flutter`; never call Supabase
  from a widget.
- Design tokens → `AppColors` / `AppTextStyles` only (see conventions steering).
- Route → add to `lib/services/router.dart`.

## Legacy vs canonical quick reference

| Use this (canonical) | Not this (legacy) |
|----------------------|-------------------|
| `AppColors`          | `ThemeColours`    |
| `AppTextStyles`      | `TextStyles`      |
| `lib/features/auth/…`| `lib/blocs/phone_auth_cubit/…` |
| `AuthRepository` (phone OTP) | `services/auth.dart` (email/pw) |
