import 'package:supabase_flutter/supabase_flutter.dart';
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
}
