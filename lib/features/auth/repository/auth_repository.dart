import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import 'auth_exceptions.dart';

class SendOtpResult {
  final String? verificationId;
  final User? autoVerifiedUser;

  const SendOtpResult._({this.verificationId, this.autoVerifiedUser});

  factory SendOtpResult.codeSent(String verificationId) =>
      SendOtpResult._(verificationId: verificationId);

  factory SendOtpResult.autoVerified(User user) =>
      SendOtpResult._(autoVerifiedUser: user);
}

class AuthRepository {
  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  String? _lastVerificationId;
  int? _resendToken;
  String? _lastPhoneE164;

  String? get lastPhoneE164 => _lastPhoneE164;

  /// Called when Android auto-verifies the number after the code was already
  /// sent (the UI is on the OTP screen), so the caller can finish sign-in
  /// without waiting for the user to type the code.
  void Function(User user)? onLateAutoVerification;

  bool get hasActiveVerification => _lastVerificationId != null;

  static final RegExp _indianMobilePattern = RegExp(r'^\+91[6-9]\d{9}$');

  String normalizeIndianPhone(String input) {
    final cleaned = input.trim().replaceAll(RegExp(r'[\s\-()]'), '');

    if (cleaned.startsWith('+91')) {
      return cleaned;
    }
    if (cleaned.startsWith('91') && cleaned.length == 12) {
      return '+$cleaned';
    }
    if (RegExp(r'^\d{10}$').hasMatch(cleaned)) {
      return '+91$cleaned';
    }
    if (cleaned.startsWith('+') && !cleaned.startsWith('+91')) {
      throw const InvalidPhoneNumberException(
        'Only Indian mobile numbers (+91) are supported at launch.',
      );
    }

    throw const InvalidPhoneNumberException();
  }

  void validateIndianPhone(String e164Phone) {
    if (!_indianMobilePattern.hasMatch(e164Phone)) {
      throw const InvalidPhoneNumberException();
    }
  }

  Future<SendOtpResult> sendOtp(String phoneNumber) async {
    final e164 = normalizeIndianPhone(phoneNumber);
    validateIndianPhone(e164);
    _lastPhoneE164 = e164;

    return _requestOtp(e164);
  }

  Future<String> resendOtp() async {
    if (_lastPhoneE164 == null) {
      throw const OtpVerificationFailedException(
        'No phone number on file. Go back and enter your number again.',
      );
    }

    final result = await _requestOtp(
      _lastPhoneE164!,
      forceResendingToken: _resendToken,
    );

    if (result.autoVerifiedUser != null) {
      return _lastVerificationId ?? '';
    }

    return result.verificationId!;
  }

  Future<SendOtpResult> _requestOtp(
    String e164Phone, {
    int? forceResendingToken,
  }) async {
    final completer = Completer<SendOtpResult>();

    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: e164Phone,
      forceResendingToken: forceResendingToken,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          final userCredential =
              await _firebaseAuth.signInWithCredential(credential);
          final user = userCredential.user;
          if (user == null) return;
          if (!completer.isCompleted) {
            completer.complete(SendOtpResult.autoVerified(user));
          } else {
            onLateAutoVerification?.call(user);
          }
        } catch (_) {
          if (!completer.isCompleted) {
            completer.completeError(const OtpVerificationFailedException());
          }
        }
      },
      verificationFailed: (FirebaseAuthException error) {
        if (!completer.isCompleted) {
          completer.completeError(_mapFirebaseException(error));
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        _lastVerificationId = verificationId;
        _resendToken = resendToken;
        if (!completer.isCompleted) {
          completer.complete(SendOtpResult.codeSent(verificationId));
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _lastVerificationId = verificationId;
      },
    );

    return completer.future.timeout(
      const Duration(seconds: 65),
      onTimeout: () => throw const OtpTimeoutException(),
    );
  }

  /// The signed-in Firebase user, if it is the number we are verifying.
  ///
  /// Android can verify the number on its own (instant verification or SMS
  /// auto-retrieval) and sign the user in through `verificationCompleted`,
  /// after `codeSent` has already moved the UI to the OTP screen. That uses up
  /// the code, so submitting it manually afterwards fails with
  /// `session-expired`. Checking for an existing sign-in avoids reporting a
  /// successful login as an expired OTP.
  User? _alreadySignedInForPendingPhone() {
    final user = _firebaseAuth.currentUser;
    if (user == null || _lastPhoneE164 == null) return null;
    return user.phoneNumber == _lastPhoneE164 ? user : null;
  }

  Future<User> verifyOtp(String smsCode, {String? verificationId}) async {
    final alreadySignedIn = _alreadySignedInForPendingPhone();
    if (alreadySignedIn != null) return alreadySignedIn;

    final id = verificationId ?? _lastVerificationId;
    if (id == null) {
      throw const OtpVerificationFailedException(
        'No OTP request in progress. Request a new code.',
      );
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: id,
        smsCode: smsCode.trim(),
      );
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        throw const OtpVerificationFailedException();
      }
      return user;
    } on FirebaseAuthException catch (error) {
      // Auto-verification may have signed the user in while this request was
      // in flight; that is a success, not an expired code.
      final signedIn = _alreadySignedInForPendingPhone();
      if (signedIn != null) return signedIn;
      throw _mapFirebaseException(error);
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const OtpVerificationFailedException();
    }
  }

  AuthException _mapFirebaseException(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-phone-number':
        return const InvalidPhoneNumberException();
      case 'session-expired':
        return const OtpTimeoutException(
          'This OTP has expired or was already used. Tap Resend for a new code.',
        );
      case 'invalid-verification-code':
        return const OtpVerificationFailedException();
      case 'network-request-failed':
        return NetworkAuthException(error.message ?? 'Network error.');
      default:
        return OtpVerificationFailedException(
          error.message ?? 'Phone verification failed.',
        );
    }
  }
}
