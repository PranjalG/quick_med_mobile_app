import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'phone_login_state.dart';

class PhoneLoginCubit extends Cubit<PhoneLoginState> {
  PhoneLoginCubit() : super(PhoneLoginInitial());

  Future<void> sendOtp(String phoneNumber) async {
    emit(PhoneLoginLoading());
    try {
      // Rule 3: Every Supabase query must include error handling (try/catch)
      // Standardize Indian phone number format if needed (e.g. +91)
      final formattedPhone = phoneNumber.startsWith('+') ? phoneNumber : '+91$phoneNumber';
      
      await Supabase.instance.client.auth.signInWithOtp(
        phone: formattedPhone,
      );
      emit(PhoneLoginSuccess());
    } on AuthException catch (e) {
      emit(PhoneLoginFailure(error: e.message));
    } catch (e) {
      emit(PhoneLoginFailure(error: e.toString()));
    }
  }
}
