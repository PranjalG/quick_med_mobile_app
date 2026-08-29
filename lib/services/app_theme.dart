import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Spacing scale.
///
/// Replaces the ad-hoc `context.sh * 0.0XX` multipliers that were scattered
/// across the app. Percentage-of-screen-height spacing distorts badly on
/// tablets and short devices; fixed steps do not.
///
/// Proportional sizing is still legitimate for hero/splash sections that are
/// *meant* to occupy a share of the viewport — keep `context.sh` there.
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Standard horizontal page gutter.
  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(horizontal: lg);
}

/// Corner radii.
class AppRadius {
  const AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double pill = 999;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
}

/// Icon sizing steps.
///
/// Defined here in Phase 1; applied to call sites in Phase 3.
class AppIconSize {
  const AppIconSize._();

  static const double sm = 16;
  static const double md = 20;
  static const double lg = 24;
  static const double xl = 32;
}

/// Application theme.
///
/// Every visual default flows from here. Call sites should read
/// `Theme.of(context).textTheme.*` and `Theme.of(context).colorScheme.*`
/// rather than constructing `GoogleFonts...` or naming colours directly.
class AppTheme {
  const AppTheme._();

  /// Type scale, mapped onto the font sizes the app already used
  /// (10, 12, 13, 14, 15, 16, 18, 20, 22, 24, 42).
  static TextTheme _textTheme() {
    final base = GoogleFonts.montserratTextTheme();

    TextStyle style(
      TextStyle? from,
      double size,
      FontWeight weight, {
      Color color = AppColors.textPrimary,
      double? height,
    }) {
      return (from ?? const TextStyle()).copyWith(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      );
    }

    return base.copyWith(
      // Display — splash and hero numerals.
      displayLarge: style(base.displayLarge, 42, FontWeight.w700),
      displayMedium: style(base.displayMedium, 32, FontWeight.w700),
      displaySmall: style(base.displaySmall, 28, FontWeight.w600),
      // Headline — screen titles.
      headlineLarge: style(base.headlineLarge, 24, FontWeight.w700),
      headlineMedium: style(base.headlineMedium, 22, FontWeight.w700),
      headlineSmall: style(base.headlineSmall, 20, FontWeight.w600),
      // Title — section headers and card titles.
      titleLarge: style(base.titleLarge, 18, FontWeight.w600),
      titleMedium: style(base.titleMedium, 16, FontWeight.w600),
      titleSmall: style(base.titleSmall, 15, FontWeight.w600),
      // Body — the workhorse; 14 was by far the most common size.
      bodyLarge: style(base.bodyLarge, 14, FontWeight.w500, height: 1.4),
      bodyMedium: style(base.bodyMedium, 13, FontWeight.w400, height: 1.4),
      bodySmall: style(
        base.bodySmall,
        12,
        FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.4,
      ),
      // Label — buttons, chips, captions.
      labelLarge: style(base.labelLarge, 16, FontWeight.w600),
      labelMedium: style(base.labelMedium, 14, FontWeight.w500),
      labelSmall: style(
        base.labelSmall,
        10,
        FontWeight.w500,
        color: AppColors.textSecondary,
      ),
    );
  }

  static ThemeData get light {
    const scheme = AppColors.lightScheme;
    final text = _textTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      textTheme: text,
      primaryTextTheme: text,

      appBarTheme: AppBarThemeData(
        backgroundColor: AppColors.scaffoldBackground,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: text.titleLarge,
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: AppIconSize.lg,
        ),
      ),

      cardTheme: const CardThemeData(
        color: AppColors.cardBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        hintStyle: text.bodyLarge?.copyWith(color: AppColors.textSecondary),
        labelStyle: text.bodyLarge?.copyWith(color: AppColors.textSecondary),
        errorStyle: text.bodySmall?.copyWith(color: AppColors.error),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: AppColors.primaryDark, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: AppColors.disabled,
          disabledForegroundColor: AppColors.onDisabled,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          textStyle: text.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.inputBorder),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          textStyle: text.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: text.labelMedium,
        ),
      ),

      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: AppIconSize.lg,
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.inputBorder,
        thickness: 1,
        space: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.secondaryNavy,
        contentTextStyle: text.bodyLarge?.copyWith(color: AppColors.white),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryDark,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.scaffoldBackground,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyLarge,
      ),
    );
  }
}
