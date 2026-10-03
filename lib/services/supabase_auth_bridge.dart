import 'package:firebase_auth/firebase_auth.dart' hide OAuthProvider;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Bridges Firebase Phone Auth to Supabase (third-party JWT / RLS).
class SupabaseSessionException implements Exception {
  final String message;
  const SupabaseSessionException(this.message);

  @override
  String toString() => message;
}

class SupabaseAuthBridge {
  static const OAuthProvider _firebase = OAuthProvider('firebase');

  /// Exchanges the current Firebase ID token for a Supabase session.
  ///
  /// Required for Storage RLS and Postgres policies that use `auth.jwt()`.
  /// The `accessToken` callback on [Supabase.initialize] alone is not enough
  /// for every API (notably Storage) unless a session exists.
  static Future<void> syncSessionFromFirebase({bool forceRefresh = false}) async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final client = Supabase.instance.client;

    if (firebaseUser == null) {
      await client.auth.signOut();
      return;
    }

    final idToken = await firebaseUser.getIdToken(forceRefresh);
    if (idToken == null || idToken.isEmpty) {
      throw const SupabaseSessionException(
        'Could not read your login token. Please try again.',
      );
    }

    try {
      await client.auth.signInWithIdToken(
        provider: _firebase,
        idToken: idToken,
      );
    } on AuthException catch (error) {
      debugPrint('Supabase signInWithIdToken failed: ${error.message}');
      throw SupabaseSessionException(_friendlyAuthError(error.message));
    }
  }

  static String _friendlyAuthError(String? raw) {
    final message = raw?.toLowerCase() ?? '';
    if (message.contains('provider') ||
        message.contains('firebase') ||
        message.contains('verification') ||
        message.contains('id_token')) {
      return 'Supabase is not linked to Firebase. In the Supabase Dashboard, open '
          'Authentication → Sign In / Providers → Third-party auth, enable Firebase, '
          'and set your Firebase project ID (quickmed-fb84a). Then sign out and sign in again.';
    }
    return 'Server login failed. Sign out, sign in with OTP again, and retry.';
  }
}
