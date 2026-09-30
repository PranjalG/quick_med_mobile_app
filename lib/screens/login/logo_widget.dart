import 'package:flutter/material.dart';

import 'package:quick_med/services/app_colors.dart';
import 'package:quick_med/services/app_text_styles.dart';
import 'package:quick_med/utils/screen_size.dart';

/// Brand logo mark rendered from the square, transparent `app_logo.png` asset,
/// optionally with the "QuickMedD" wordmark beneath it.
///
/// The wordmark is painted in the logo's own colours: "QuickMed" in the deep
/// brand green and the trailing "D" in the teal accent, echoing the green
/// hexagon + teal capsule of the mark.
class LogoWidget extends StatelessWidget {
  /// Logo width (and height) as a fraction of screen width.
  final double widthFactor;

  /// Whether to show the "QuickMedD" wordmark under the logo.
  final bool showWordmark;

  const LogoWidget({
    super.key,
    this.widthFactor = 0.34,
    this.showWordmark = true,
  });

  @override
  Widget build(BuildContext context) {
    final size = context.sw * widthFactor;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/app_logo.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
        if (showWordmark) ...[
          SizedBox(height: context.fs(8)),
          Text.rich(
            TextSpan(
              style: AppTextStyles.brandWordmark(context),
              children: const [
                TextSpan(text: 'QuickMed'),
                TextSpan(
                  text: 'D',
                  style: TextStyle(color: AppColors.brandTeal),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
