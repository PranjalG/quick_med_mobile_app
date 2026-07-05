import 'package:supabase_flutter/supabase_flutter.dart';

abstract class CustomAuthException implements Exception {
  final String message;
  const CustomAuthException(this.message);

  @override
  String toString() => message;
}

class InvalidCredentialsException extends CustomAuthException {
  const InvalidCredentialsException() : super('Invalid email or password. Please check your credentials and try again.');
}

class EmailAlreadyInUseException extends CustomAuthException {
  const EmailAlreadyInUseException() : super('This email address is already registered. Please log in instead.');
}

class WeakPasswordException extends CustomAuthException {
  const WeakPasswordException() : super('Password is too weak. Please choose a password with at least 6 characters.');
}

class InvalidEmailException extends CustomAuthException {
  const InvalidEmailException() : super('Please enter a valid email address.');
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

  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw const UnknownAuthException('Sign up failed. Please try again.');
      }
      return response;
    } on AuthException catch (e) {
      _handleAuthException(e);
      rethrow;
    } catch (e) {
      throw UnknownAuthException(e.toString());
    }
  }

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw const InvalidCredentialsException();
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
    if (msg.contains('invalid login') || msg.contains('invalid credentials') || msg.contains('confirm your email')) {
      throw const InvalidCredentialsException();
    } else if (msg.contains('already registered') || msg.contains('already exists') || msg.contains('email_exists')) {
      throw const EmailAlreadyInUseException();
    } else if (msg.contains('password should be') || msg.contains('weak password')) {
      throw const WeakPasswordException();
    } else if (msg.contains('invalid email') || msg.contains('bad email')) {
      throw const InvalidEmailException();
    } else if (msg.contains('rate limit') || msg.contains('too many requests')) {
      throw const RateLimitException();
    } else if (msg.contains('network') || msg.contains('connection')) {
      throw const NetworkException();
    } else {
      throw UnknownAuthException(e.message);
    }
  }
}
