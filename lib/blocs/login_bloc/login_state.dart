part of 'login_bloc.dart';

class LoginState extends Equatable {
  final String? email;
  final String? pswd;
  final Status loginResponseStatus;
  final String? errorMsg;
  final bool userLogin;
  final UserLogin userLoginType;
  final bool loginSuccess;
  final String? emailErrorText;

  const LoginState({
    this.email,
    this.pswd,
    this.loginResponseStatus = Status.initial,
    this.errorMsg,
    this.userLogin = false,
    this.userLoginType = UserLogin.signUp,
    this.loginSuccess = false,
    this.emailErrorText,
  });

  LoginState copyWith({
    String? email,
    String? pswd,
    Status? loginResponseStatus,
    String? errorMsg,
    bool? userLogin,
    UserLogin? userLoginType,
    bool? loginSuccess,
    String? emailErrorText,
  }) {
    return LoginState(
      loginResponseStatus: loginResponseStatus ?? this.loginResponseStatus,
      email: email ?? this.email,
      pswd: pswd ?? this.pswd,
      errorMsg: errorMsg ?? this.errorMsg,
      userLogin: userLogin ?? this.userLogin,
      userLoginType: userLoginType ?? this.userLoginType,
      loginSuccess: loginSuccess ?? this.loginSuccess,
      emailErrorText: emailErrorText ?? this.emailErrorText,
    );
  }

  @override
  List<Object?> get props => [
        email,
        pswd,
        loginResponseStatus,
        errorMsg,
        userLogin,
        userLoginType,
        loginSuccess,
        emailErrorText,
      ];
}
