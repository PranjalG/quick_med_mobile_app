import 'package:equatable/equatable.dart';
import 'package:quick_med/services/profile_service.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfile profile;

  const ProfileLoaded({required this.profile});

  @override
  List<Object?> get props => [profile];
}

class ProfileUpdating extends ProfileState {
  /// The profile being saved, so screens can keep showing it while the save
  /// runs instead of falling back to an empty state.
  final UserProfile? profile;

  const ProfileUpdating({this.profile});

  @override
  List<Object?> get props => [profile];
}

class ProfileUpdateSuccess extends ProfileState {
  final UserProfile profile;

  /// `false` when the change was only saved on this phone because Supabase
  /// rejected or could not be reached. Server features (e.g. checkout) do not
  /// see the change until a later sync succeeds.
  final bool savedToServer;

  const ProfileUpdateSuccess({
    required this.profile,
    this.savedToServer = true,
  });

  @override
  List<Object?> get props => [profile, savedToServer];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}
