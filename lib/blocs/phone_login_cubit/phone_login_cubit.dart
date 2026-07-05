import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_med/services/auth_repository.dart';
import 'package:quick_med/services/profile_service.dart';
import 'phone_login_state.dart';

class PhoneLoginCubit extends Cubit<PhoneLoginState> {
  final AuthRepository _authRepository = AuthRepository();
  final ProfileService _profileService = ProfileService();

  PhoneLoginCubit() : super(PhoneLoginInitial());

  Future<void> sendOtp(String phoneNumber) async {
    emit(PhoneLoginLoading());
    try {
      await _authRepository.sendOtp(phoneNumber);
      emit(PhoneLoginSuccess());
    } on CustomAuthException catch (e) {
      emit(PhoneLoginFailure(error: e.message));
    } catch (e) {
      emit(PhoneLoginFailure(error: e.toString()));
    }
  }

  Future<void> verifyOtp(String phoneNumber, String token) async {
    emit(PhoneOtpVerifying());
    try {
      final response = await _authRepository.verifyOtp(phoneNumber, token);

      if (response.user != null) {
        bool hasProfile = false;
        try {
          final profile = await _profileService.fetchProfile(response.user!.id);
          if (profile != null && profile.name.isNotEmpty) {
            hasProfile = true;
          }
        } catch (e) {
          hasProfile = false;
        }
        emit(PhoneOtpVerifySuccess(hasProfile: hasProfile));
      } else {
        emit(const PhoneOtpVerifyFailure(error: 'Verification failed. Please try again.'));
      }
    } on CustomAuthException catch (e) {
      emit(PhoneOtpVerifyFailure(error: e.message));
    } catch (e) {
      emit(PhoneOtpVerifyFailure(error: e.toString()));
    }
  }
}
