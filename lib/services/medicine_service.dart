import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quick_med/models/medicine_model.dart';

class MedicineService {
  final SupabaseClient _client = Supabase.instance.client;

  // Local simulated fallback data representing standard drugstore inventory in Kota
  static final List<Medicine> _localFallbackMedicines = [
    Medicine(
      id: 'sim_1',
      name: 'Dolo 650 mg Tablet',
      salt: 'Paracetamol 650mg',
      mrp: 35.62,
      price: 25.64,
      discount: '28% OFF',
      deliveryTime: '30 min delivery',
      rxRequired: false,
    ),
    Medicine(
      id: 'sim_2',
      name: 'Calpol 500 mg Tablet',
      salt: 'Paracetamol 500mg',
      mrp: 42.00,
      price: 30.24,
      discount: '28% OFF',
      deliveryTime: '45 min delivery',
      rxRequired: true,
    ),
    Medicine(
      id: 'sim_3',
      name: 'Allegra 120 mg Tablet',
      salt: 'Fexofenadine Hydrochloride 120mg',
      mrp: 215.00,
      price: 161.25,
      discount: '25% OFF',
      deliveryTime: '30 min delivery',
      rxRequired: false,
    ),
    Medicine(
      id: 'sim_4',
      name: 'Pan-D Capsule',
      salt: 'Pantoprazole 40mg + Domperidone 30mg',
      mrp: 198.50,
      price: 148.87,
      discount: '25% OFF',
      deliveryTime: '40 min delivery',
      rxRequired: true,
    ),
    Medicine(
      id: 'sim_5',
      name: 'Cetirizine 10 mg Tablet',
      salt: 'Cetirizine Dihydrochloride 10mg',
      mrp: 18.20,
      price: 12.74,
      discount: '30% OFF',
      deliveryTime: '30 min delivery',
      rxRequired: false,
    ),
    Medicine(
      id: 'sim_6',
      name: 'Okacet Tablet',
      salt: 'Cetirizine 10mg',
      mrp: 22.00,
      price: 16.50,
      discount: '25% OFF',
      deliveryTime: '30 min delivery',
      rxRequired: false,
    ),
    Medicine(
      id: 'sim_7',
      name: 'Amoxyclav 625 Tablet',
      salt: 'Amoxicillin 500mg + Clavulanic Acid 125mg',
      mrp: 223.50,
      price: 167.62,
      discount: '25% OFF',
      deliveryTime: '45 min delivery',
      rxRequired: true,
    ),
  ];

  /// Queries the Supabase 'medicines' table.
  /// Falls back to local database lists in case of exceptions or absent tables.
  Future<List<Medicine>> fetchMedicines(String query) async {
    try {
      var supabaseQuery = _client.from('medicines').select();

      if (query.trim().isNotEmpty) {
        supabaseQuery = supabaseQuery.or('name.ilike.%$query%,salt.ilike.%$query%');
      }

      final List<dynamic> data = await supabaseQuery;
      return data.map((json) => Medicine.fromJson(json as Map<String, dynamic>)).toList();
    } catch (_) {
      // Fallback in case table doesn't exist yet
      if (query.trim().isEmpty) {
        return _localFallbackMedicines;
      }
      final lowerQuery = query.toLowerCase();
      return _localFallbackMedicines
          .where((med) =>
              med.name.toLowerCase().contains(lowerQuery) ||
              med.salt.toLowerCase().contains(lowerQuery))
          .toList();
    }
  }
}
