import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_med/utils/screen_size.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    _navigateToLanding();
  }

  void _navigateToLanding() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Stack(
            children: [
              SizedBox(
                height: context.sh * 0.45,
                width: double.infinity,
                child: Image.asset(
                  'assets/images/Gradient.png',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: context.sh * 0.12,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.9),
                          Colors.white,
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(100),
                        topRight: Radius.circular(100),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: context.sh * 0.01),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Image.asset(
              'assets/images/Logo.png',
              height: context.sh * 0.1,
              // width: 100,
            ),
          ),
          SizedBox(height: context.sh * 0.2),
        ],
      ),
    );
  }
}
