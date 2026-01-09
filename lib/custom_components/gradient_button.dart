import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quick_med/services/theme_colours.dart';
import 'package:quick_med/utils/screen_size.dart';

class GradientButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback? onTap;
  final double? width;
  final IconData? trailingIcon;
  final bool? enabled;

  const GradientButton({
    super.key,
    required this.buttonText,
    required this.onTap,
    this.width,
    this.trailingIcon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (enabled ?? true) ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
        width: context.sw * (width ?? 0.8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: (enabled ?? true)
              ? const LinearGradient(
            colors: [
              ThemeColours.lightGreen,
              ThemeColours.darkGreen,
            ],
            stops: [0.1, 0.8],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : LinearGradient(
            colors: [
              ThemeColours.lightGreen.withValues(alpha: 0.4),
              ThemeColours.darkGreen.withValues(alpha: 0.4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: (enabled ?? true)
              ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              offset: const Offset(0, 4),
              blurRadius: 6,
            )
          ]
              : null,
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
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: enabled ?? true ? 1 : 0.7),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                trailingIcon ?? Icons.arrow_forward_rounded,
                size: 26,
                color: Colors.white.withValues(alpha: enabled ?? true ? 1 : 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
