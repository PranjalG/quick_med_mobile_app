import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_med/blocs/splash_cubit/splash_cubit.dart';
import 'package:quick_med/blocs/splash_cubit/splash_state.dart';
import 'package:quick_med/services/app_colors.dart';
import 'package:quick_med/services/app_text_styles.dart';
import 'package:quick_med/utils/screen_size.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashCubit(),
      child: const SplashView(),
    );
  }
}

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state is SplashNavigateToOnboarding) {
          context.go('/onboarding');
        } else if (state is SplashNavigateToHome) {
          context.go('/home_screen');
        } else if (state is SplashNavigateToProfileSetup) {
          context.go('/profile_setup');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Column(
          children: [
            // 1. Top curved pattern header image using extracted PNG and custom clipper
            ClipPath(
              clipper: BottomCurveClipper(),
              child: SizedBox(
                height: context.sh * 0.45,
                width: double.infinity,
                child: Image.asset(
                  'assets/images/pattern-header.png',
                  fit: BoxFit.cover,
                  color: AppColors.primaryDark,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
            ),
            const Spacer(),
            // 2. Content area with logo text and tagline
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'QuickMedD',
                  style: AppTextStyles.splashTitle(context),
                ),
                const SizedBox(height: 16),
                Text(
                  'Swift Medicine Delivery',
                  style: AppTextStyles.splashSubtitle(context),
                ),
              ],
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}

class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);
    // Control point in the center is higher to create the curved dome arch
    final controlPoint = Offset(size.width / 2, size.height - 90);
    final endPoint = Offset(size.width, size.height);
    
    path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
