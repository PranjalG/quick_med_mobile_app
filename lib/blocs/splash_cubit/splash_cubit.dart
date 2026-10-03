import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_med/services/auth_service.dart';
import 'package:quick_med/services/profile_service.dart';
import 'package:quick_med/services/supabase_auth_bridge.dart';
import 'package:quick_med/utils/profile_completeness.dart';
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
        await SupabaseAuthBridge.syncSessionFromFirebase(forceRefresh: true);
        final profile = await _profileService.fetchProfile(userId);
        final profileComplete = isProfileComplete(profile);
        if (profileComplete) {
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
