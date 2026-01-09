part of 'login_bloc.dart';

class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class SignUpClickEvent extends LoginEvent {}

class SignInClickEvent extends LoginEvent {}

class BackButtonClick extends LoginEvent {}

class EmailChangeEvent extends LoginEvent {
  final String emailText;

  const EmailChangeEvent({required this.emailText});
}

class EmailValidateEvent extends LoginEvent {}

class PasswordChangeEvent extends LoginEvent {
  final String pswdText;

  const PasswordChangeEvent({required this.pswdText});
}

class SignUpEvent extends LoginEvent {
  final String email;
  final String pswd;

  const SignUpEvent({
    required this.email,
    required this.pswd,
  });
}

class SignInWithEmailEvent extends LoginEvent {}

class SignInWithGoogleEvent extends LoginEvent {}
