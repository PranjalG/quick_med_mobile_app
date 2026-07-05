import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_med/services/auth_repository.dart';
import 'package:quick_med/services/profile_service.dart';
import 'email_auth_state.dart';

class EmailAuthCubit extends Cubit<EmailAuthState> {
  final AuthRepository _authRepository = AuthRepository();
  final ProfileService _profileService = ProfileService();

  EmailAuthCubit() : super(EmailAuthInitial());

  Future<void> signIn(String email, String password) async {
    emit(EmailAuthLoading());
    try {
      final response = await _authRepository.signInWithEmail(email, password);
      if (response.user != null) {
        final hasProfile = await _checkHasProfile(response.user!.id);
        emit(EmailAuthSuccess(hasProfile: hasProfile));
      } else {
        emit(const EmailAuthFailure(error: 'Failed to sign in. User not found.'));
      }
    } on CustomAuthException catch (e) {
      emit(EmailAuthFailure(error: e.message));
    } catch (e) {
      emit(EmailAuthFailure(error: e.toString()));
    }
  }

  Future<void> signUp(String email, String password) async {
    emit(EmailAuthLoading());
    try {
      final response = await _authRepository.signUpWithEmail(email, password);
      if (response.user != null) {
        // Newly registered users won't have a profile yet
        emit(const EmailAuthSuccess(hasProfile: false));
      } else {
        emit(const EmailAuthFailure(error: 'Failed to sign up. User not created.'));
      }
    } on CustomAuthException catch (e) {
      emit(EmailAuthFailure(error: e.message));
    } catch (e) {
      emit(EmailAuthFailure(error: e.toString()));
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
}
