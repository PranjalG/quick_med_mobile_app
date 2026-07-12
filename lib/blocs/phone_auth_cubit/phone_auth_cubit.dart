import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quick_med/services/profile_service.dart';
import 'phone_auth_state.dart';

class PhoneAuthCubit extends Cubit<PhoneAuthState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ProfileService _profileService = ProfileService();

  PhoneAuthCubit() : super(PhoneAuthInitial());

  Future<void> sendOtp(String phoneNumber) async {
    emit(PhoneAuthLoading());
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          final userCredential = await _firebaseAuth.signInWithCredential(credential);
          if (userCredential.user != null) {
            final hasProfile = await _checkHasProfile(userCredential.user!.uid);
            emit(PhoneAuthCodeVerified(hasProfile: hasProfile));
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          emit(PhoneAuthFailure(error: e.message ?? 'Phone verification failed.'));
        },
        codeSent: (String verificationId, int? resendToken) {
          emit(PhoneAuthCodeSent(verificationId: verificationId));
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      emit(PhoneAuthFailure(error: e.toString()));
    }
  }

  Future<void> verifyOtp(String verificationId, String smsCode) async {
    emit(PhoneAuthLoading());
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      if (userCredential.user != null) {
        final hasProfile = await _checkHasProfile(userCredential.user!.uid);
        emit(PhoneAuthCodeVerified(hasProfile: hasProfile));
      } else {
        emit(const PhoneAuthFailure(error: 'Failed to sign in. User not found.'));
      }
    } catch (e) {
      emit(PhoneAuthFailure(error: e.toString()));
    }
  }

  Future<bool> _checkHasProfile(String userId) async {
    try {
      final profile = await _profileService.fetchProfile(userId);
      return profile != null && profile.name.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  void reset() {
    emit(PhoneAuthInitial());
  }
}
