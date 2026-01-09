import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quick_med/utils/screen_size.dart';

class FloatingTextBox extends StatelessWidget {
  final String text;

  const FloatingTextBox({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: context.sw * 0.03),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        color: Colors.white,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.sw * 0.02,
          vertical: context.sh * 0.02,
        ),
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
