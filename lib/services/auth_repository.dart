import 'package:supabase_flutter/supabase_flutter.dart';

abstract class CustomAuthException implements Exception {
  final String message;
  const CustomAuthException(this.message);

  @override
  String toString() => message;
}

class InvalidOtpException extends CustomAuthException {
  const InvalidOtpException() : super('The verification code is incorrect or expired. Please try again.');
}

class RateLimitException extends CustomAuthException {
  const RateLimitException() : super('Too many requests. Please wait a moment before trying again.');
}

class NetworkException extends CustomAuthException {
  const NetworkException() : super('Connection failed. Please check your internet connection.');
}

class UnknownAuthException extends CustomAuthException {
  const UnknownAuthException(super.message);
}

class AuthRepository {
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<void> sendOtp(String phoneNumber) async {
    try {
      final formattedPhone = phoneNumber.startsWith('+') ? phoneNumber : '+91$phoneNumber';
      
      // Basic validation
      if (phoneNumber.length < 10) {
        throw const UnknownAuthException('Please enter a valid 10-digit phone number.');
      }

      await _client.auth.signInWithOtp(
        phone: formattedPhone,
      );
    } on AuthException catch (e) {
      _handleAuthException(e);
    } catch (e) {
      throw UnknownAuthException(e.toString());
    }
  }

  Future<AuthResponse> verifyOtp(String phoneNumber, String token) async {
    try {
      final formattedPhone = phoneNumber.startsWith('+') ? phoneNumber : '+91$phoneNumber';
      
      final response = await _client.auth.verifyOTP(
        phone: formattedPhone,
        token: token,
        type: OtpType.sms,
      );

      if (response.user == null) {
        throw const InvalidOtpException();
      }
      return response;
    } on AuthException catch (e) {
      _handleAuthException(e);
      rethrow;
    } catch (e) {
      throw UnknownAuthException(e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw UnknownAuthException(e.toString());
    }
  }

  void _handleAuthException(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid') || msg.contains('incorrect') || msg.contains('expired')) {
      throw const InvalidOtpException();
    } else if (msg.contains('rate limit') || msg.contains('too many requests')) {
      throw const RateLimitException();
    } else if (msg.contains('network') || msg.contains('connection')) {
      throw const NetworkException();
    } else {
      throw UnknownAuthException(e.message);
    }
  }
}
