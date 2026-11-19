import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Bridges Firebase Phone Auth to Supabase (third-party JWT / RLS).
class SupabaseSessionException implements Exception {
  final String message;
  const SupabaseSessionException(this.message);

  @override
  String toString() => message;
}

/// Shown when Supabase treats the signed-in user as anonymous because their
/// Firebase token has no `role: authenticated` claim, so RPCs granted only
/// to `authenticated` (checkout) fail with "permission denied for function".
const String guestRoleMessage =
    'Ordering isn\'t enabled for your account yet — the server sees you as a '
    'guest. Sign out and back in; if it persists, contact support.';

/// True for Postgres "permission denied for function …" errors, which is how
/// a missing `role: authenticated` claim shows up on checkout RPCs.
bool isGuestRoleDenial(String? code, String message) =>
    code == '42501' && message.contains('permission denied for function');

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
      final result = await firebaseUser.getIdTokenResult(forceRefresh);
      final idToken = result.token;
      if (idToken == null || idToken.isEmpty) {
        throw const SupabaseSessionException(
          'Could not read your login token. Please try again.',
        );
      }
      // Without this claim Supabase runs every request as `anon`.
      if (result.claims?['role'] != 'authenticated') {
        debugPrint(
          'Firebase ID token has no role: "authenticated" claim, so Supabase '
          'treats this user as anon and checkout RPCs will be denied. Set the '
          'claim with the Firebase Admin SDK (see Supabase docs: Third-party '
          'auth → Firebase).',
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
