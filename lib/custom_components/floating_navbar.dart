import 'package:flutter/material.dart';
import 'package:quick_med/services/app_colors.dart';
import 'package:quick_med/services/app_theme.dart';

/// Floating bottom navigation bar.
///
/// Uses Material icons rather than raster assets: the previous PNG/SVG icons
/// carried baked-in colours that could not follow the palette, and one entry
/// pointed at an `.svg` that `Image.asset` cannot decode at all.
class FloatingNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap; // callback to notify parent when tab changes

  const FloatingNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<_NavDestination> _destinations = [
    _NavDestination(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _NavDestination(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
    _NavDestination(
      icon: Icons.shopping_cart_outlined,
      activeIcon: Icons.shopping_cart_rounded,
      label: 'Cart',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Material(
          color: AppColors.scaffoldBackground,
          elevation: 8,
          shadowColor: AppColors.secondaryNavy.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(AppRadius.lg + 4),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_destinations.length, (index) {
                return _NavButton(
                  destination: _destinations[index],
                  isActive: index == currentIndex,
                  onTap: () => onTap(index),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavDestination {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavDestination({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _NavButton extends StatelessWidget {
  final _NavDestination destination;
  final bool isActive;
  final VoidCallback onTap;

  const _NavButton({
    required this.destination,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isActive,
      label: destination.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        splashColor: AppColors.primary,
        highlightColor: AppColors.primary.withValues(alpha: 0.5),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: AppRadius.mdAll,
          ),
          child: Icon(
            isActive ? destination.activeIcon : destination.icon,
            size: AppIconSize.lg,
            color: isActive ? AppColors.secondaryTeal : AppColors.secondaryBlue,
          ),
        ),
      ),
    );
  }
}
