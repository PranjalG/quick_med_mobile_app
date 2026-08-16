import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  /// Access the global Supabase client instance for Postgres/Storage/Realtime.
  static SupabaseClient get client => Supabase.instance.client;
}
