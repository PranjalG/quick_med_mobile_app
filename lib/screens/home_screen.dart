import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Stack(
            children: [
              SizedBox(
                height: screenHeight * 0.45,
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
                    height: screenHeight * 0.12,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white.withOpacity(0.9), Colors.white],
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
            margin: const EdgeInsets.only(top: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              // shape: BoxShape.circle,
              // boxShadow: [
              //   BoxShadow(
              //     blurRadius: 10,
              //     color: Colors.black12,
              //     offset: Offset(0, 4),
              //   )
              // ],
            ),
            padding: const EdgeInsets.all(24),
            child: Image.asset(
              'assets/images/Logo.png',
              height: 80,
              // width: 100,
            ),
          ),
          const SizedBox(height: 24),
          // const Text(
          //   'Welcome to QuickMed',
          //   style: TextStyle(
          //     fontSize: 24,
          //     fontWeight: FontWeight.bold,
          //     color: Colors.teal,
          //   ),
          // ),
          // const SizedBox(height: 12),
          // const Text(
          //   'Your trusted medicine delivery app',
          //   style: TextStyle(fontSize: 16, color: Colors.black54),
          // ),
          ElevatedButton(
              onPressed: () {
                context.go('/login');
              },
              child: const Text('Login ->'))
        ],
      ),
    );
  }
}
