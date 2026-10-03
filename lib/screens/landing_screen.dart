import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_med/blocs/cart_cubit/cart_cubit.dart';
import 'package:quick_med/utils/prescription_upload_flow.dart';
import 'package:quick_med/blocs/catalogue_cubit/catalogue_cubit.dart';
import 'package:quick_med/models/category_model.dart';
import 'package:quick_med/models/medicine_model.dart';
import 'package:quick_med/services/app_theme.dart';
import 'package:quick_med/blocs/profile_cubit/profile_cubit.dart';
import 'package:quick_med/blocs/profile_cubit/profile_state.dart';
import 'package:quick_med/screens/login/logo_widget.dart';
import 'package:quick_med/services/app_colors.dart';
import 'package:quick_med/services/app_text_styles.dart';
import 'package:quick_med/utils/screen_size.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Top Header Section (Brand, Greeting, Location, Bell Notification)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlocBuilder<ProfileCubit, ProfileState>(
                    builder: (context, state) {
                      String displayName = 'Guest';
                      String displayArea = 'Kota';
                      if (state is ProfileLoaded) {
                        displayName = state.profile.name.split(' ').first;
                        displayArea = state.profile.kotaArea;
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const LogoWidget(
                            horizontal: true,
                            widthFactor: 0.09,
                            showTagline: false,
                          ),
                          const SizedBox(height: 8),
                                Text(
                                  'Hi, $displayName 👋',
                                  style: AppTextStyles.homeHeading(context),
                                ),
                                const SizedBox(height: 8),
                                // Location chip
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardBackground,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.inputBorder,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        size: 16,
                                        color: AppColors.brandTeal,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$displayArea, Kota',
                                        style: AppTextStyles.skipText(context).copyWith(
                                          color: AppColors.brandGreenDeep,
                                          fontSize: context.fs(13),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 16,
                                        color: AppColors.brandGreenDeep,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                      );
                    },
                  ),
                  Material(
                    color: AppColors.cardBackground,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () => context.push('/alerts'),
                      customBorder: const CircleBorder(),
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.notifications_none_rounded,
                          size: 24,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                      ],
                    ),
                  ),

                  // 2. Search Trigger Bar & Upload Prescription Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => context.push('/search'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.inputFill,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: AppColors.inputBorder,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 22),
                                const SizedBox(width: 12),
                                Text(
                                  'Search medicines, salt or brand',
                                  style: AppTextStyles.hintText(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Upload Prescription Card
                        InkWell(
                          onTap: () => PrescriptionUploadFlow.run(context),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.brandGradientStart,
                                AppColors.brandGradientEnd,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.brandTeal.withValues(alpha: 0.25),
                                offset: const Offset(0, 4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.document_scanner_outlined, color: AppColors.white, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                'Upload Prescription',
                                style: AppTextStyles.buttonText(context).copyWith(
                                  fontSize: context.fs(14),
                                  color: AppColors.white,
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.white, size: 14),
                            ],
                          ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. Hero Promo Card (30-Min Delivery with Super Delivery Agent Image)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.secondaryBlue,
                            AppColors.secondaryTeal,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brandTeal.withValues(alpha: 0.25),
                            offset: const Offset(0, 8),
                            blurRadius: 16,
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.white.withValues(alpha: 0.22),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '⚡ Fast Delivery',
                                    style: AppTextStyles.chipTitle(context).copyWith(
                                      fontSize: context.fs(12),
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '30-Min Delivery',
                                  style: AppTextStyles.bannerTitle(context),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Get essentials at your door, instantly.',
                                  style: AppTextStyles.bannerBody(context),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Order Now',
                                        style: AppTextStyles.bannerButton(context).copyWith(
                                          color: AppColors.brandGreenDeep,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 16,
                                        color: AppColors.brandGreenDeep,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: SizedBox(
                                height: 110,
                                width: 110,
                                child: Image.asset(
                                  'assets/images/delivery_super_agent.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const _CategoriesSection(),
                  const SizedBox(height: 24),

                  // 5. Offers & Discounts Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Offers & Discounts',
                              style: AppTextStyles.homeSectionHeader(context),
                            ),
                            // LIVE Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.brandGreenLight.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: AppColors.brandGreenLight),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    height: 6,
                                    width: 6,
                                    decoration: const BoxDecoration(
                                      color: AppColors.brandGreen,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'LIVE',
                                    style: AppTextStyles.chipTitle(context).copyWith(
                                      fontSize: context.fs(11),
                                      color: AppColors.brandGreenDeep,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Hero Offer Banner Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.brandGradientStart,
                                AppColors.brandGradientEnd,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.white.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'TODAY ONLY 🔥',
                                  style: AppTextStyles.bannerButton(context).copyWith(
                                    fontSize: context.fs(11),
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '30% OFF',
                                style: AppTextStyles.bannerTitle(context).copyWith(
                                  fontSize: context.fs(36),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'On every medicine & health product',
                                style: AppTextStyles.bannerBody(context),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'Claim Offer →',
                                  style: AppTextStyles.chipTitle(context).copyWith(
                                    color: AppColors.brandGreenDeep,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Bottom Chips Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildOfferChip(
                                context: context,
                                title: '🚚 Free Delivery',
                                subtitle: 'Min. order ₹299',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildOfferChip(
                                context: context,
                                title: '💊 Generic Savings',
                                subtitle: 'Salt-based options',
                              ),
                            ),
                          ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferChip({
    required BuildContext context,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.inputBorder,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.chipTitle(context).copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTextStyles.chipSubtitle(context).copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Categories and their medicines, driven by Supabase.
///
/// Previously six hardcoded tiles that did nothing when tapped. The six
/// category rows seeded in the database use the same labels, so the visual
/// result is unchanged while the content is now real.
class _CategoriesSection extends StatelessWidget {
  const _CategoriesSection();

  static const Map<String, IconData> _icons = {
    'skincare': Icons.face_retouching_natural_rounded,
    'health_nutrition': Icons.restaurant_menu_rounded,
    'baby_care': Icons.child_care_rounded,
    'general_medicine': Icons.medication_rounded,
    'sexual_wellness': Icons.favorite_rounded,
    'pet_care': Icons.pets_rounded,
  };

  static const List<Color> _tints = [
    AppColors.brandGreenLight,
    AppColors.brandTeal,
    AppColors.brandGreen,
    AppColors.brandGreenDark,
    AppColors.brandGradientStart,
    AppColors.brandGradientEnd,
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatalogueCubit, CatalogueState>(
      builder: (context, state) {
        return switch (state) {
          CatalogueInitial() || CatalogueLoading() => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
              child: Center(child: CircularProgressIndicator()),
            ),
          CatalogueEmpty() => const _CatalogueMessage(
              icon: Icons.inventory_2_outlined,
              title: 'No medicines yet',
              body: 'The catalogue is empty. Run the seed script to add stock.',
            ),
          CatalogueFailure(:final message) => _CatalogueMessage(
              icon: Icons.cloud_off_rounded,
              title: 'Could not load the catalogue',
              body: message,
              onRetry: () => context.read<CatalogueCubit>().refresh(),
            ),
          CatalogueLoaded(:final byCategory, :final isFallback) =>
            _buildLoaded(context, byCategory, isFallback),
        };
      },
    );
  }

  Widget _buildLoaded(
    BuildContext context,
    Map<MedicineCategory, List<Medicine>> byCategory,
    bool isFallback,
  ) {
    final categories = byCategory.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isFallback)
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.md),
            child: Row(
              children: [
                const Icon(Icons.wifi_off_rounded,
                    size: AppIconSize.sm, color: AppColors.accent),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Showing offline sample data',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.accent),
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Categories',
                  style: AppTextStyles.homeSectionHeader(context)),
              const SizedBox(height: AppSpacing.lg),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: AppSpacing.lg,
                mainAxisSpacing: AppSpacing.lg,
                childAspectRatio: 0.85,
                children: [
                  for (var i = 0; i < categories.length; i++)
                    _CategoryTile(
                      category: categories[i],
                      icon: _icons[categories[i].slug] ??
                          Icons.medication_rounded,
                      tint: _tints[i % _tints.length],
                    ),
                ],
              ),
            ],
          ),
        ),
        for (final category in categories) ...[
          const SizedBox(height: AppSpacing.xl),
          _CategoryRow(
            category: category,
            medicines: byCategory[category] ?? const [],
          ),
        ],
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final MedicineCategory category;
  final IconData icon;
  final Color tint;

  const _CategoryTile({
    required this.category,
    required this.icon,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
          child: Icon(
            icon,
            color: AppColors.white,
            size: 28,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          category.name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.categoryLabel(context)
              .copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final MedicineCategory category;
  final List<Medicine> medicines;

  const _CategoryRow({required this.category, required this.medicines});

  @override
  Widget build(BuildContext context) {
    if (medicines.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Text(category.name,
              style: AppTextStyles.homeSectionHeader(context)),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 186,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            itemCount: medicines.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, i) => _MedicineCard(medicine: medicines[i]),
          ),
        ),
      ],
    );
  }
}

class _MedicineCard extends StatelessWidget {
  final Medicine medicine;

  const _MedicineCard({required this.medicine});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final outOfStock = medicine.isOutOfStock;

    return Opacity(
      opacity: outOfStock ? 0.55 : 1,
      child: Container(
        width: 156,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: AppRadius.lgAll,
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (medicine.rxRequired)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accentLight.withValues(alpha: 0.25),
                  borderRadius: AppRadius.smAll,
                ),
                child: Text('Rx',
                    style: text.labelSmall?.copyWith(color: AppColors.accent)),
              ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              medicine.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: text.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              medicine.manufacturer,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.bodySmall,
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Rs ${medicine.price.toStringAsFixed(0)}',
                    style: text.titleMedium),
                const SizedBox(width: AppSpacing.xs),
                if (medicine.mrp > medicine.price)
                  Text(
                    medicine.mrp.toStringAsFixed(0),
                    style: text.bodySmall?.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: AppColors.neutral,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Expanded(
                  child: Text(
                    outOfStock ? 'Out of stock' : medicine.discount,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.labelSmall?.copyWith(
                      color: outOfStock ? AppColors.error : AppColors.brandTeal,
                    ),
                  ),
                ),
                if (!outOfStock)
                  BlocBuilder<CartCubit, CartState>(
                    builder: (context, cart) {
                      final inCart = cart.lines
                          .any((l) => l.medicine.id == medicine.id);
                      return InkWell(
                        onTap: () {
                          context.read<CartCubit>().add(medicine);
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(SnackBar(
                              content: Text('${medicine.name} added to cart'),
                              duration: const Duration(seconds: 2),
                            ));
                        },
                        borderRadius: AppRadius.smAll,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: inCart
                                ? null
                                : const LinearGradient(
                                    colors: [
                                      AppColors.brandGradientStart,
                                      AppColors.brandGradientEnd,
                                    ],
                                  ),
                            color: inCart ? AppColors.brandGreenLight : null,
                            borderRadius: AppRadius.smAll,
                          ),
                          child: Icon(
                            inCart
                                ? Icons.check_rounded
                                : Icons.add_shopping_cart_rounded,
                            size: AppIconSize.sm,
                            color: inCart
                                ? AppColors.brandGreenDeep
                                : AppColors.white,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogueMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final VoidCallback? onRetry;

  const _CatalogueMessage({
    required this.icon,
    required this.title,
    required this.body,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppColors.brandTeal),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: text.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xs),
          Text(body,
              style: text.bodySmall, textAlign: TextAlign.center, maxLines: 3),
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.md),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }
}
