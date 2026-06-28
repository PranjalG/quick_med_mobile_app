import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quick_med/services/theme_colours.dart';
import 'package:quick_med/utils/screen_size.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: 'Real value deals',
      subtitle:
          'Upto 30% off on generic medicines and 40% off on health products.',
      icon: Icons.local_offer_rounded,
      gradientColors: [
        const Color(0xFFFF9A5C).withValues(alpha: 0.15),
        const Color(0xFFFF6B4A).withValues(alpha: 0.25),
      ],
      iconColor: const Color(0xFFFF6B4A),
    ),
    OnboardingData(
      title: 'Genuine Medicines',
      subtitle:
          'We source only from licensed, trusted pharmacies — 100% authentic, every order.',
      icon: Icons.health_and_safety_rounded,
      gradientColors: [
        const Color(0xFF53E88B).withValues(alpha: 0.15),
        const Color(0xFF15BE77).withValues(alpha: 0.25),
      ],
      iconColor: const Color(0xFF15BE77),
    ),
    OnboardingData(
      title: '30-Minute Delivery',
      subtitle:
          'Get your medicines delivered to your doorstep in under 30 minutes, every time.',
      icon: Icons.delivery_dining_rounded,
      gradientColors: [
        const Color(0xFF38BDF8).withValues(alpha: 0.15),
        const Color(0xFF0284C7).withValues(alpha: 0.25),
      ],
      iconColor: const Color(0xFF0284C7),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/login');
    }
  }

  void _onSkip() {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Skip Button row
            Container(
              height: context.sh * 0.08,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              alignment: Alignment.centerRight,
              child: _currentPage < _onboardingData.length - 1
                  ? TextButton(
                      onPressed: _onSkip,
                      style: TextButton.styleFrom(
                        foregroundColor: ThemeColours.textGrey,
                      ),
                      child: Text(
                        'Skip',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ThemeColours.darkGreen,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            // PageView content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  final data = _onboardingData[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Illustration Area
                        Container(
                          height: context.sh * 0.35,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: data.gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Icon(
                            data.icon,
                            size: context.sh * 0.15,
                            color: data.iconColor,
                          ),
                        ),
                        SizedBox(height: context.sh * 0.06),
                        // Title
                        Text(
                          data.title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.palanquinDark(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        SizedBox(height: context.sh * 0.02),
                        // Subtitle
                        Text(
                          data.subtitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: ThemeColours.textGrey,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Bottom Action controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentPage == index
                              ? ThemeColours.darkGreen
                              : ThemeColours.lightGrey,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: context.sh * 0.04),
                  // Next / Get Started Button
                  GestureDetector(
                    onTap: _onNext,
                    child: Container(
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            ThemeColours.lightGreen,
                            ThemeColours.darkGreen,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: ThemeColours.darkGreen.withValues(alpha: 0.3),
                            offset: const Offset(0, 8),
                            blurRadius: 15,
                          )
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _currentPage == _onboardingData.length - 1
                            ? 'Get Started'
                            : 'Next →',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final Color iconColor;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.iconColor,
  });
}
