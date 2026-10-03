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

  /// Optional tagline (e.g. splash subtitle) below the wordmark.
  final bool showTagline;

  /// Logo mark to the left of the wordmark (e.g. landing app bar).
  final bool horizontal;

  const LogoWidget({
    super.key,
    this.widthFactor = 0.34,
    this.showWordmark = true,
    this.showTagline = false,
    this.horizontal = false,
  });

  Widget _wordmark(BuildContext context, {double? fontSize}) {
    return Text.rich(
      TextSpan(
        style: AppTextStyles.brandWordmark(context).copyWith(
          fontSize: fontSize ?? context.fs(28),
        ),
        children: const [
          TextSpan(text: 'QuickMed'),
          TextSpan(
            text: 'D',
            style: TextStyle(color: AppColors.brandTeal),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = context.sw * widthFactor;

    if (horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/app_logo.png',
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
          if (showWordmark) ...[
            SizedBox(width: context.fs(8)),
            _wordmark(context, fontSize: context.fs(20)),
          ],
        ],
      );
    }

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
          _wordmark(context),
          if (showTagline) ...[
            SizedBox(height: context.fs(4)),
            Text(
              'Swift Medicine Delivery',
              style: AppTextStyles.splashSubtitle(context),
            ),
          ],
        ],
      ],
    );
  }
}
