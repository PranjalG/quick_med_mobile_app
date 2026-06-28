import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quick_med/services/theme_colours.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ProductMock> _allProducts = [];
  List<ProductMock> _searchResults = [];
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _allProducts = [
      ProductMock(
        name: 'Dolo 650 mg Tablet',
        salt: 'Paracetamol 650mg',
        mrp: 35.62,
        price: 25.64,
        discount: '28% OFF',
        deliveryTime: '30 min delivery',
        rxRequired: false,
      ),
      ProductMock(
        name: 'Calpol 500 mg Tablet',
        salt: 'Paracetamol 500mg',
        mrp: 42.00,
        price: 30.24,
        discount: '28% OFF',
        deliveryTime: '45 min delivery',
        rxRequired: true,
      ),
      ProductMock(
        name: 'Paracetamol 650 mg Tablet',
        salt: 'Paracetamol 650mg',
        mrp: 38.50,
        price: 26.95,
        discount: '30% OFF',
        deliveryTime: '30 min delivery',
        rxRequired: false,
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (value.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    final query = value.trim().toLowerCase();
    
    // Check if the query contains generic paracetamol terms to show matches,
    // otherwise if it's some unknown query, it will result in empty state
    if (query.contains('para') || query.contains('dolo') || query.contains('calpol')) {
      setState(() {
        _searchResults = _allProducts;
        _hasSearched = true;
      });
    } else {
      setState(() {
        _searchResults = [];
        _hasSearched = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  // Back Button
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  // Search Input Box
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: GoogleFonts.montserrat(
                                fontSize: 15,
                                color: const Color(0xFF111827),
                                fontWeight: FontWeight.w500,
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
                            IconButton(
                              icon: const Icon(Icons.close, color: Color(0xFF9CA3AF), size: 18),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Filter Slider Button
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.tune_rounded, color: ThemeColours.darkGreen, size: 20),
                      onPressed: () {
                        // Mock filter action
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Filter settings clicked (Mock)')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (!_hasSearched) {
      // Default / Welcome state showing helper tips
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
      // Empty State
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Empty state illustration
              Center(
                child: Container(
                  height: 180,
                  width: 180,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'No Results Found',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Try searching by salt name, generic name, or check your spelling.',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: const Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              // Search by Salt button
              GestureDetector(
                onTap: () {
                  _searchController.text = 'Paracetamol';
                  _onSearchChanged('Paracetamol');
                },
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: ThemeColours.darkGreen,
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Search by Salt Name (Paracetamol)',
                    style: GoogleFonts.montserrat(
                      color: ThemeColours.darkGreen,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Browse all categories text
              Center(
                child: TextButton(
                  onPressed: () {
                    context.pop(); // Go back to Home / Categories
                  },
                  child: Text(
                    'Browse All Categories',
                    style: GoogleFonts.montserrat(
                      color: ThemeColours.darkGreen,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Results State
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results Count Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Text(
            '${_searchResults.length} results found',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
        // Product List
        Expanded(
          child: ListView.builder(
            itemCount: _searchResults.length,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            itemBuilder: (context, index) {
              final product = _searchResults[index];
              return _buildProductCard(product);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(ProductMock product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image placeholder
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.medication_liquid_rounded,
                  size: 40,
                  color: ThemeColours.darkGreen,
                ),
              ),
              const SizedBox(width: 16),
              // Product details
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
                      product.salt,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Price row
                    Row(
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
                            color: const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Discount Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF53E88B).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.discount,
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF15BE77),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Heart icon button
              IconButton(
                icon: const Icon(Icons.favorite_border_rounded, color: Color(0xFF9CA3AF), size: 20),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFE5E7EB), thickness: 1.0),
          const SizedBox(height: 8),
          // Delivery Speed and Add to Cart Button row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.flash_on_rounded, color: Color(0xFFFF6B4A), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    product.deliveryTime,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              // Rx Required badge if applicable
              if (product.rxRequired)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B4A).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Rx Required',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFF6B4A),
                    ),
                  ),
                ),
              // Add to Cart Button
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${product.name} added to cart (Mock)')),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: ThemeColours.darkGreen,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    'Add to Cart',
                    style: GoogleFonts.montserrat(
                      color: ThemeColours.darkGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
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

class ProductMock {
  final String name;
  final String salt;
  final double mrp;
  final double price;
  final String discount;
  final String deliveryTime;
  final bool rxRequired;

  ProductMock({
    required this.name,
    required this.salt,
    required this.mrp,
    required this.price,
    required this.discount,
    required this.deliveryTime,
    required this.rxRequired,
  });
}
