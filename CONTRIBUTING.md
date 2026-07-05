# 🛠️ Developer Contribution Guidelines — QuickMed

Welcome! This guide outlines the development workflow, coding standards, state management practices, and styling protocols required when contributing to the QuickMed project.

---

## 💻 Environment Setup

### 1. Requirements
* Flutter SDK (`>=3.22.x` / Dart `>=3.4.x`)
* Firebase CLI & Supabase CLI configured locally.

### 2. Initialization
Ensure dependencies are fetched and the codebase is verified:
```bash
flutter pub get
flutter analyze
```

---

## 🎨 Figma Fidelity & Styling Standards

QuickMed focuses heavily on matching design mockups precisely. The repository enforces strict rules on layout, typography, and color tokens:

### 1. Responsive Typography & Sizing
To maintain a responsive layout across various screen widths (optimized for the 375pt base width), **do not hardcode double values for font sizes or primary layout sizes**. Instead:
* Import `package:quick_med/utils/screen_size.dart`.
* Use the `.fs` extension for font scaling (e.g., `18.fs` or `context.fs(18)`).
* Use context size utilities: `context.sw` (screen width), `context.sh` (screen height).

*Example:*
```dart
import 'package:quick_med/utils/screen_size.dart';

Widget build(BuildContext context) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.fs),
    child: Text(
      'Search Medicines',
      style: TextStyle(
        fontSize: 16.fs,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
```

### 2. Design Tokens Over Raw Hex Codes
* **No Raw Colors:** Do not use inline hex colors (e.g., `Color(0xFF23E492)`) in UI widgets.
* **Standard Tokens:** All design colors must use the `AppColors` token library defined in `lib/services/app_colors.dart`.
* **Token Registry:** 
  * Primary actions & branding: `AppColors.primary`
  * Body copy: `AppColors.textPrimary` and `AppColors.textSecondary`
  * Accents & errors: `AppColors.error`, `AppColors.success`, `AppColors.grey`

---

## 🧠 State Management & Data Patterns

The codebase employs **Flutter BLoC (Cubit)** to separate presentation from business logic.

### 1. Cubit/BLoC Rules
* **No Inline setState for Business Logic:** Screen-level files (such as cart actions, login verification, and search queries) must offload business logic to a dedicated Cubit. Page-level widgets should ideally be stateless shells that listen to and emit Cubit states.
* **Asynchronous Standard State:** Use the 4-phase `Status` enum from `lib/services/enum.dart` (`Status.initial`, `Status.loading`, `Status.success`, `Status.failure`) to model asynchronous bounds in your Cubit states.

### 2. Error Handling & Transactions
* **Database & Auth Operations:** Every client query to Supabase or Firebase must be wrapped inside a `try-catch` block.
* **Failure State Propagation:** If an operation fails, the error must be caught, and the Cubit must emit a state with `Status.failure` and a human-readable `errorMsg` or `error` string.

*Example:*
```dart
try {
  emit(state.copyWith(status: Status.loading));
  final response = await Supabase.instance.client.auth.signInWithOtp(phone: phone);
  emit(state.copyWith(status: Status.success));
} catch (e) {
  emit(state.copyWith(
    status: Status.failure,
    errorMsg: 'Verification failed. Please try again.',
  ));
}
```

---

## 🚀 Git & PR Workflow

Before submitting a Pull Request (PR), ensure you run the verification pipeline:

1. **Format Code:**
   Ensure Dart formatting is applied consistently:
   ```bash
   dart format .
   ```
2. **Linting and Analysis:**
   Ensure there are zero analyzer issues or warnings:
   ```bash
   flutter analyze
   ```
3. **Commit Messages:**
   Commit messages should follow semantic conventions (e.g., `feat: add prescription upload button`, `fix: correct otp resend timer`).
