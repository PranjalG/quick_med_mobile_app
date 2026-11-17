import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Bridges Firebase Phone Auth to Supabase (third-party JWT / RLS).
class SupabaseSessionException implements Exception {
  final String message;
  const SupabaseSessionException(this.message);

  @override
  String toString() => message;
}

class SupabaseAuthBridge {
  /// Makes sure the Firebase ID token Supabase will receive is valid.
  ///
  /// Supabase is initialised with the `accessToken` option
  /// (see `supabase_config.dart`), which is Supabase's Third-Party Auth mode
  /// for Firebase: every Postgres, Storage and Realtime request already carries
  /// the current Firebase ID token. In that mode `client.auth` is disabled, so
  /// there is no Supabase session to create — calling `signInWithIdToken` or
  /// `auth.signOut()` throws. All this needs to do is refresh the Firebase
  /// token so the next request does not go out with an expired one.
  static Future<void> syncSessionFromFirebase(
      {bool forceRefresh = false}) async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return;

    try {
      final idToken = await firebaseUser.getIdToken(forceRefresh);
      if (idToken == null || idToken.isEmpty) {
        throw const SupabaseSessionException(
          'Could not read your login token. Please try again.',
        );
      }
    } on FirebaseAuthException catch (error) {
      debugPrint(
          'Firebase ID token refresh failed: ${error.code} ${error.message}');
      throw const SupabaseSessionException(
        'Your login session could not be refreshed. Please sign in again.',
      );
    }
  }
}
