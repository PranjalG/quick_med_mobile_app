import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quick_med/models/category_model.dart';
import 'package:quick_med/models/medicine_model.dart';

class MedicineService {
  final SupabaseClient _client = Supabase.instance.client;

  // Local simulated fallback data matching your exact database records
  static final List<Medicine> _localFallbackMedicines = [
    Medicine(
      id: 'c6e1de97-9dcd-42e3-b859-cb03aa2a0469',
      name: 'Dolo 650',
      saltId: '240eef85-dd97-440d-891d-88b8b4aab5f5',
      manufacturer: 'Micro Labs',
      mrp: 36.00,
      price: 32.00,
      discount: '11% OFF',
      deliveryTime: '30 min delivery',
      rxRequired: false,
      stockQty: 50,
    ),
    Medicine(
      id: 'b9cff14d-9161-4044-a12c-3e814e0a57fb',
      name: 'Calpol 650',
      saltId: '240eef85-dd97-440d-891d-88b8b4aab5f5',
      manufacturer: 'GSK',
      mrp: 30.00,
      price: 27.00,
      discount: '10% OFF',
      deliveryTime: '30 min delivery',
      rxRequired: false,
      stockQty: 50,
    ),
    Medicine(
      id: 'bb490884-6a68-493c-9a74-81851207a184',
      name: 'Cetrizine Generic',
      saltId: '0d07351a-7fe8-4645-a536-11075e091309',
      manufacturer: 'Local Pharma',
      mrp: 15.00,
      price: 12.00,
      discount: '20% OFF',
      deliveryTime: '30 min delivery',
      rxRequired: false,
      stockQty: 50,
    ),
    Medicine(
      id: '483852cf-2962-4b6e-b800-bad280b86571',
      name: 'Pantocid 40',
      saltId: 'cf7c25c7-1897-477a-bab1-07d5379cdd53',
      manufacturer: 'Sun Pharma',
      mrp: 85.00,
      price: 78.00,
      discount: '8% OFF',
      deliveryTime: '30 min delivery',
      rxRequired: true,
      stockQty: 50,
    ),
  ];

  /// Queries the Supabase 'medicines' table using your schema columns.
  /// Falls back to your local mock records in case of exceptions.
  Future<List<Medicine>> fetchMedicines(String query) async {
    try {
      var supabaseQuery = _client.from('medicines').select();

      if (query.trim().isNotEmpty) {
        // Query by product name or manufacturer name case-insensitively
        supabaseQuery = supabaseQuery.or('name.ilike.%$query%,manufacturer.ilike.%$query%');
      }

      final List<dynamic> data = await supabaseQuery;
      return data.map((json) => Medicine.fromJson(json as Map<String, dynamic>)).toList();
    } catch (_) {
      // Fallback matching logic
      if (query.trim().isEmpty) {
        return _localFallbackMedicines;
      }
      final lowerQuery = query.toLowerCase();
      return _localFallbackMedicines
          .where((med) =>
              med.name.toLowerCase().contains(lowerQuery) ||
              med.manufacturer.toLowerCase().contains(lowerQuery))
          .toList();
    }
  }

  /// True when the last catalogue read fell back to bundled constants.
  ///
  /// The app silently served [_localFallbackMedicines] as if it were live data
  /// for a long time. Anything reading the catalogue should be able to tell.
  bool lastReadUsedFallback = false;

  Future<List<MedicineCategory>> fetchCategories() async {
    final List<dynamic> data = await _client
        .from('categories')
        .select()
        .order('sort_order', ascending: true);
    return data
        .map((j) => MedicineCategory.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  /// Whole catalogue in ONE round trip, grouped by category client-side.
  ///
  /// Deliberately not a query per category: six categories would mean seven
  /// round trips on the landing screen's first paint.
  Future<Map<MedicineCategory, List<Medicine>>> fetchCatalogue({
    int perCategory = 5,
  }) async {
    try {
      final categories = await fetchCategories();
      final List<dynamic> data = await _client
          .from('medicines')
          .select()
          .order('name', ascending: true);

      final medicines = data
          .map((j) => Medicine.fromJson(j as Map<String, dynamic>))
          .toList();

      final byCategory = <MedicineCategory, List<Medicine>>{};
      for (final category in categories) {
        final matching =
            medicines.where((m) => m.categoryId == category.id).toList();
        if (matching.isEmpty) continue;
        byCategory[category] =
            matching.take(perCategory).toList(growable: false);
      }

      if (byCategory.isEmpty) {
        throw StateError('catalogue query returned no categorised medicines');
      }

      lastReadUsedFallback = false;
      return byCategory;
    } catch (error, stack) {
      lastReadUsedFallback = true;
      debugPrint(
        'MedicineService.fetchCatalogue FELL BACK to bundled constants. '
        'The catalogue you are seeing is NOT live data. Cause: $error',
      );
      debugPrintStack(stackTrace: stack, maxFrames: 6);
      return {
        const MedicineCategory(
          id: 'fallback',
          slug: 'general_medicine',
          name: 'General Medicine',
          iconAsset: 'assets/icons/capsules.svg',
        ): _localFallbackMedicines,
      };
    }
  }

  Future<List<Medicine>> fetchMedicinesByCategory(
    String categoryId, {
    int limit = 50,
  }) async {
    final List<dynamic> data = await _client
        .from('medicines')
        .select()
        .eq('category_id', categoryId)
        .order('name', ascending: true)
        .limit(limit);
    return data
        .map((j) => Medicine.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  /// Ranked search via the `search_medicines` RPC (full-text + trigram).
  ///
  /// Falls back to the previous ILIKE query, then to bundled constants, so a
  /// missing migration degrades instead of breaking. [lastReadUsedFallback]
  /// records which path ran.
  Future<List<Medicine>> searchMedicines(String query, {int limit = 20}) async {
    final q = query.trim();
    if (q.isEmpty) {
      lastReadUsedFallback = false;
      return const [];
    }

    try {
      final List<dynamic> data = await _client.rpc(
        'search_medicines',
        params: {'q': q, 'limit_count': limit},
      );
      lastReadUsedFallback = false;
      return data
          .map((j) => Medicine.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (error) {
      debugPrint(
        'search_medicines RPC unavailable ($error) — falling back to ILIKE. '
        'Run supabase/migrations/004_search.sql for ranked search.',
      );
      return fetchMedicines(q);
    }
  }
}
