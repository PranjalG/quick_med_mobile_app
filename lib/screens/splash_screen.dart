import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_med/blocs/splash_cubit/splash_cubit.dart';
import 'package:quick_med/blocs/splash_cubit/splash_state.dart';
import 'package:quick_med/services/app_colors.dart';
import 'package:quick_med/services/app_text_styles.dart';
import 'package:quick_med/custom_components/brand_curved_header.dart';
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
        backgroundColor: AppColors.scaffoldBackground,
        body: Column(
          children: [
            // 1. Top curved pattern header image using extracted PNG and custom clipper
            const BrandCurvedHeader(heightFactor: 0.45),
            const Spacer(),
            // 2. Content area with logo, brand name and tagline
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/app_logo.png',
                  width: context.sw * 0.3,
                  height: context.sw * 0.3,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: context.fs(16)),
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
