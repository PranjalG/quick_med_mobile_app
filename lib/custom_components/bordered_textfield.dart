import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quick_med/services/theme_colours.dart';
import 'package:quick_med/utils/screen_size.dart';

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
  final IconData? suffixIcon;
  final VoidCallback? suffixIconOnTap;
  final bool isRequired;
  final InputDecoration? textDecoration;
  final VoidCallback? onSubmit;
  final TextInputAction textInputAction;


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
    this.suffixIconOnTap,
    this.onSubmit,
    this.textInputAction = TextInputAction.done,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: EdgeInsets.only(
                left: context.sw * 0.01, bottom: context.sh * 0.005),
            child: Text(
              label!,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ThemeColours.darkGreen,
              ),
            ),
          ),
        Container(
          width: context.sw * 0.8,
          padding: EdgeInsets.symmetric(horizontal: context.sw * 0.04),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              width: 2,
              color: hasError ? Colors.red : ThemeColours.lightGreen,
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            inputFormatters: inputFormatter,
            cursorColor: ThemeColours.darkGreen,
            enabled: enabled ?? true,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              color: ThemeColours.darkGreen,
              decoration: TextDecoration.none,
            ),
            textInputAction: textInputAction,
            onFieldSubmitted: (value) {
              if (onSubmit != null) {
                onSubmit!();
              }
            },
            enableInteractiveSelection: allowPasting ?? true,
            decoration: textDecoration ??
                InputDecoration(
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: context.sh * 0.01),
                  hintText: hintText,
                  hintStyle: GoogleFonts.montserrat(
                    color: ThemeColours.darkGreen,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  errorText: null,
                  suffixIcon: suffixIcon == null
                      ? null
                      : IconButton(
                          icon: Icon(
                            suffixIcon,
                            color: ThemeColours.darkGreen,
                          ),
                          onPressed: suffixIconOnTap ?? () {},
                        ),
                ),
            onChanged: onChange,
          ),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(
                left: context.sw * 0.02, top: context.sh * 0.01),
            child: Text(
              errorText!,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: Colors.red,
              ),
            ),
          ),
      ],
    );
  }
}
