import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quick_med/services/theme_colours.dart';

class BorderedButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onTap;
  final IconData? trailingIcon;

  const BorderedButton({
    super.key,
    required this.buttonText,
    required this.onTap,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
        width: screenWidth * 0.8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            width: 2,
            color: ThemeColours.lightGreen,
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 10),
            Text(
              buttonText,
              style: GoogleFonts.montserrat(
                fontSize: 18,
                color: ThemeColours.darkGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                trailingIcon ?? Icons.arrow_forward_rounded,
                color: ThemeColours.darkGreen,
                size: 26,
              ),
            )
          ],
        ),
      ),
    );
  }
}
