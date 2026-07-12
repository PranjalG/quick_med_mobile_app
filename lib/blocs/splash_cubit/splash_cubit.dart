import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_med/services/auth_service.dart';
import 'package:quick_med/services/profile_service.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final ProfileService _profileService = ProfileService();

  SplashCubit() : super(SplashInitial()) {
    checkAuthStatus();
  }

  void checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    final userId = AuthService.currentUserId;
    if (userId != null) {
      try {
        final profile = await _profileService.fetchProfile(userId);
        if (profile != null && profile.name.isNotEmpty) {
          emit(SplashNavigateToHome());
        } else {
          emit(SplashNavigateToProfileSetup());
        }
      } catch (e) {
        emit(SplashNavigateToProfileSetup());
      }
    } else {
      emit(SplashNavigateToOnboarding());
    }
  }
}
