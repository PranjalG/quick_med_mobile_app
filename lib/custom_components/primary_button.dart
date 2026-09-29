import 'package:flutter/material.dart';

import '../services/app_colors.dart';
import '../services/app_text_styles.dart';
import '../utils/screen_size.dart';

/// Canonical primary call-to-action button.
///
/// Uses the brand teal gradient (`AppColors.gradientStart` ->
/// `AppColors.gradientEnd`) and `AppTextStyles`. Prefer this over the legacy
/// [GradientButton] (green) for new screens.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  final IconData? trailingIcon;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.trailingIcon = Icons.arrow_forward_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = enabled && onTap != null;

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: isEnabled ? 1 : 0.6,
        child: Container(
          width: double.infinity,
          height: context.fs(56),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.fs(16)),
            gradient: const LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: AppColors.gradientEnd.withValues(alpha: 0.28),
                      offset: const Offset(0, 6),
                      blurRadius: 14,
                    ),
                  ]
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                label,
                style: AppTextStyles.buttonText(context).copyWith(
                  color: AppColors.white,
                  fontSize: context.fs(16),
                ),
              ),
              if (trailingIcon != null)
                Positioned(
                  right: context.fs(20),
                  child: Icon(
                    trailingIcon,
                    size: context.fs(22),
                    color: AppColors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
