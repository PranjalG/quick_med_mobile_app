import 'package:go_router/go_router.dart';
import 'package:quick_med/screens/home_screen.dart';
import 'package:quick_med/screens/login/login_screen.dart';
import 'package:quick_med/screens/splash_screen.dart';
import 'package:quick_med/screens/onboarding_screen.dart';
import 'package:quick_med/screens/login/otp_verification_screen.dart';
import 'package:quick_med/screens/login/profile_setup_screen.dart';
import 'package:quick_med/screens/search_screen.dart';


final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
        path: '/home_screen',
        builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/otp_verification',
      builder: (context, state) {
        final phone = state.uri.queryParameters['phone'] ?? '';
        return OtpVerificationScreen(phoneNumber: phone);
      },
    ),
    GoRoute(
      path: '/profile_setup',
      builder: (context, state) => const ProfileSetupScreen(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchScreen(),
    ),
  ],
);
