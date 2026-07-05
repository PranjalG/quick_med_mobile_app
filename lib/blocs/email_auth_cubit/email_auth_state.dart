import 'package:equatable/equatable.dart';

abstract class EmailAuthState extends Equatable {
  const EmailAuthState();

  @override
  List<Object?> get props => [];
}

class EmailAuthInitial extends EmailAuthState {}

class EmailAuthLoading extends EmailAuthState {}

class EmailAuthSuccess extends EmailAuthState {
  final bool hasProfile;

  const EmailAuthSuccess({required this.hasProfile});

  @override
  List<Object?> get props => [hasProfile];
}

class EmailAuthFailure extends EmailAuthState {
  final String error;

  const EmailAuthFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
