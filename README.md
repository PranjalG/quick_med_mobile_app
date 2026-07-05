# 💊 QuickMed — On-Demand Medicine Delivery App

QuickMed is a high-fidelity, production-grade Flutter mobile application designed for on-demand medicine delivery targeting Indian users (initially optimized for Kota City, Rajasthan). The app features pixel-perfect UI designs matched directly to Figma mockups and communicates with a hybrid Firebase and Supabase backend for secure authentication, user profiles, and order management.

---

## 📖 Project Documentation Index
Before contributing or building, please review our specialized documentation:
* **[PRODUCT.md](file:///Users/pranjalgaur/development/Flutter_projects/quick_med_mobile_app-main/PRODUCT.md):** Detailed product vision, target user personas, core customer journeys, and feature roadmaps.
* **[ARCHITECTURE.md](file:///Users/pranjalgaur/development/Flutter_projects/quick_med_mobile_app-main/ARCHITECTURE.md):** Code patterns, state management specs (Cubit/BLoC), GoRouter navigation flows, and database schemas.
* **[CONTRIBUTING.md](file:///Users/pranjalgaur/development/Flutter_projects/quick_med_mobile_app-main/CONTRIBUTING.md):** Step-by-step dev setup instructions, styling token rules, responsive scaling (`context.fs`), and PR checklists.

---

## ✨ Features

* **🚀 Smart Splash & Transitions:** Seamless branded animation sequence guided by `SplashCubit`.
* **📱 Fully Interactive Onboarding:** Multi-slide product feature carousel showing value propositions.
* **🔒 Dual Authentication Flows:** Support for secure traditional Email/Password Auth (Firebase) and Mobile OTP Verification (Supabase).
* **🏠 High-Fidelity Home Dashboard:** Includes promotional scroll banners, categorizations, and live discount cards.
* **🔍 Salt & Brand Search:** Search for medications by brand names or active generic salt compositions.
* **🛒 Persistent Cart Management:** Quantity adjustments and real-time total bill calculations (items + platform fee + rider fee).
* **🗺️ Live Map Tracking:** Realistic GPS marker tracking of delivery partners moving towards customers on Google Maps.

---

## 🛠️ Tech Stack

* **Framework:** Flutter (Target version `3.22.x` / Dart `3.4.x`)
* **State Management:** Flutter BLoC & Cubits (Strict separation of concern layers)
* **Backend Engines:** Firebase Auth (Email Sign-ups) + Supabase Flutter (OTP and general database client)
* **Routing:** GoRouter (Declarative navigation)
* **Styling Tokens:** Responsive context scaling (`context.fs`) mapped with `AppColors` and `ThemeColours` design tokens.

---

## 🚀 Setup & Installation

### 1. Prerequisites
Ensure you have the Flutter SDK configured on your system:
```bash
flutter --version
```

### 2. Configure Backend Credentials
1. **Supabase Setup:** Create a configuration file at `lib/services/supabase_config.dart` containing your database URL and anon publishable key:
   ```dart
   class SupabaseConfig {
     static const String url = 'https://your-project-id.supabase.co';
     static const String publishableKey = 'your-anon-publishable-key';
   }
   ```
2. **Firebase Setup:** Register your application platforms inside the Firebase console and generate `lib/firebase_options.dart` via the FlutterFire CLI:
   ```bash
   flutterfire configure
   ```

### 3. Fetch Dependencies
Install package references:
```bash
flutter pub get
```

### 4. Build & Run
To run the app locally on a connected emulator or physical device:
```bash
# Debug Mode
flutter run

# Release Mode
flutter run --release
```

---

## 🎨 Figma Alignment Rules
This repository strictly enforces the following UI/UX guidelines:
1. **Figma Fidelity:** Layout elements must match the Figma design margins exactly.
2. **Zero Raw Hex Colors:** All colors must refer to `AppColors` or `ThemeColours` tokens.
3. **No Hardcoded Font Sizes:** All text components must scale with the screen width using context-relative scaling (`context.fs`).
4. **BLoC Separation:** Avoid using stateful widgets where state can instead be managed within a Cubit.
