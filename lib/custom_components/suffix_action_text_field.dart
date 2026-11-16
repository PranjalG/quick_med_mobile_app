import 'package:flutter/material.dart';
import 'package:quick_med/services/text_styles.dart';
import 'package:quick_med/services/app_colors.dart';

class SuffixActionTextField extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onSearchPressed;

  const SuffixActionTextField({
    super.key,
    required this.hintText,
    this.onSearchPressed,
  });


  @override
  State<SuffixActionTextField> createState() => _SuffixActionTextFieldState();
}

class _SuffixActionTextFieldState extends State<SuffixActionTextField> {
  late final TextEditingController _controller;

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
    return TextField(
      controller: _controller,
      onChanged: (value) {
        widget.onSearchPressed?.call(value.trim());
      },
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyles.body(context).copyWith(
          color: AppColors.accent,
        ),
        filled: true,
        fillColor: AppColors.accentLight.withValues(alpha: 0.3),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.search),
          color: AppColors.accent,
          onPressed: () {
            widget.onSearchPressed?.call(_controller.text.trim());
          },
        ),
      ),
    );
  }
}
