import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:supabase_flutter/supabase_flutter.dart';

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

  static Future<void> signOut() async {
    await fb.FirebaseAuth.instance.signOut();
    await Supabase.instance.client.auth.signOut();
  }
}
