---
inclusion: fileMatch
fileMatchPattern: 'lib/**/{repository,service,services,supabase*,auth*,*_repository,*_service}*.dart'
---

# QuickMed — Backend & Data Integration

Applies when working in services, repositories, or backend config.

## Dual-backend model

- **Firebase Auth = identity.** Phone OTP (primary) and email/password.
- **Supabase = data.** Postgres, Storage, Realtime.
- **Bridge:** `SupabaseConfig.initialize` (`lib/services/supabase_config.dart`)
  supplies an `accessToken` callback returning the current Firebase user's ID
  token. All Supabase calls run as that Firebase user, so **RLS is keyed on the
  Firebase uid**. Convention: `profiles.id == Firebase uid`.
- Init order matters: `Firebase.initializeApp` **then**
  `SupabaseConfig.initialize()` (already wired in `main.dart`).
- **No Firestore.** Never add `cloud_firestore`.

## Supabase objects referenced in code

| Object | Kind | Used by |
|--------|------|---------|
| `profiles` | table (id = firebase uid, `default_city='Kota'`) | `ProfileRepository.upsertOnLogin`, `profile_service` |
| `medicines` | table (`name`, `manufacturer`, `mrp`, `discounted_price`, `salt_id`, `prescription_required`) | `medicine_service` |
| `active_deliveries` | table | `live_tracking_repository` |
| `delivery:<orderId>` | Realtime broadcast channel | `live_tracking_repository` |

## Auth (phone OTP) — the canonical flow

- `AuthRepository` (`features/auth/repository/auth_repository.dart`) wraps
  `FirebaseAuth`, normalizes/validates Indian phone numbers
  (`+91[6-9]\d{9}`), and wraps the callback-based `verifyPhoneNumber` in a
  `Completer` with a ~60s timeout. It exposes `sendOtp`, `verifyOtp`,
  `resendOtp`, and tracks verification state internally.
- Raw `FirebaseAuthException.code`s (`invalid-phone-number`, `session-expired`,
  `invalid-verification-code`, `network-request-failed`) are mapped to typed
  `AuthException` subclasses. Callers only catch `AuthException` and read
  `.message`.
- On success, `PhoneAuthCubit._completeSignIn` upserts the Supabase `profiles`
  row via `ProfileRepository.upsertOnLogin(uid, phone)` before emitting success.
- `services/auth.dart` (email/password) and `services/auth_service.dart`
  (static `currentUserId` / `currentUserEmail` / `currentUserPhone` / `signOut`)
  are the identity accessors used elsewhere.

## Resilience pattern (keep this)

Data services degrade gracefully instead of throwing to the UI:

- `medicine_service.fetchMedicines(query)` — Supabase `.or(name.ilike…,
  manufacturer.ilike…)`; on any error returns a filtered hardcoded fallback list.
- `profile_service` — reads Supabase `profiles`, falls back to a temp-file JSON
  cache (`quick_med_profile_<uid>.json`); writes cache first, then best-effort
  Supabase upsert (does not rethrow on failure).
- `live_tracking_repository` — subscribes to the `delivery:<orderId>` Realtime
  channel; on failure/timeout runs a simulated Kota GPS path.

When adding/extending a data service, preserve this online-with-local-fallback
behavior.

## Security rules

- The key in `supabase_config.dart` must be the **publishable/anon** key only.
  Never commit or use a `service_role` key in client code.
- Assume **RLS is enabled** on all Supabase tables — never design around
  bypassing it.
- Models translate snake_case DB columns to camelCase in `fromJson`/`toJson`
  (see `medicine_model.dart`); keep that mapping in the model, not the repo.
