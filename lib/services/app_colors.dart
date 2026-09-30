import 'package:flutter/material.dart';

/// Canonical colour palette for QuickMed.
///
/// This is the **single source of truth** for colour in the app. Do not
/// introduce raw `Color(0x...)` literals or `Colors.*` constants at call
/// sites — add a semantic token here instead.
///
/// The legacy `ThemeColours` palette in `theme_colours.dart` is deprecated and
/// is being migrated onto the tokens below. See that file for the mapping.
class AppColors {
  const AppColors._();

  // ---------------------------------------------------------------------
  // Brand
  // ---------------------------------------------------------------------

  static const Color primary = Color(0xFFD6F3F4); // Primary (Light Mint/Aqua)
  static const Color primaryDark =
      Color(0xFF508991); // Support (Dusty Slate Blue)

  // ---------------------------------------------------------------------
  // Logo / brand green
  //
  // Sampled directly from the QuickMedD app logo (the green hexagon +
  // teal/white capsule). The mark runs from a bright lime highlight through a
  // mid emerald to a teal shadow side, so these tokens describe that
  // green→teal family. Use them for brand surfaces that should echo the logo
  // (splash, onboarding accents, the login wordmark).
  // ---------------------------------------------------------------------

  /// Representative mid lime-emerald — the logo's core green.
  static const Color brandGreen = Color(0xFF3CBB4C);

  /// Bright highlight face of the hexagon.
  static const Color brandGreenLight = Color(0xFF5FD46E);

  /// Deeper green where the mark turns toward teal.
  static const Color brandGreenDark = Color(0xFF1E9E6A);

  /// Teal shadow side of the logo / the darker capsule half.
  static const Color brandTeal = Color(0xFF009078);

  /// Deep teal-green for text on light backgrounds (WCAG-safe on white).
  static const Color brandGreenDeep = Color(0xFF00695A);

  /// Logo gradient (highlight → teal shadow), matching the hexagon shading.
  static const Color brandGradientStart = brandGreenLight; // #5FD46E
  static const Color brandGradientEnd = brandTeal; // #009078

  // Secondary Colors
  static const Color secondaryBlue = Color(0xFF74B3CE); // Medium Blue
  static const Color secondaryTeal = Color(0xFF004346); // Dark Teal
  static const Color secondaryNavy = Color(0xFF172A3A); // Midnight Navy

  // ---------------------------------------------------------------------
  // Semantic Light Mode Colors
  // ---------------------------------------------------------------------

  static const Color scaffoldBackground = Color(0xFFFFFFFF); // White background
  static const Color cardBackground =
      Color(0xFFF3F8F9); // Soft Mint/Ice Blue Card Background
  static const Color inputFill = Color(0xFFFFFFFF); // White Input Field
  static const Color inputBorder =
      Color(0xFFD1E3E5); // Soft Mint/Teal Gray Border

  static const Color textPrimary = Color(0xFF172A3A); // Midnight Navy Text
  static const Color textSecondary = Color(0xFF508991); // Dusty Slate Blue Text
  static const Color grey = Color(0xFF74B3CE); // Medium Blue / Grey
  static const Color white = Colors.white;
  static const Color error = Color(0xFFD31818);
  static const Color success = Color(0xFF004346); // Dark Teal

  // ---------------------------------------------------------------------
  // Tokens added during the ThemeColours consolidation (Phase 1)
  // ---------------------------------------------------------------------

  /// Neutral greys. `ThemeColours` carried its own neutral ramp that was
  /// unrelated to the navy/teal text colours; these fill that gap without
  /// reintroducing a second palette.
  static const Color neutralDark =
      Color(0xFF555555); // was ThemeColours.textGrey
  static const Color neutral =
      Color(0xFF777777); // was ThemeColours.textLightGrey
  static const Color neutralLight =
      Color(0xFFB4B4B4); // was ThemeColours.lightGrey

  /// Warning / caution state. No equivalent existed in this palette.
  static const Color warning = Color(0xFFFFD234);
  static const Color onWarning = secondaryNavy;

  /// Accent used by the "themed"/"suffix action" text fields, which are
  /// currently the only orange surfaces in the app.
  ///
  /// These preserve the previous orange values verbatim so the Phase 2
  /// migration is a pure rename with **no** visual change. Whether orange
  /// stays as a deliberate accent or folds into the teal family is a design
  /// decision deferred to Phase 4 component consolidation.
  static const Color accent = Color(0xFFDA6317); // was ThemeColours.darkOrange
  static const Color accentLight =
      Color(0xFFF9A84D); // was ThemeColours.lightOrange

  /// Primary call-to-action gradient.
  ///
  /// Replaces the legacy green gradient (`ThemeColours.lightGreen` ->
  /// `darkGreen`) used by GradientButton, ThemedFloatingButton and
  /// BorderedButton. Derived from the canonical teal family so CTAs match the
  /// rest of the palette.
  static const Color gradientStart = primaryDark; // #508991
  static const Color gradientEnd = secondaryTeal; // #004346

  /// Disabled / low-emphasis surface for controls.
  static const Color disabled = Color(0xFFE3ECEE);
  static const Color onDisabled = Color(0xFF9BB2B6);

  // ---------------------------------------------------------------------
  // ColorScheme
  // ---------------------------------------------------------------------

  /// Material 3 scheme built explicitly from the tokens above.
  ///
  /// Deliberately *not* `ColorScheme.fromSeed` — seeding seizes control of
  /// every derived role and would drift away from the brand values.
  ///
  /// [secondaryTeal] rather than [primaryDark] is used as `primary` because
  /// white-on-#004346 clears WCAG AA for normal text, while white-on-#508991
  /// only reaches ~3.7:1 and would fail on button labels.
  static const ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: secondaryTeal,
    onPrimary: white,
    primaryContainer: primary,
    onPrimaryContainer: secondaryNavy,
    secondary: primaryDark,
    onSecondary: white,
    secondaryContainer: cardBackground,
    onSecondaryContainer: secondaryNavy,
    tertiary: secondaryBlue,
    onTertiary: secondaryNavy,
    tertiaryContainer: primary,
    onTertiaryContainer: secondaryNavy,
    error: error,
    onError: white,
    errorContainer: Color(0xFFFBE1E1),
    onErrorContainer: Color(0xFF5C0A0A),
    surface: scaffoldBackground,
    onSurface: textPrimary,
    surfaceContainerLowest: white,
    surfaceContainerLow: cardBackground,
    surfaceContainer: cardBackground,
    surfaceContainerHigh: Color(0xFFEAF2F4),
    surfaceContainerHighest: Color(0xFFE3ECEE),
    onSurfaceVariant: textSecondary,
    outline: inputBorder,
    outlineVariant: Color(0xFFE8F1F2),
    shadow: Color(0x1A172A3A),
    scrim: Color(0x99172A3A),
    inverseSurface: secondaryNavy,
    onInverseSurface: white,
    inversePrimary: primary,
  );
}
