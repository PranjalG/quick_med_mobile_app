import 'package:equatable/equatable.dart';

abstract class PhoneLoginState extends Equatable {
  const PhoneLoginState();

  @override
  List<Object?> get props => [];
}

class PhoneLoginInitial extends PhoneLoginState {}

class PhoneLoginLoading extends PhoneLoginState {}

class PhoneLoginSuccess extends PhoneLoginState {}

class PhoneLoginFailure extends PhoneLoginState {
  final String error;

  const PhoneLoginFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

class PhoneOtpVerifying extends PhoneLoginState {}

class PhoneOtpVerifySuccess extends PhoneLoginState {
  final bool hasProfile;

  const PhoneOtpVerifySuccess({required this.hasProfile});

  @override
  List<Object?> get props => [hasProfile];
}

class PhoneOtpVerifyFailure extends PhoneLoginState {
  final String error;

  const PhoneOtpVerifyFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
