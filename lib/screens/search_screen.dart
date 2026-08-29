import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_med/blocs/search_cubit/search_cubit.dart';
import 'package:quick_med/models/medicine_model.dart';
import 'package:quick_med/services/app_theme.dart';
import 'package:quick_med/custom_components/custom_shimmer.dart';
import 'package:quick_med/services/app_colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final SearchCubit _cubit = SearchCubit();

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {}); // keep the clear-button visibility in sync
    _cubit.queryChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Search Header Row
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  // Back Arrow Button
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: AppColors.textPrimary, size: 24),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 4),
                  // Search TextField Pill
                  Expanded(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.inputBorder,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: GoogleFonts.montserrat(
                                fontSize: 15,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              onChanged: _onSearchChanged,
                              decoration: InputDecoration(
                                hintText: 'Search medicines, salt or brand',
                                hintStyle: GoogleFonts.montserrat(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                              child: const Icon(Icons.close_rounded,
                                  color: AppColors.textSecondary, size: 20),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Sliders / Filter Button
                   Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: AppColors.inputBorder, width: 1.5),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.tune_rounded,
                          color: AppColors.textPrimary, size: 20),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Filter settings clicked')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // 2. Main Content Area
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildContent() {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        return switch (state) {
          SearchIdle() => _buildPrompt(),
          SearchLoading() => _buildShimmerLoader(),
          SearchNoResults(:final query) => _buildNoResults(query),
          SearchFailure(:final query, :final message) =>
            _buildError(query, message),
          SearchResults(:final results) => _buildResults(results),
        };
      },
    );
  }

  /// Nothing typed yet.
  Widget _buildPrompt() {
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_rounded,
                size: 80, color: AppColors.secondaryBlue.withValues(alpha: 0.4)),
            const SizedBox(height: AppSpacing.lg),
            Text('Search for medicines or products',
                style: text.titleSmall, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text('Search by brand, salt or manufacturer',
                style: text.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults(String query) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 140,
              width: 140,
              decoration: const BoxDecoration(
                color: AppColors.cardBackground,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.inventory_2_outlined,
                  size: 56, color: AppColors.secondaryBlue),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('No results for "$query"',
                style: text.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text('Check the spelling, or try the salt name instead of the brand.',
                style: text.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String query, String message) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 56, color: AppColors.secondaryBlue),
            const SizedBox(height: AppSpacing.lg),
            Text('Search failed', style: text.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(message,
                style: text.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: () => _cubit.searchNow(query),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(List<Medicine> results) {
    final text = Theme.of(context).textTheme;
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Text(
            '${results.length} result${results.length == 1 ? '' : 's'} found',
            style: text.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
        ),
        ...results.map(_buildProductCard),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _buildShimmerLoader() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: 3,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.inputBorder, width: 1.5),
        ),
        child: const Column(
          children: [
            Row(
              children: [
                CustomShimmer(
                    width: 80,
                    height: 80,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomShimmer(width: 150, height: 16),
                      SizedBox(height: 6),
                      CustomShimmer(width: 100, height: 12),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          CustomShimmer(width: 60, height: 12),
                          SizedBox(width: 8),
                          CustomShimmer(width: 40, height: 16),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomShimmer(width: 120, height: 14),
                CustomShimmer(
                    width: 100,
                    height: 36,
                    borderRadius: BorderRadius.all(Radius.circular(18))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Medicine product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder, width: 1.0),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image Mock Box
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: AppColors.disabled,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.inputBorder, width: 1),
                ),
                child: const Center(
                  child: Icon(
                    Icons.medication_rounded,
                    size: 40,
                    color: AppColors.secondaryBlue,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.manufacturer,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Price & Discount Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'MRP ₹${product.mrp.toStringAsFixed(2)}',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.neutral,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '₹${product.price.toStringAsFixed(2)}',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                AppColors.secondaryBlue.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.discount,
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Favorite Heart Icon
              GestureDetector(
                onTap: () {
                  setState(() {
                    product.isFavorite = !product.isFavorite;
                  });
                },
                child: Icon(
                  product.isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_outline_rounded,
                  color: product.isFavorite
                      ? AppColors.accent
                      : AppColors.neutral,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Delivery & Add to Cart Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.bolt_rounded,
                      size: 18, color: AppColors.accent),
                  const SizedBox(width: 4),
                  Text(
                    product.deliveryTime,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                  if (product.rxRequired) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: AppColors.secondaryBlue, width: 1),
                      ),
                      child: Text(
                        'Rx Required',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryTeal,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              // Add to Cart Button
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBlue,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondaryBlue.withValues(alpha: 0.2),
                      offset: const Offset(0, 3),
                      blurRadius: 6,
                    )
                  ],
                ),
                child: Center(
                  child: Text(
                    'Add to Cart',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
