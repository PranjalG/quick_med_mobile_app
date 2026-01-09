import 'package:flutter/material.dart';
import 'package:quick_med/services/theme_colours.dart';

class BorderedIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const BorderedIconButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          border: Border.all(
            width: 2,
            color: ThemeColours.lightGreen,
          ),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: ThemeColours.lightGreen,
          size: 26,
        ),
      ),
    );
  }
}
