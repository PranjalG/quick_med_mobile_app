# 💊 QuickMed — On-Demand Medicine Delivery App

QuickMed is a high-fidelity, production-grade Flutter mobile application designed for on-demand medicine delivery targeting Indian users (initially optimized for Kota City, Rajasthan). The app features pixel-perfect UI designs matched directly to Figma mockups and communicates with a Supabase backend for secure authentication, user profiles, and order management.

---

## ✨ Features

- **🚀 Smart Splash & Transitions:** Guided by `SplashCubit` delay states.
- **📱 Fully Interactive Onboarding:** Multi-slide product feature show-off using native cached image assets.
- **🔒 OTP Mobile Authentication:** Clean authentication flow powered by Supabase Phone Auth.
- **🏠 High-Fidelity Home Dashboard:** Includes active promo banners, categorization grid, and real-time live discount tags.
- **🔍 Quick Salt & Brand Search:** Instant, local filtering and result sorting.
- **🛒 Persistent Cart Management:** Seamless add-to-cart operations with automated cost calculations.
- **🗺️ Live Map Tracking:** Location selectors and delivery routing via Google Maps integration.

---

## 🛠️ Tech Stack & Architecture

- **Framework:** Flutter (target version `3.22.x` / Dart `3.4.x`)
- **Backend-as-a-Service:** Supabase (Database, Auth, Storage)
- **State Management:** Flutter BLoC (Cubit) to strictly separate business logic from UI representation.
- **Navigation:** GoRouter (declarative routing system)
- **Assets Support:** Optimised vector structures and cached raster image layers.
- **Styling Tokens:** Unified styling constants mapping (`AppColors` & `AppTextStyles` tokens) with context-based font size scaling (`context.fs`).

---

## 🚀 Setup & Installation

### 1. Prerequisites
Ensure you have the Flutter SDK configured on your system:
```bash
flutter --version
```

### 2. Configure Supabase Credentials
Create a configuration file at `lib/services/supabase_config.dart` containing your Supabase URL and anon credentials:
```dart
class SupabaseConfig {
  static const String url = 'https://your-project-id.supabase.co';
  static const String anonKey = 'your-anon-publishable-key';
}
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

## 📁 Directory Structure

```text
lib/
├── blocs/               # Cubit state controllers
│   ├── onboarding_cubit/
│   ├── phone_login_cubit/
│   └── splash_cubit/
├── custom_components/   # Common reusable UI widgets
├── screens/             # Screen UI layers
│   ├── cart/
│   ├── login/
│   ├── profile/
│   ├── landing_screen.dart
│   ├── search_screen.dart
│   └── splash_screen.dart
├── services/            # Supabase config, API clients, and theme tokens
│   ├── app_colors.dart
│   ├── app_text_styles.dart
│   ├── supabase_config.dart
│   └── supabase_service.dart
└── utils/               # App utilities and context helpers
```

---

## 🎨 Figma Alignment Rules
This repository strictly enforces the following design and architecture guidelines:
1. **Figma Fidelity:** Pixel-perfect matching to the Figma design mockups.
2. **Design Tokens:** Zero raw hex codes. Every color uses `AppColors.xxx`.
3. **Typography:** Zero hardcoded font sizes. Every text element uses `AppTextStyles.xxx` styled with screen-relative context scaling (`context.fs`).
4. **BLoC Separation:** Zero `StatefulWidgets` where state can instead be managed through a BLoC/Cubit.
5. **Supabase Integrity:** Strict try-catch error handling around every Supabase client transaction.
