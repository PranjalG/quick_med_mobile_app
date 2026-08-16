import 'package:flutter_bloc/flutter_bloc.dart';
import 'email_auth_state.dart';

class EmailAuthCubit extends Cubit<EmailAuthState> {
  EmailAuthCubit() : super(EmailAuthInitial());

  Future<void> signIn(String email, String password) async {
    emit(const EmailAuthFailure(
      error: 'Email authentication is not available. Use phone authentication.',
    ));
  }

  Future<void> signUp(String email, String password) async {
    emit(const EmailAuthFailure(
      error: 'Email authentication is not available. Use phone authentication.',
    ));
  }
}
