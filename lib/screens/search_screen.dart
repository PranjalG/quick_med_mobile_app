import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quick_med/models/medicine_model.dart';
import 'package:quick_med/services/medicine_service.dart';
import 'package:quick_med/custom_components/custom_shimmer.dart';
import 'package:quick_med/services/app_colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController =
      TextEditingController(text: 'Paracetamol');
  final MedicineService _medicineService = MedicineService();

  List<Medicine> _searchResults = [];
  bool _hasSearched = true;
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Fetch initial results for 'Paracetamol'
    _search('Paracetamol');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _search(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _medicineService.fetchMedicines(query);
      setState(() {
        _searchResults = results;
        _hasSearched = query.isNotEmpty;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _searchResults = [];
        _hasSearched = query.isNotEmpty;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _search(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                        color: Color(0xFF111827), size: 24),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 4),
                  // Search TextField Pill
                  Expanded(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: GoogleFonts.montserrat(
                                fontSize: 15,
                                color: const Color(0xFF111827),
                                fontWeight: FontWeight.w600,
                              ),
                              onChanged: _onSearchChanged,
                              decoration: InputDecoration(
                                hintText: 'Search medicines, salt or brand',
                                hintStyle: GoogleFonts.montserrat(
                                  color: const Color(0xFF9CA3AF),
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
                                  color: Color(0xFF9CA3AF), size: 20),
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: const Color(0xFFE5E7EB), width: 1),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.tune_rounded,
                          color: Color(0xFF111827), size: 20),
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
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildShimmerLoader();
    }

    if (!_hasSearched && _searchController.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_rounded,
              size: 80,
              color: const Color(0xFF9CA3AF).withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Search for medicines or products',
              style: GoogleFonts.montserrat(
                color: const Color(0xFF9CA3AF),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try typing "Paracetamol" to test search results',
              style: GoogleFonts.montserrat(
                color: const Color(0xFF9CA3AF),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  height: 140,
                  width: 140,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Results Found',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We couldn\'t find any matching medicine for "${_searchController.text}".',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            '${_searchResults.length} results found',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
        ..._searchResults.map((product) => _buildProductCard(product)),
        const SizedBox(height: 24),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, 4),
            blurRadius: 10,
          )
        ],
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
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                ),
                child: const Center(
                  child: Icon(
                    Icons.medication_rounded,
                    size: 40,
                    color: Color(0xFF4CAF50),
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
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.manufacturer,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
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
                            color: const Color(0xFF9CA3AF),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '₹${product.price.toStringAsFixed(2)}',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                AppColors.primaryDark.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.discount,
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
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
                      ? const Color(0xFFFF6B4A)
                      : const Color(0xFF9CA3AF),
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
                      size: 18, color: Color(0xFFFF7B5A)),
                  const SizedBox(width: 4),
                  Text(
                    product.deliveryTime,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFF7B5A),
                    ),
                  ),
                  if (product.rxRequired) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: const Color(0xFFBFDBFE), width: 1),
                      ),
                      child: Text(
                        'Rx Required',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1D4ED8),
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
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withValues(alpha: 0.2),
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
