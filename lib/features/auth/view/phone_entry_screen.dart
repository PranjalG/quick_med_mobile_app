import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../custom_components/bordered_textfield.dart';
import '../../../custom_components/gradient_button.dart';
import '../../../screens/login/logo_widget.dart';
import '../../../services/app_colors.dart';
import '../../../services/theme_colours.dart';
import '../../../utils/screen_size.dart';
import '../bloc/phone_auth_cubit.dart';
import '../bloc/phone_auth_state.dart';
import '../repository/auth_exceptions.dart';

class PhoneEntryScreen extends StatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  State<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String? _inlineError;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String? _validateIndianPhone(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return 'Please enter your mobile number';
    }

    try {
      AuthRepositoryValidation.validate(trimmed);
      return null;
    } on InvalidPhoneNumberException catch (error) {
      return error.message;
    }
  }

  void _onSendOtp() {
    final error = _validateIndianPhone(_phoneController.text);
    setState(() => _inlineError = error);
    if (error != null) return;

    context.read<PhoneAuthCubit>().sendOtp(_phoneController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PhoneAuthCubit>().state;
    final isSending = state is PhoneAuthCodeSending && !context.read<PhoneAuthCubit>().hasActiveVerification;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Column(
            children: [
              const LogoWidget(),
              Center(
                child: Text(
                  'Login with Phone',
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              SizedBox(height: context.sh * 0.02),
              Center(
                child: Text(
                  'Enter your mobile number.\nWe\'ll send a 6-digit OTP.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
              SizedBox(height: context.sh * 0.04),
              Center(
                child: BorderedTextField(
                  controller: _phoneController,
                  label: 'Mobile Number',
                  hintText: '10-digit number',
                  keyboardType: TextInputType.phone,
                  inputFormatter: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  errorText: _inlineError,
                  textInputAction: TextInputAction.done,
                  onSubmit: _onSendOtp,
                  onChange: (_) {
                    if (_inlineError != null) {
                      setState(() => _inlineError = null);
                    }
                  },
                  textDecoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: context.sh * 0.01),
                    hintText: '10-digit number',
                    hintStyle: GoogleFonts.montserrat(
                      color: ThemeColours.darkGreen,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    prefixText: '+91 ',
                    prefixStyle: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ThemeColours.darkGreen,
                    ),
                  ),
                ),
              ),
              SizedBox(height: context.sh * 0.02),
              Center(
                child: GradientButton(
                  buttonText: isSending ? 'Sending OTP...' : 'Send OTP',
                  enabled: !isSending,
                  onTap: isSending ? null : _onSendOtp,
                ),
              ),
              SizedBox(height: context.sh * 0.03),
            ],
          ),
        );
      },
    );
  }
}

/// Lightweight validation helper so the view can show inline errors
/// without constructing a full [AuthRepository].
class AuthRepositoryValidation {
  static final RegExp _indianMobilePattern = RegExp(r'^\+91[6-9]\d{9}$');

  static void validate(String input) {
    final cleaned = input.trim().replaceAll(RegExp(r'[\s\-()]'), '');

    String e164;
    if (cleaned.startsWith('+91')) {
      e164 = cleaned;
    } else if (cleaned.startsWith('91') && cleaned.length == 12) {
      e164 = '+$cleaned';
    } else if (RegExp(r'^\d{10}$').hasMatch(cleaned)) {
      e164 = '+91$cleaned';
    } else if (cleaned.startsWith('+') && !cleaned.startsWith('+91')) {
      throw const InvalidPhoneNumberException(
        'Only Indian mobile numbers (+91) are supported at launch.',
      );
    } else {
      throw const InvalidPhoneNumberException();
    }

    if (!_indianMobilePattern.hasMatch(e164)) {
      throw const InvalidPhoneNumberException();
    }
  }
}
