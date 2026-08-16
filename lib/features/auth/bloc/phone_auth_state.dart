import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class PhoneAuthState extends Equatable {
  const PhoneAuthState();

  @override
  List<Object?> get props => [];
}

class PhoneAuthInitial extends PhoneAuthState {
  const PhoneAuthInitial();
}

class PhoneAuthCodeSending extends PhoneAuthState {
  const PhoneAuthCodeSending();
}

class PhoneAuthCodeSent extends PhoneAuthState {
  final String verificationId;
  final String phoneDisplay;

  const PhoneAuthCodeSent({
    required this.verificationId,
    required this.phoneDisplay,
  });

  @override
  List<Object?> get props => [verificationId, phoneDisplay];
}

class PhoneAuthVerifying extends PhoneAuthState {
  final String phoneDisplay;

  const PhoneAuthVerifying({required this.phoneDisplay});

  @override
  List<Object?> get props => [phoneDisplay];
}

class PhoneAuthSuccess extends PhoneAuthState {
  final User user;

  const PhoneAuthSuccess({required this.user});

  @override
  List<Object?> get props => [user.uid];
}

class PhoneAuthFailure extends PhoneAuthState {
  final String message;

  const PhoneAuthFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
