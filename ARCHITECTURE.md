# quick_med — Architecture & Specification

> On-demand medicine delivery app (Flutter). This document is reverse-engineered
> from the source as of the current state of the repo. It captures the actual
> architecture, the inferred product specification, and the known gaps between
> the two.

---

## 1. Overview

**quick_med** is a Flutter mobile app for ordering medicines and having them
delivered "in a whoosh" through a local-area delivery network. The current build
is **UI-complete but data-mocked**: screens, navigation, theming, and state
management are wired end-to-end, but the medicine catalog, cart, order history,
and live tracking are all driven by hard-coded / randomly-generated data rather
than a real backend. The only live integration is **Firebase Auth** (email/password).

- **Package name:** `quick_med`
- **Version:** `1.0.0+1`
- **Dart SDK:** `>=3.4.3 <4.0.0` (built on Flutter 3.22.2 per README)
- **Design base width:** 375pt (iPhone standard) — used for responsive scaling.

---

## 2. Tech Stack

| Concern | Choice |
|---|---|
| UI | Flutter, Material 3 (`useMaterial3: true`), seed color `lightGreenAccent` |
| State management | `bloc` / `flutter_bloc` (v9) + `equatable` |
| Navigation | `go_router` (v15) — declarative routing |
| Auth | `firebase_core` + `firebase_auth` (email/password) |
| Maps | `google_maps_flutter` (live delivery tracking UI) |
| Fonts / Icons | `google_fonts`, `font_awesome_flutter`, `cupertino_icons` |
| Persistence | `hydrated_bloc` — **declared in README but commented out** in `main.dart` |
| Lints | `flutter_lints` ^3.0.0 |

---

## 3. Directory Structure

```
lib/
├── main.dart                     # App entry, Firebase init, MaterialApp.router
├── firebase_options.dart         # FlutterFire generated config (all platforms)
│
├── blocs/                        # BLoC layer (3 feature blocs)
│   ├── login_bloc/               # Auth state, sign-in/up toggle, validation
│   ├── home_bloc/                # Bottom-nav tab index
│   └── landing_screen_bloc/      # Medicine list load + search (+ Medicine model)
│
├── screens/                      # Feature screens (UI)
│   ├── splash_screen.dart        # 3s branded splash → /login
│   ├── login/                    # login_screen, logo_widget
│   ├── home_screen.dart          # TabBarView shell (Landing/Profile/Cart)
│   ├── landing_screen.dart       # Medicine grid + search (the "store" tab)
│   ├── cart/                     # cart_screen, cart_item_card, quantity_selector
│   └── profile/                  # profile_screen (user info + order history)
│
├── custom_components/            # 13 reusable themed widgets
│   ├── gradient_button.dart      bordered_button.dart   bordered_icon_button.dart
│   ├── bordered_textfield.dart   themed_text_field.dart suffix_action_text_field.dart
│   ├── floating_text_box.dart    floating_navbar.dart   themed_card.dart
│   ├── themed_floating_button.dart loading_indicator.dart data_error_widget.dart
│   └── alert_message_box.dart
│
├── services/                     # Cross-cutting helpers (no real "service" layer)
│   ├── auth.dart                 # Firebase Auth wrapper
│   ├── router.dart               # GoRouter route table
│   ├── enum.dart                 # Status, UserLogin enums
│   ├── strings.dart              # Static UI strings
│   ├── text_styles.dart          # Responsive TextStyle factory
│   └── theme_colours.dart        # Color palette constants
│
└── utils/
    └── screen_size.dart          # BuildContext extension: sw, sh, fs(size)

assets/
├── images/   (Logo.png, Gradient.png, paracetamol.png, levocitrizine.jpg,
│              profile_woman.png, …)
└── icons/    (home.png, profile_icon.png, cart.png)
```

---

## 4. Architectural Pattern

The app follows a **BLoC (Business Logic Component) presentation architecture**:

