import 'package:flutter/material.dart';
import 'package:quick_med/services/app_colors.dart';

class ThemedTextField extends StatefulWidget {
  final String hintText;
  final VoidCallback? onSearchPressed;

  const ThemedTextField({
    super.key,
    required this.hintText,
    this.onSearchPressed,
  });

  @override
  State<ThemedTextField> createState() => _ThemedTextFieldState();
}

class _ThemedTextFieldState extends State<ThemedTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      style: const TextStyle(
        color: AppColors.accent,
        decoration: TextDecoration.none,
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        fillColor: AppColors.accentLight.withValues(alpha: 0.4),
        filled: true,
        hintText: widget.hintText,
        hintStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.accent,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.accentLight.withValues(alpha : 0.3),
            width: 0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.accentLight.withValues(alpha : 0.3),
            width: 0,
          ),
        ),
        suffixIcon: GestureDetector(
          onTap: widget.onSearchPressed ?? () {},
          child: const Icon(
            Icons.search,
            color: AppColors.accent,
          ),
        ),
      ),
      cursorColor: AppColors.accent,
    );
  }
}
