import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_med/blocs/profile_cubit/profile_cubit.dart';
import 'package:quick_med/blocs/profile_cubit/profile_state.dart';
import 'package:quick_med/services/app_colors.dart';
import 'package:quick_med/services/app_text_styles.dart';
import 'package:quick_med/utils/screen_size.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // 1. Watermark Background Pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.08,
              child: Image.asset(
                'assets/images/watermark-pattern.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. Main Scroll Content
          SafeArea(
            child: SingleChildScrollView(
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
                                Text(
                                  'QuickMedD',
                                  style: AppTextStyles.homeTitle(context),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Hi, $displayName 👋',
                                  style: AppTextStyles.homeHeading(context),
                                ),
                                const SizedBox(height: 8),
                                // Location chip
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        size: 16,
                                        color: AppColors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$displayArea, Kota',
                                        style: AppTextStyles.skipText(context).copyWith(
                                          color: AppColors.grey,
                                          fontSize: context.fs(13),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 16,
                                        color: AppColors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        // Notification Bell with Badge
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF3F4F6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.notifications_none_rounded,
                                size: 24,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Positioned(
                              right: 4,
                              top: 4,
                              child: Container(
                                height: 8,
                                width: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF6B4A),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
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
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  offset: const Offset(0, 4),
                                  blurRadius: 8,
                                )
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.search_rounded, color: AppColors.grey, size: 22),
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
                        Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0284C7).withValues(alpha: 0.2),
                                offset: const Offset(0, 4),
                                blurRadius: 8,
                              )
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
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.white, size: 14),
                            ],
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
                          colors: [Color(0xFF0A7B6C), Color(0xFF1B5E20)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0A7B6C).withValues(alpha: 0.25),
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
                                    color: const Color(0xFFFF7B5A),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '⚡ Fast Delivery',
                                    style: AppTextStyles.chipTitle(context).copyWith(
                                      fontSize: context.fs(12),
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
                                    color: const Color(0xFFF5C518),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Order Now',
                                        style: AppTextStyles.bannerButton(context),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 16,
                                        color: AppColors.textPrimary,
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

                  // 4. Categories Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Categories',
                          style: AppTextStyles.homeSectionHeader(context),
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85,
                          children: [
                            _buildCategoryItem(
                              context: context,
                              label: 'Skincare',
                              icon: Icons.face_retouching_natural_rounded,
                              color: const Color(0xFFFF7B5A),
                            ),
                            _buildCategoryItem(
                              context: context,
                              label: 'Health & Nutrition',
                              icon: Icons.restaurant_menu_rounded,
                              color: AppColors.primary,
                            ),
                            _buildCategoryItem(
                              context: context,
                              label: 'Baby Care',
                              icon: Icons.child_care_rounded,
                              color: const Color(0xFF38BDF8),
                            ),
                            _buildCategoryItem(
                              context: context,
                              label: 'General Medicine',
                              icon: Icons.medication_rounded,
                              color: const Color(0xFF0284C7),
                            ),
                            _buildCategoryItem(
                              context: context,
                              label: 'Sexual Wellness',
                              icon: Icons.favorite_rounded,
                              color: const Color(0xFFFF6B4A),
                            ),
                            _buildCategoryItem(
                              context: context,
                              label: 'Pet Care',
                              icon: Icons.pets_rounded,
                              color: const Color(0xFFF5C518),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
                                color: const Color(0xFFFF6B4A),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    height: 6,
                                    width: 6,
                                    decoration: const BoxDecoration(
                                      color: AppColors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'LIVE',
                                    style: AppTextStyles.chipTitle(context).copyWith(
                                      fontSize: context.fs(11),
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
                              colors: [Color(0xFF0D5C3A), Color(0xFF1B5E20)],
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
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'TODAY ONLY 🔥',
                                  style: AppTextStyles.bannerButton(context).copyWith(
                                    fontSize: context.fs(11),
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
                                  color: const Color(0xFFFF7B5A),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'Claim Offer →',
                                  style: AppTextStyles.chipTitle(context),
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
                                gradient: const [Color(0xFFFF6B4A), Color(0xFFFF9A5C)],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildOfferChip(
                                context: context,
                                title: '💊 Generic Savings',
                                subtitle: 'Salt-based options',
                                gradient: const [Color(0xFF0284C7), Color(0xFF38BDF8)],
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
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.categoryLabel(context),
        ),
      ],
    );
  }

  Widget _buildOfferChip({
    required BuildContext context,
    required String title,
    required String subtitle,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.chipTitle(context),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTextStyles.chipSubtitle(context),
          ),
        ],
      ),
    );
  }
}
