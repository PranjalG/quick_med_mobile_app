import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class AuthService {
  static String? get currentUserId {
    final fbUser = fb.FirebaseAuth.instance.currentUser;
    if (fbUser != null) return fbUser.uid;

    final sbUser = sb.Supabase.instance.client.auth.currentUser;
    if (sbUser != null) return sbUser.id;

    return null;
  }

  static String? get currentUserEmail {
    final fbUser = fb.FirebaseAuth.instance.currentUser;
    if (fbUser != null) return fbUser.email;

    final sbUser = sb.Supabase.instance.client.auth.currentUser;
    if (sbUser != null) return sbUser.email;

    return null;
  }

  static String? get currentUserPhone {
    final fbUser = fb.FirebaseAuth.instance.currentUser;
    if (fbUser != null) return fbUser.phoneNumber;

    final sbUser = sb.Supabase.instance.client.auth.currentUser;
    if (sbUser != null) return sbUser.phone;

    return null;
  }

  static Future<void> signOut() async {
    await fb.FirebaseAuth.instance.signOut();
    await sb.Supabase.instance.client.auth.signOut();
  }
}
