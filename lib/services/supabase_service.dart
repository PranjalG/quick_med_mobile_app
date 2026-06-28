import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  /// Access the global Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;

  /// Shortcut for current session
  static Session? get currentSession => client.auth.currentSession;

  /// Shortcut for current user
  static User? get currentUser => client.auth.currentUser;
}
