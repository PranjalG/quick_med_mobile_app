import 'package:go_router/go_router.dart';
import 'package:quick_med/screens/home_screen.dart';
import 'package:quick_med/screens/login_screen.dart';
import 'package:quick_med/screens/splash_screen.dart';


final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
        path: '/home_screen',
        builder: (context, state) => const HomeScreen(),
        // routes: [
          // GoRoute(
          //   path: 'detail_screen',
          //   builder: (context, state) {
          //     final data = state.extra as Map<String, String>;
          //     final title = data['title'] ?? '';
          //     final subtitle = data['subtitle'] ?? '';
          //     return DetailScreen(title: title, subtitle: subtitle);
          //   },
          // ),
        // ]
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
  ],
);
