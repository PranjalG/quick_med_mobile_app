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

  Future<void> saveProfile(UserProfile profile) async {
    emit(ProfileUpdating());
    try {
      await _profileService.saveProfile(profile);
      emit(ProfileUpdateSuccess(profile: profile));
      emit(ProfileLoaded(profile: profile));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  void clearProfile() {
    emit(ProfileInitial());
  }
}
