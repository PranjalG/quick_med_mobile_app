import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Application-wide [ThemeData], built from the canonical [AppColors] tokens.
///
/// Referenced by `main.dart` as `theme: AppTheme.light`. Uses
/// [AppColors.lightScheme] (an explicit Material 3 scheme, not `fromSeed`) so
/// the theme stays aligned with the brand palette.
class AppTheme {
  const AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: AppColors.lightScheme,
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
      );
}
