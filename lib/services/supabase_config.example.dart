import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Copy this file to `supabase_config.dart` (gitignored) and fill in your
/// Supabase project URL and **publishable/anon** key only — never service_role.
class SupabaseConfig {
  static const String url = 'https://YOUR_PROJECT_REF.supabase.co';
  static const String publishableKey = 'YOUR_SUPABASE_PUBLISHABLE_OR_ANON_KEY';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: url,
      publishableKey: publishableKey,
      accessToken: () async {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return null;
        return user.getIdToken();
      },
    );
  }
}