```
   Widget (Screen)  --dispatch event-->  Bloc  --emit state-->  Widget rebuilds
                                           |
                                           └── calls Auth() / generates mock data
```

- **Events** are immutable `Equatable` classes (`part of` the bloc file).
- **States** are immutable `Equatable` classes with `copyWith`.
- Each screen creates its bloc locally via `BlocProvider(create: ...)` and reads
  it with `BlocConsumer` (builder + listener). Blocs are **not** provided at the
  app root — they are screen-scoped and short-lived.
- There is **no repository / data-provider layer** in use. `main.dart` has a
  commented-out `LandingScreenRepository(LandingScreenDataProvider())`, signaling
  the intended-but-unbuilt data layer. Mock data is generated inside the bloc.

### Status enum (shared async convention)
`services/enum.dart` defines a 4-state machine reused across blocs:
`Status { initial, loading, success, failure }` — screens switch UI on this
(loading spinner / grid / error widget).

---

## 5. Navigation & Routing

Routing is centralized in `services/router.dart` (`GoRouter`):

| Path | Screen | Notes |
|---|---|---|
| `/` | `SplashScreen` | Initial route |
| `/login` | `LoginScreen` | |
| `/home_screen` | `HomeScreen` | Tab shell |

**Flow:**

```
SplashScreen (3s delay)
      │ context.go('/login')
      ▼
LoginScreen  ──(Status.success │ Google/Apple tap)──►  /home_screen
      ▲                                                     │
      └── BackButtonClick resets sign-in/up panel           ▼
                                            HomeScreen (TabBarView + FloatingNavbar)
                                            ├─ tab 0: LandingScreen  (store / search)
                                            ├─ tab 1: ProfileScreen  (profile + history)
                                            └─ tab 2: CartScreen      (map + cart + bill)
```

> Note: `LandingScreen`, `ProfileScreen`, and `CartScreen` are **tabs inside
> `HomeScreen`**, not GoRouter routes. Tab switching is driven by `HomeBloc`,
> synced bidirectionally with a `TabController` and the custom `FloatingNavbar`.

---

## 6. State Management (per-bloc spec)

### 6.1 LoginBloc  (`blocs/login_bloc/`)
Drives the auth screen — a single screen that morphs between a landing panel, a
sign-up form, and a social-login panel.

**State fields:** `email`, `pswd`, `loginResponseStatus (Status)`, `errorMsg`,
`userLogin (bool — has the user entered the auth panel)`,
`userLoginType (UserLogin.signIn|signUp)`, `loginSuccess`, `emailErrorText`.

**Events & behavior:**
- `SignInClickEvent` / `SignUpClickEvent` — flip `userLogin` and set login type.
- `BackButtonClick` — return to the landing panel.
- `EmailChangeEvent` / `PasswordChangeEvent` — capture field input.
- `EmailValidateEvent` — regex validate `^[\w.-]+@[\w.-]+\.\w+$`, set `emailErrorText`.
- `SignUpEvent` — calls `Auth.createUserWithEmailAndPassword`; on a new user emits
  `Status.success` + `loginSuccess`, on error emits `Status.failure` + `errorMsg`.

**Gap:** `SignInWithEmailEvent` and `SignInWithGoogleEvent` events are declared
but **not registered** in the bloc. `Auth.signInWithEmailAndPassword` exists but is
**never invoked** — the only real auth path is *sign-up*. Google/Apple buttons
bypass auth entirely and `context.go('/home_screen')` directly.

### 6.2 HomeBloc  (`blocs/home_bloc/`)
Trivial bloc holding the active bottom-nav tab.
- **State:** `tabIndex (int, default 0)`.
- **Event:** `TabIndexChangeEvent(index)` — emitted by both the `TabController`
  listener and the `FloatingNavbar.onTap`, keeping them in sync.

