import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepository {
  ProfileRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const String defaultCity = 'Kota';

  Future<void> upsertOnLogin({
    required String uid,
    required String phone,
  }) async {
    await _client.from('profiles').upsert(
      {
        'id': uid,
        'phone': phone,
        'kota_area': defaultCity,
      },
      onConflict: 'id',
    );
  }
}
