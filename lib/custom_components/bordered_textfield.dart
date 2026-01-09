import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quick_med/services/theme_colours.dart';

class BorderedTextField extends StatelessWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Function(String?) onChange;
  final String? errorText;
  final bool? enabled;
  final bool? allowPasting;
  final List<TextInputFormatter>? inputFormatter;
  final Icon? suffixIcon;
  final bool isRequired;
  final InputDecoration? textDecoration;

  const BorderedTextField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    required this.onChange,
    this.errorText,
    this.enabled,
    this.allowPasting,
    this.inputFormatter,
    this.isRequired = false,
    this.textDecoration,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label != null ? Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 6),
          child: Text(
            label ?? '',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ThemeColours.darkGreen,
            ),
          ),
        ) : const SizedBox.shrink(),
        Container(
          width: screenWidth * 0.8,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              width: 2,
              color: ThemeColours.lightGreen,
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            inputFormatters: inputFormatter,
            cursorColor: ThemeColours.darkGreen,
            enabled: enabled ?? false,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              color: ThemeColours.darkGreen,
              decoration: TextDecoration.none,
            ),
            enableInteractiveSelection: allowPasting ?? true,
            decoration: textDecoration ?? InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              hintText: hintText,
              hintStyle: GoogleFonts.montserrat(
                color: ThemeColours.darkGreen,
                fontSize: 14,
                decoration: TextDecoration.none,
              ),
              border: InputBorder.none,
              suffixIcon: suffixIcon,
            ),
            onChanged: (v) {
              onChange(v);
            },
          ),
        ),
      ],
    );
  }
}
