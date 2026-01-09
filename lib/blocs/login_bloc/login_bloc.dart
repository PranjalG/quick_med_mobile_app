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
    on<EmailChangeEvent>(_onEmailChangeEvent);
    on<PasswordChangeEvent>(_onPasswordChangeEvent);
  }

  void _onSignUpClickEvent(SignUpClickEvent event, Emitter<LoginState> emit) {
    emit(state.copyWith(signUp: !state.signUp));
  }

  void _onEmailChangeEvent(EmailChangeEvent event, Emitter<LoginState> emit) {
    emit(state.copyWith(email: event.emailText));
  }

  void _onPasswordChangeEvent(
      PasswordChangeEvent event, Emitter<LoginState> emit) {
    emit(state.copyWith(pswd: event.pswdText));
  }

  void _onSignUpEvent(SignUpEvent event, Emitter<LoginState> emit) async {
    emit(state.copyWith(apiStatus: Status.loading));
    final Auth auth = Auth();

    try {
      final UserCredential response = await auth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.pswd,
      );

      if (response.additionalUserInfo?.isNewUser == true) {
        emit(
          state.copyWith(
            apiStatus: Status.success,
            loginSuccess: true,
          ),
        );
      } else {}
    } catch (err) {
      emit(
        state.copyWith(
          apiStatus: Status.failure,
          errorMsg: err.toString(),
        ),
      );
    }
  }
}
