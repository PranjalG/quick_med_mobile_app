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
