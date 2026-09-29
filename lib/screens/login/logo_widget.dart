import 'package:flutter/material.dart';

import 'package:quick_med/utils/screen_size.dart';

/// Brand logo lockup (wordmark + tagline) rendered from the `Logo.png` asset.
///
/// Using the asset directly keeps the official green wordmark and avoids
/// re-typing the brand name.
class LogoWidget extends StatelessWidget {
  /// Logo width as a fraction of screen width.
  final double widthFactor;

  const LogoWidget({super.key, this.widthFactor = 0.62});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/Logo.png',
      width: context.sw * widthFactor,
      fit: BoxFit.contain,
    );
  }
}
