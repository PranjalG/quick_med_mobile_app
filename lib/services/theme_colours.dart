import 'package:flutter/material.dart';

/// LEGACY PALETTE — scheduled for deletion in Phase 2.
///
/// This was a second, unrelated colour system (green/orange/neutral-grey)
/// running alongside [AppColors] (mint/teal/navy). Every token below now has a
/// canonical equivalent in `app_colors.dart`.
///
/// Do not add anything here, and do not reference it in new code. The call
/// sites listed against each token are migrated in Phase 2, after which this
/// file is deleted.
///
/// Migration map:
///
/// | ThemeColours   | AppColors                          | Notes                        |
/// |----------------|------------------------------------|------------------------------|
/// | appWhite       | AppColors.white                    | identical value              |
/// | errorRed       | AppColors.error                    | identical value (#D31818)    |
/// | textGrey       | AppColors.neutralDark              | new neutral ramp             |
/// | textLightGrey  | AppColors.neutral                  | new neutral ramp             |
/// | lightGrey      | AppColors.neutralLight             | unused at any call site      |
/// | warningYellow  | AppColors.warning                  | unused at any call site      |
/// | successGreen   | AppColors.success                  | unused; success is teal      |
/// | lightGreen     | AppColors.gradientStart            | CTA gradient -> teal         |
/// | darkGreen      | AppColors.gradientEnd / primaryDark| CTA + field accents -> teal  |
/// | lightOrange    | AppColors.accentLight              | value preserved verbatim     |
/// | darkOrange     | AppColors.accent                   | value preserved verbatim     |
///
/// Note on the green -> teal move: `lightGreen`/`darkGreen` are the app's
/// call-to-action colours (GradientButton, ThemedFloatingButton,
/// BorderedButton, BorderedTextField, LoadingIndicator). Folding them into the
/// teal family is the visible consequence of adopting [AppColors] as
/// canonical. If the green brand should be kept instead, redefine
/// `AppColors.gradientStart/gradientEnd` rather than reviving this file.
class ThemeColours {
  static const Color appWhite = Color.fromRGBO(255, 255, 255, 1.0);
  static const Color lightGreen = Color.fromRGBO(83, 232, 139, 1.0);
  static const Color darkGreen = Color.fromRGBO(21, 190, 119, 1.0);

  static const Color textGrey = Color.fromRGBO(85, 85, 85, 1);
  static const Color textLightGrey = Color.fromRGBO(119, 119, 119, 1.0);

  static const Color lightOrange = Color.fromRGBO(249, 168, 77, 1.0);
  static const Color darkOrange = Color.fromRGBO(218, 99, 23, 1.0);
  static const Color lightGrey = Color.fromRGBO(180, 180, 180, 1.0);

  static const Color errorRed = Color.fromRGBO(211, 24, 24, 1.0);
  static const Color warningYellow = Color.fromRGBO(255, 210, 52, 1.0);
  static const Color successGreen = Color.fromRGBO(21, 182, 21, 1.0);
}
