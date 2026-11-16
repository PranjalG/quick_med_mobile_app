import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_med/blocs/onboarding_cubit/onboarding_cubit.dart';
import 'package:quick_med/blocs/onboarding_cubit/onboarding_state.dart';
import 'package:quick_med/custom_components/brand_curved_header.dart';
import 'package:quick_med/services/app_colors.dart';
import 'package:quick_med/services/app_text_styles.dart';
import 'package:quick_med/utils/screen_size.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingCubit(),
      child: const OnboardingView(),
    );
  }
}

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  static final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: 'Real value deals',
      subtitle:
          'Upto 30% off on generic medicines and 40% off on health products.',
      imagePath: 'assets/images/onboarding-real-value-deals.png',
    ),
    OnboardingData(
      title: 'Genuine Medicines',
      subtitle:
          'We source only from licensed, trusted pharmacies — 100% authentic, every order.',
      imagePath: 'assets/images/medical-store.png',
    ),
    OnboardingData(
      title: '30-Minute Delivery',
      subtitle:
          'Get your medicines delivered to your doorstep in under 30 minutes, every time.',
      imagePath: 'assets/images/scooter.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Column(
        children: [
          const BrandCurvedHeader(heightFactor: 0.14),
          Expanded(
            child: SafeArea(
              top: false,
              child: BlocBuilder<OnboardingCubit, OnboardingState>(
              builder: (context, state) {
                final int currentPage = state.currentPage;

                return Column(
                  children: [
                    // Top skip button row
                    Container(
                      height: context.sh * 0.08,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      alignment: Alignment.centerRight,
                      child: currentPage < _onboardingData.length - 1
                          ? GestureDetector(
                              onTap: () => context.go('/login'),
                              child: Text(
                                'Skip',
                                style: AppTextStyles.skipText(context),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    // PageView Builder
                    Expanded(
                      child: PageView.builder(
                        controller: pageController,
                        onPageChanged: (int page) {
                          context.read<OnboardingCubit>().updatePage(page);
                        },
                        itemCount: _onboardingData.length,
                        itemBuilder: (context, index) {
                          final data = _onboardingData[index];
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Illustration Image Area — flexes to fill the
                                // available height so the page never overflows,
                                // while BoxFit.contain scales the artwork up as
                                // large as that space allows.
                                Flexible(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: context.sh * 0.01),
                                    child: Image.asset(
                                      data.imagePath,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(height: context.sh * 0.015),
                                // Title Text
                                Text(
                                  data.title,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.onboardingTitle(context),
                                ),
                                SizedBox(height: context.sh * 0.02),
                                // Subtitle Text
                                Text(
                                  data.subtitle,
                                  textAlign: TextAlign.center,
                                  style:
                                      AppTextStyles.onboardingSubtitle(context),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Bottom Action Controls
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Page Indicators
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _onboardingData.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                height: 8,
                                width: currentPage == index ? 24 : 8,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: currentPage == index
                                      ? AppColors.brandGreen
                                      : AppColors.brandTeal
                                          .withValues(alpha: 0.25),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: context.sh * 0.04),
                          // Next / Get Started Button
                          GestureDetector(
                            onTap: () {
                              if (currentPage < _onboardingData.length - 1) {
                                pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              } else {
                                context.go('/login');
                              }
                            },
                            child: Container(
                              height: 60,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.brandGradientStart,
                                    AppColors.brandGradientEnd,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.brandTeal
                                        .withValues(alpha: 0.3),
                                    offset: const Offset(0, 8),
                                    blurRadius: 15,
                                  )
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                currentPage == _onboardingData.length - 1
                                    ? 'Get Started'
                                    : 'Next →',
                                style: AppTextStyles.buttonText(context)
                                    .copyWith(color: AppColors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final String imagePath;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });
}
