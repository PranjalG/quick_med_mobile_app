import 'package:flutter/material.dart';

import '../services/app_colors.dart';
import '../utils/screen_size.dart';

/// Curved bottom edge used on splash and other brand-forward screens.
class BrandBottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);
    final controlPoint = Offset(size.width / 2, size.height - 90);
    final endPoint = Offset(size.width, size.height);
    path.quadraticBezierTo(
      controlPoint.dx,
      controlPoint.dy,
      endPoint.dx,
      endPoint.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// Top hero band: logo-green → teal gradient with the pattern overlay from splash.
class BrandCurvedHeader extends StatelessWidget {
  final double heightFactor;

  const BrandCurvedHeader({
    super.key,
    this.heightFactor = 0.28,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: BrandBottomCurveClipper(),
      child: Container(
        height: context.sh * heightFactor,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.brandGradientStart,
              AppColors.brandGradientEnd,
            ],
          ),
        ),
        child: Image.asset(
          'assets/images/pattern-header.png',
          fit: BoxFit.cover,
          color: AppColors.white.withValues(alpha: 0.18),
          colorBlendMode: BlendMode.srcIn,
        ),
      ),
    );
  }
}
