import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FloatingTextBox extends StatelessWidget {
  final String text;

  const FloatingTextBox({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Text(
          text,
          maxLines: 2,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
