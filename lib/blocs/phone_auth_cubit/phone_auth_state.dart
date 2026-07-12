import 'package:equatable/equatable.dart';

abstract class PhoneAuthState extends Equatable {
  const PhoneAuthState();

  @override
  List<Object?> get props => [];
}

class PhoneAuthInitial extends PhoneAuthState {}

class PhoneAuthLoading extends PhoneAuthState {}

class PhoneAuthCodeSent extends PhoneAuthState {
  final String verificationId;
  const PhoneAuthCodeSent({required this.verificationId});

  @override
  List<Object?> get props => [verificationId];
}

class PhoneAuthCodeVerified extends PhoneAuthState {
  final bool hasProfile;
  const PhoneAuthCodeVerified({required this.hasProfile});

  @override
  List<Object?> get props => [hasProfile];
}

class PhoneAuthFailure extends PhoneAuthState {
  final String error;
  const PhoneAuthFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
