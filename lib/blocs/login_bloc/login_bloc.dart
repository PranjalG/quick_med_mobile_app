import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quick_med/services/auth.dart';
import 'package:quick_med/services/enum.dart';

part 'login_event.dart';

part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginState()) {
    on<LoginEvent>((event, emit) {});
    on<SignUpEvent>(_onSignUpEvent);

    on<SignUpClickEvent>(_onSignUpClickEvent);
    on<SignInClickEvent>(_onSignInClickEvent);

    on<BackButtonClick>(_onBackButtonClick);

    on<EmailChangeEvent>(_onEmailChangeEvent);
    on<EmailValidateEvent>(_onEmailValidateEvent);
    on<PasswordChangeEvent>(_onPasswordChangeEvent);
  }

  void _onSignUpClickEvent(SignUpClickEvent event, Emitter<LoginState> emit) {
    emit(
      state.copyWith(
        userLogin: !state.userLogin,
        userLoginType: UserLogin.signUp,
      ),
    );
  }

  void _onSignInClickEvent(SignInClickEvent event, Emitter<LoginState> emit) {
    emit(
      state.copyWith(
        userLogin: !state.userLogin,
        userLoginType: UserLogin.signIn,
      ),
    );
  }

  void _onBackButtonClick(BackButtonClick event, Emitter<LoginState> emit) {
    emit(
      state.copyWith(
        userLogin: false,
      ),
    );
  }

  void _onEmailChangeEvent(EmailChangeEvent event, Emitter<LoginState> emit) {
    emit(state.copyWith(email: event.emailText));
  }

  void _onEmailValidateEvent(
      EmailValidateEvent event, Emitter<LoginState> emit) {
    final email = state.email;
    emit(
      state.copyWith(
        emailErrorText: email == null
            ? 'Email is required'
            : !isValidEmail(email)
                ? 'Enter a valid email'
                : '',
      ),
    );
  }

  void _onPasswordChangeEvent(
      PasswordChangeEvent event, Emitter<LoginState> emit) {
    emit(state.copyWith(pswd: event.pswdText));
  }

  void _onSignUpEvent(SignUpEvent event, Emitter<LoginState> emit) async {
    emit(state.copyWith(loginResponseStatus: Status.loading));
    final Auth auth = Auth();

    try {
      final UserCredential response = await auth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.pswd,
      );

      if (response.additionalUserInfo?.isNewUser == true) {
        emit(
          state.copyWith(
            loginResponseStatus: Status.success,
            loginSuccess: true,
          ),
        );
      } else {}
    } catch (err) {
      emit(
        state.copyWith(
          loginResponseStatus: Status.failure,
          errorMsg: err.toString(),
        ),
      );
    }
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(email);
  }
}
