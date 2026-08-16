import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://glbbmeyaeesinllcvgox.supabase.co';
  static const String publishableKey =
      'sb_publishable_ebiP3jOmdXUsNG08QiLnSg_S986TfhF';

  /// Initializes Supabase with a Firebase ID token for Third-Party Auth.
  ///
  /// Call this **after** [Firebase.initializeApp] so RLS-protected
  /// Postgres/Storage/Realtime requests run as the signed-in Firebase user.
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
