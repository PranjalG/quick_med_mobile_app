import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_exceptions.dart';

class ProfileRepository {
  ProfileRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const String defaultCity = 'Kota';

  Future<void> upsertOnLogin({
    required String uid,
    required String phone,
  }) async {
    try {
      await _client.from('profiles').upsert(
        {
          'id': uid,
          'phone': phone,
          'kota_area': defaultCity,
        },
        onConflict: 'id',
      );
    } on PostgrestException catch (error, stack) {
      // Surface the real Postgres/RLS reason during development instead of
      // hiding it behind a generic message.
      if (kDebugMode) {
        debugPrint(
          'profiles upsert failed — code: ${error.code}, '
          'message: ${error.message}, details: ${error.details}, '
          'hint: ${error.hint}',
        );
        debugPrintStack(stackTrace: stack);
      }
      throw ProfileSetupException(
        'Profile setup failed: ${error.message}'
        '${error.hint != null ? ' (${error.hint})' : ''}',
      );
    } catch (error, stack) {
      if (kDebugMode) {
        debugPrint('profiles upsert failed (non-Postgrest): $error');
        debugPrintStack(stackTrace: stack);
      }
      throw const ProfileSetupException();
    }
  }
}
