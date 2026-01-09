part of 'login_bloc.dart';

class LoginState extends Equatable {
  final String? email;
  final String? pswd;
  final Status apiStatus;
  final String? errorMsg;
  final bool signUp;
  final bool loginSuccess;

  const LoginState({
    this.email,
    this.pswd,
    this.apiStatus = Status.initial,
    this.errorMsg,
    this.signUp = false,
    this.loginSuccess = false,
  });

  LoginState copyWith({
    String? email,
    String? pswd,
    Status? apiStatus,
    String? errorMsg,
    bool? signUp,
    bool? loginSuccess,
  }) {
    return LoginState(
      apiStatus: apiStatus ?? this.apiStatus,
      email: email ?? this.email,
      pswd: pswd ?? this.pswd,
      errorMsg: errorMsg ?? this.errorMsg,
      signUp: signUp ?? this.signUp,
      loginSuccess: loginSuccess ?? this.loginSuccess,
    );
  }

  @override
  List<Object?> get props => [
        email,
        pswd,
        apiStatus,
        errorMsg,
        signUp,
        loginSuccess,
      ];
}
