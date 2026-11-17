import 'package:firebase_auth/firebase_auth.dart' as fb;

class AuthService {
  static String? get currentUserId {
    return fb.FirebaseAuth.instance.currentUser?.uid;
  }

  static String? get currentUserEmail {
    return fb.FirebaseAuth.instance.currentUser?.email;
  }

  static String? get currentUserPhone {
    return fb.FirebaseAuth.instance.currentUser?.phoneNumber;
  }

  /// Signing out of Firebase is enough: Supabase runs in Third-Party Auth mode
  /// and authenticates each request with the Firebase ID token, so once the
  /// Firebase user is gone Supabase requests are anonymous. `client.auth` is
  /// disabled in that mode and calling `auth.signOut()` would throw.
  static Future<void> signOut() async {
    await fb.FirebaseAuth.instance.signOut();
  }
}
