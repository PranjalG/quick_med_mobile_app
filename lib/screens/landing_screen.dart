import 'package:flutter/material.dart';
import 'package:quick_med/custom_components/themed_floating_button.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'Landing',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade200,
            ),
          ),
        ),
        ThemedFloatingButton(
          child: const Text('Login', style: TextStyle(color: Colors.white),),
          onTap: () {},
        ),
      ],
    );
  }
}
