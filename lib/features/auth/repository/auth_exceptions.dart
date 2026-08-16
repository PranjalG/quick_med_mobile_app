abstract class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

class InvalidPhoneNumberException extends AuthException {
  const InvalidPhoneNumberException([
    super.message = 'Enter a valid 10-digit Indian mobile number',
  ]);
}

class OtpVerificationFailedException extends AuthException {
  const OtpVerificationFailedException([
    super.message = 'Invalid OTP. Please check the code and try again.',
  ]);
}

class OtpTimeoutException extends AuthException {
  const OtpTimeoutException([
    super.message = 'OTP request timed out. Please try again.',
  ]);
}

class NetworkAuthException extends AuthException {
  const NetworkAuthException([
    super.message = 'Network error. Check your connection and try again.',
  ]);
}
