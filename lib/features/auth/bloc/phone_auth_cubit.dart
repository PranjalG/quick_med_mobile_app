import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/auth_exceptions.dart';
import '../repository/auth_repository.dart';
import '../repository/profile_repository.dart';
import 'phone_auth_state.dart';

class PhoneAuthCubit extends Cubit<PhoneAuthState> {
  PhoneAuthCubit({
    AuthRepository? authRepository,
    ProfileRepository? profileRepository,
  })  : _authRepository = authRepository ?? AuthRepository(),
        _profileRepository = profileRepository ?? ProfileRepository(),
        super(const PhoneAuthInitial());

  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;

  String? _phoneDisplay;

  bool get hasActiveVerification => _authRepository.hasActiveVerification;

  String get phoneDisplay => _phoneDisplay ?? '';

  String _formatPhoneDisplay(String e164) {
    if (e164.startsWith('+91') && e164.length == 13) {
      final local = e164.substring(3);
      return '+91 ${local.substring(0, 5)} ${local.substring(5)}';
    }
    return e164;
  }

  Future<void> sendOtp(String phoneNumber) async {
    emit(const PhoneAuthCodeSending());
    try {
      final result = await _authRepository.sendOtp(phoneNumber);
      final e164 = _authRepository.lastPhoneE164 ?? phoneNumber;
      _phoneDisplay = _formatPhoneDisplay(e164);

      if (result.autoVerifiedUser != null) {
        await _completeSignIn(result.autoVerifiedUser!);
        return;
      }

      emit(
        PhoneAuthCodeSent(
          verificationId: result.verificationId!,
          phoneDisplay: _phoneDisplay!,
        ),
      );
    } on AuthException catch (error) {
      emit(PhoneAuthFailure(message: error.message));
    } catch (_) {
      emit(
        const PhoneAuthFailure(
          message: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  Future<void> verifyOtp(String smsCode) async {
    final phoneDisplay = _phoneDisplay ?? '';
    emit(PhoneAuthVerifying(phoneDisplay: phoneDisplay));
    try {
      final user = await _authRepository.verifyOtp(smsCode);
      await _completeSignIn(user);
    } on AuthException catch (error) {
      emit(PhoneAuthFailure(message: error.message));
    } catch (_) {
      emit(
        const PhoneAuthFailure(
          message: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  Future<void> resendOtp() async {
    emit(const PhoneAuthCodeSending());
    try {
      final verificationId = await _authRepository.resendOtp();
      emit(
        PhoneAuthCodeSent(
          verificationId: verificationId,
          phoneDisplay: _phoneDisplay ?? '',
        ),
      );
    } on AuthException catch (error) {
      emit(PhoneAuthFailure(message: error.message));
    } catch (_) {
      emit(
        const PhoneAuthFailure(
          message: 'Could not resend OTP. Please try again.',
        ),
      );
    }
  }

  Future<void> _completeSignIn(User user) async {
    try {
      final phone = user.phoneNumber ?? _authRepository.lastPhoneE164 ?? '';
      await _profileRepository.upsertOnLogin(uid: user.uid, phone: phone);
      emit(PhoneAuthSuccess(user: user));
    } catch (_) {
      emit(
        const PhoneAuthFailure(
          message: 'Signed in, but profile setup failed. Please try again.',
        ),
      );
    }
  }

  void resetToPhoneEntry() {
    _phoneDisplay = null;
    emit(const PhoneAuthInitial());
  }
}
