import 'package:supabase_flutter/supabase_flutter.dart';

class Address {
  final String id;
  final String label;
  final String fullAddress;

  const Address({
    required this.id,
    required this.label,
    required this.fullAddress,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        id: json['id'] as String? ?? '',
        label: json['label'] as String? ?? 'Home',
        fullAddress: json['full_address'] as String? ?? '',
      );
}

class AddressException implements Exception {
  final String message;
  const AddressException(this.message);

  @override
  String toString() => message;
}

class AddressService {
  AddressService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<Address>> fetchAll(String uid) async {
    final List<dynamic> rows = await _client
        .from('addresses')
        .select()
        .eq('user_id', uid)
        .order('created_at', ascending: true);
    return rows.map((r) => Address.fromJson(r as Map<String, dynamic>)).toList();
  }

  /// Returns the user's first address, creating one from their profile if they
  /// have none.
  ///
  /// `place_order` requires an address_id owned by the caller, but profile
  /// setup writes its address into `profiles.address_detail` / `kota_area`
  /// rather than into `addresses`. Without this bridge, a first-time customer
  /// could never check out. A proper address book replaces this later.
  Future<Address> ensureDefault(String uid) async {
    final existing = await fetchAll(uid);
    if (existing.isNotEmpty) return existing.first;

    final profile = await _client
        .from('profiles')
        .select('kota_area, address_detail')
        .eq('id', uid)
        .maybeSingle();

    final detail = (profile?['address_detail'] as String? ?? '').trim();
    final area = (profile?['kota_area'] as String? ?? '').trim();

    if (detail.isEmpty && area.isEmpty) {
      throw const AddressException(
        'Add a delivery address to your profile before ordering.',
      );
    }

    final full = [detail, area].where((p) => p.isNotEmpty).join(', ');

    final row = await _client
        .from('addresses')
        .insert({
          'user_id': uid,
          'label': 'Home',
          'full_address': full,
        })
        .select()
        .single();

    return Address.fromJson(row);
  }
}
