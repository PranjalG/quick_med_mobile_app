import 'package:flutter/foundation.dart';
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

double? _readDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
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

  /// Returns an address id owned by the caller's JWT `sub` (same rule as
  /// [place_order]). Prefer the server RPC; fall back to client insert for
  /// projects that have not applied `010_ensure_delivery_address.sql` yet.
  Future<Address> ensureDefault(String uid) async {
    try {
      final id = await _client.rpc<String>('ensure_delivery_address');
      if (id.isNotEmpty) {
        final row = await _client
            .from('addresses')
            .select()
            .eq('id', id)
            .maybeSingle();
        if (row != null) {
          return Address.fromJson(row);
        }
        return Address(id: id, label: 'Home', fullAddress: '');
      }
    } on PostgrestException catch (error) {
      if (error.code == 'PGRST202') {
        debugPrint(
          'ensure_delivery_address RPC missing — using client fallback. '
          'Apply supabase/migrations/010_ensure_delivery_address.sql',
        );
      } else {
        throw AddressException(_friendlyRpc(error));
      }
    }

    return _ensureDefaultClientSide(uid);
  }

  String _friendlyRpc(PostgrestException error) {
    final raw = error.message;
    if (error.code == '22023' && raw.contains('delivery address')) {
      return 'Add a delivery address to your profile before ordering.';
    }
    if (error.code == '28000') {
      return 'Please sign in again to place this order.';
    }
    return raw.isNotEmpty ? raw : 'Could not resolve your delivery address.';
  }

  Future<Address> _ensureDefaultClientSide(String uid) async {
    final existing = await fetchAll(uid);
    if (existing.isNotEmpty) return existing.first;

    final profile = await _client
        .from('profiles')
        .select(
          'kota_area, address_detail, address_latitude, address_longitude',
        )
        .eq('id', uid)
        .maybeSingle();

    final detail = (profile?['address_detail'] as String? ?? '').trim();
    final area = (profile?['kota_area'] as String? ?? '').trim();

    if (detail.isEmpty && area.isEmpty) {
      throw const AddressException(
        'Add a delivery address to your profile before ordering.',
      );
    }

    final lat = _readDouble(profile?['address_latitude']);
    final lng = _readDouble(profile?['address_longitude']);
    if (lat == null || lng == null) {
      throw const AddressException(
        'Pin your delivery location in Profile before ordering.',
      );
    }

    final full = [detail, area].where((p) => p.isNotEmpty).join(', ');

    final row = await _client
        .from('addresses')
        .insert({
          'user_id': uid,
          'label': 'Home',
          'full_address': full,
          'latitude': lat,
          'longitude': lng,
        })
        .select()
        .single();

    return Address.fromJson(row);
  }
}
