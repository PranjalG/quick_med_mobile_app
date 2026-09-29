---
inclusion: always
---

# QuickMed — Product Overview

QuickMed is a high-fidelity, production-grade Flutter mobile app for **on-demand
medicine delivery**, targeting Indian users and initially optimized for **Kota
City, Rajasthan**. The UI is matched pixel-for-pixel to Figma mockups and is
backed by a hybrid Firebase + Supabase backend.

Package name: `quick_med`. App title: "Quick Med mobile app".

## Who it's for

- **Customers** — browse, search, and order medicines for fast local delivery.
- (Planned) **Delivery riders** — a second role in the same app. Role-based
  routing is a stated goal but is **not implemented yet**. Today the app is
  customer-only.

## Core customer journey

1. **Splash** — branded animation sequence (`SplashCubit`).
2. **Onboarding** — multi-slide value-proposition carousel.
3. **Auth** — dual sign-in:
   - Mobile OTP verification (phone number → OTP), the live/primary flow.
   - Email/password (legacy helper, `services/auth.dart`).
4. **Profile setup** — capture name, Kota area, address after first login.
5. **Home / landing dashboard** — promo banners, categories, discount cards.
6. **Search** — find medicines by brand name or active generic salt.
7. **Cart** — quantity adjustments and a live bill (items + platform fee +
   rider fee).
8. **Live tracking** — GPS marker of the delivery partner moving toward the
   customer on Google Maps.

## Feature status (as built in the repo)

| Area | Status |
|------|--------|
| Splash, onboarding | Scaffolded |
| Phone OTP auth (Firebase) | Working, migrated to `lib/features/auth/` |
| Email/password auth | Legacy helper present (`services/auth.dart`) |
| Profile setup + profiles table | Working with local-cache fallback |
| Home / landing, search, cart | Scaffolded UI |
| Live tracking | Working with simulated-GPS fallback |
| Rider role / role-based routing | Not started |
| Cart/auth persistence (`hydrated_bloc`) | Referenced in comments only, not enabled |

## Product principles

- **Figma fidelity first.** Layout margins and spacing must match the design.
- **Graceful degradation.** Data services (medicines, profile, tracking) fall
  back to local mock/cache data when Supabase is unreachable, so the app
  degrades instead of failing. Preserve this behavior when extending them.
- **India-specific defaults.** Phone numbers are Indian E.164 (`+91XXXXXXXXXX`),
  currency is INR (₹), and the default city is `Kota`.

## Known scope gaps (verify before relying on them)

- `lib/services/app_theme.dart` (`AppTheme.light`) is **imported by `main.dart`
  but does not exist in the repo** — the app will not compile until it is
  restored or the reference is replaced. Flag this early in any build attempt.
- Backend credentials in `lib/services/supabase_config.dart` are committed
  publishable/anon keys; Firebase config comes from `firebase_options.dart`.
