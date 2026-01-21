import 'package:flutter/material.dart';
import 'package:quick_med/utils/screen_size.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: context.sh * 0.15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                height: context.sh * 0.098,
                child: Image.asset(
                  'assets/images/Logo.png',
                  height: context.sh * 0.098,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: context.sh * 0.12),
      ],
    );
  }
}