### 6.3 LandingScreenBloc  (`blocs/landing_screen_bloc/`)
Owns the medicine catalog for the store tab.
- **State:** `medicineDataResponseStatus (Status)`, `error`, `medicineList`,
  `filteredList`.
- **Events:**
  - `LoadMedicinesEvent` — emits `loading`, **waits 4s (simulated network)**, then
    generates **30 random `Medicine` objects** (name cycles
    Levocitrizine/Azithromicine/Paracetamol; price = `Random().nextInt(41)`),
    emits `success`.
  - `SearchMedicinesEvent(query)` — case-insensitive `contains` filter into
    `filteredList`.
- **Embedded model:** `Medicine { String medicineName; num price; }` — defined
  inside the state file (no shared domain model).

---

## 7. Screen Specifications

### Splash (`splash_screen.dart`)
Branded launch screen: a `Gradient.png` hero (45% height) with a rounded white
overlay and centered `Logo.png`. Auto-navigates to `/login` after 3 seconds.

### Login (`login/login_screen.dart`, `logo_widget.dart`)
Single scrollable screen over a gradient background, state-driven into 3 modes:
1. **Landing panel** — tagline + "Sign in" (gradient) and "Sign up" (bordered).
2. **Sign-up form** — email/password fields with inline validation, submits `SignUpEvent`.
3. **Social panel** — "Sign in with Google" / "Sign in with Apple" + back button.
On `Status.success`, listener routes to `/home_screen`. Shows `LoadingIndicator`
while `Status.loading`.

### Home (`home_screen.dart`)
Stateful shell with a `TabController(length: 3)` + `HomeBloc`. Body is a
`TabBarView` of `[LandingScreen, ProfileScreen, CartScreen]`; bottom bar is the
custom `FloatingNavbar`. Tab index is kept in sync through the bloc.

### Landing / Store (`landing_screen.dart`)
- Title (`Strings.landingScreenTitle`) + notification icon.
- Search bar (`SuffixActionTextField`) → dispatches `SearchMedicinesEvent`.
- Body switches on `Status`: `LoadingIndicator` / 3-column `GridView` of
  `ThemedCard` (medicine image + name + ₹price) / `DataErrorWidget`.

### Cart (`cart/`)  — *most feature-rich screen, fully mocked*
- **Top half:** `GoogleMap` with delivery-partner & customer markers and a
  connecting green `Polyline`. Hard-coded Kota coordinates
  (`25.2138,75.8648` partner / `25.2155,75.8700` customer). `simulateLiveTracking()`
  moves the partner marker and animates the camera. Header chips show
  `Order #QM1021` and `₹349`.
- **Bottom half:** delivery-partner card (Ramesh Kumar, call button), editable
  cart list (`CartItemCard` + `QuantitySelector`, increment/decrement/delete via
  `setState`), bill summary (Item Total + ₹20 delivery + ₹5 platform fee → "To Pay"),
  and a hard-coded delivery address.
- **Local model:** `CartItem { String name; int quantity; double price; }` with
  a seeded list of 3 items. This screen uses **plain `setState`, not a bloc.**

### Profile (`profile/profile_screen.dart`)
- Static user card (Anastasiya Rajguru, Nayapura Kota, masked phone) +
  `profile_woman.png`.
- `DraggableScrollableSheet` (0.6–0.9) listing **5 mock order cards** (id `#QM10n`,
  "Delivered" chip, item summary, ₹349, `12 Jan 2026`). Purely presentational.

---

## 8. Reusable Components (`custom_components/`)

