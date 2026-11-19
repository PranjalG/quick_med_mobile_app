import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_med/services/profile_service.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileService _profileService = ProfileService();

  ProfileCubit() : super(ProfileInitial());

  Future<void> loadProfile(String userId) async {
    emit(ProfileLoading());
    try {
      final profile = await _profileService.fetchProfile(userId);
      if (profile != null) {
        emit(ProfileLoaded(profile: profile));
      } else {
        emit(ProfileInitial());
      }
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  /// Re-fetches the profile without emitting [ProfileLoading], so the home
  /// greeting does not flash "Guest" during pull-to-refresh. On failure the
  /// current state is kept.
  Future<void> refreshProfile(String userId) async {
    try {
      final profile = await _profileService.fetchProfile(userId);
      if (profile != null) emit(ProfileLoaded(profile: profile));
    } catch (_) {
      // Keep whatever is already on screen.
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    emit(ProfileUpdating(profile: profile));
    try {
      final savedToServer = await _profileService.saveProfile(profile);
      emit(
        ProfileUpdateSuccess(profile: profile, savedToServer: savedToServer),
      );
      emit(ProfileLoaded(profile: profile));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  void clearProfile() {
    emit(ProfileInitial());
  }
}