| Component | Purpose |
|---|---|
| `gradient_button` | Primary CTA with gradient fill |
| `bordered_button` | Secondary/outline CTA, optional trailing icon |
| `bordered_icon_button` | Icon-only outline button (e.g. back) |
| `bordered_textfield` / `themed_text_field` / `suffix_action_text_field` | Themed inputs; the suffix variant fires an `onSearchPressed` callback |
| `floating_text_box` | Rounded info/tagline box |
| `floating_navbar` | Custom 3-item bottom nav (home/profile/cart PNG icons, pill highlight) |
| `themed_card` | Medicine card (random local image, title, ₹price) |
| `themed_floating_button` | FAB-style action |
| `loading_indicator` | Centered progress indicator |
| `data_error_widget` | Error/empty state for failed loads |
| `alert_message_box` | Inline alert/message |

---

## 9. Services, Theming & Utilities

- **`services/auth.dart`** — thin wrapper over `FirebaseAuth`:
  `currentUser`, `authStateChanges`, `signInWithEmailAndPassword`,
  `createUserWithEmailAndPassword`, `signOut`.
- **`services/theme_colours.dart`** — palette: greens (`lightGreen 53,232,139`,
  `darkGreen 21,190,119`), oranges, greys, plus error/warning/success.
- **`services/text_styles.dart`** — responsive `TextStyle` factory
  (`body`→`headline`) sized via `context.fs(...)`.
- **`services/strings.dart`** — static copy (rupee symbol, landing title, search
  hint, generic error).
- **`utils/screen_size.dart`** — `BuildContext` extension: `sw` (width), `sh`
  (height), `fs(size)` = `size * sw/375` for proportional scaling. **This is the
  backbone of the app's responsive layout** — most paddings/sizes are expressed
  as fractions of `sh`/`sw`.

---

## 10. Firebase

`firebase_options.dart` is FlutterFire-generated with configs for web, Android,
iOS, macOS, Windows (Linux unsupported). `main.dart` calls
`Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` before
`runApp`. Only **Auth** is used; no Firestore/Storage/Functions.

---

## 11. Inferred Product Specification

Reconstructed from the UI and data shapes, the app *intends* to support:

1. **Onboarding** — branded splash → authentication.
2. **Authentication** — email/password sign-up & sign-in, plus Google & Apple
   social login. (Currently: sign-up live; sign-in & social are stubs.)
3. **Medicine discovery** — browse a catalog grid and search medicines by name.
4. **Cart management** — add items, adjust quantities, remove items, view an
   itemized bill (item total + delivery fee + platform fee).
5. **Live order tracking** — map view of the delivery partner moving toward the
   customer, with partner contact and ETA.
6. **Profile & history** — user details and a list of past orders with status.
7. **Locale** — INR pricing (₹), targeted at Kota, Rajasthan (map coords + address).

---

## 12. Known Gaps / TODO (spec vs. implementation)

| Area | Current state |
|---|---|
| Catalog data | Randomly generated in `LandingScreenBloc`; no API/repository |
| Cart ↔ Catalog | Disconnected — "Add to cart" from the store does nothing; cart has its own seeded list |
| Cart state | Uses `setState`, not a bloc (inconsistent with the rest of the app) |
| Order history | Static 5-card mock in `ProfileScreen` |
| Live tracking | Mocked: hard-coded coords, manual `simulateLiveTracking()`, no real GPS/stream |
| Sign-in (email) | `Auth.signInWithEmailAndPassword` defined but never called; only sign-up works |
| Social login | Google/Apple buttons skip auth and route straight to home |
| Persistence | `hydrated_bloc` referenced in README but commented out in `main.dart` |
| Data layer | `LandingScreenRepository`/`DataProvider` scaffolded (commented) but unbuilt |
| Maps API key | Requires a Google Maps API key configured per-platform to render |
| Domain model | `Medicine` and `CartItem` are duplicated, screen-local models (no shared domain) |

---

## 13. Build & Run

```bash
flutter pub get
# Ensure Firebase config (firebase_options.dart) and a Google Maps API key are set
flutter run
```

Requires the Firebase project referenced by `firebase_options.dart` and a valid
Google Maps API key (Android `AndroidManifest.xml` / iOS `AppDelegate`) for the
Cart tab's map to render.
