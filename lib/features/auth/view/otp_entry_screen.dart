import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../custom_components/bordered_textfield.dart';
import '../../../custom_components/gradient_button.dart';
import '../../../services/app_colors.dart';
import '../../../utils/screen_size.dart';
import '../bloc/phone_auth_cubit.dart';
import '../bloc/phone_auth_state.dart';

class OtpEntryScreen extends StatefulWidget {
  final String phoneDisplay;

  const OtpEntryScreen({super.key, required this.phoneDisplay});

  @override
  State<OtpEntryScreen> createState() => _OtpEntryScreenState();
}

class _OtpEntryScreenState extends State<OtpEntryScreen> {
  final TextEditingController _otpController = TextEditingController();
  Timer? _resendTimer;
  int _resendSeconds = 30;
  bool _canResend = false;
  String? _inlineError;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendSeconds = 30;
      _canResend = false;
    });
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds == 0) {
        timer.cancel();
        if (mounted) setState(() => _canResend = true);
      } else if (mounted) {
        setState(() => _resendSeconds--);
      }
    });
  }

  void _onVerify() {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      setState(() => _inlineError = 'Enter the 6-digit OTP');
      return;
    }
    setState(() => _inlineError = null);
    context.read<PhoneAuthCubit>().verifyOtp(code);
  }

  void _onOtpChanged(String? value) {
    if (_inlineError != null) {
      setState(() => _inlineError = null);
    }
    final digits = value != null ? value.replaceAll(RegExp(r'\D'), '') : '';
    if (digits.length == 6 && digits != _otpController.text) {
      _otpController.text = digits;
      _otpController.selection = TextSelection.collapsed(offset: digits.length);
    }
    if (digits.length == 6) {
      _onVerify();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PhoneAuthCubit>().state;
    final isBusy = state is PhoneAuthVerifying ||
        (state is PhoneAuthCodeSending &&
            context.read<PhoneAuthCubit>().hasActiveVerification);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: context.sh * 0.08),
        Center(
          child: Text(
            'OTP Verification',
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
            'Enter the 6-digit code sent to\n${widget.phoneDisplay}',
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
            controller: _otpController,
            label: 'Verification Code',
            hintText: '6-digit OTP',
            keyboardType: TextInputType.number,
            inputFormatter: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            errorText: _inlineError,
            textInputAction: TextInputAction.done,
            onSubmit: _onVerify,
            onChange: _onOtpChanged,
          ),
        ),
        SizedBox(height: context.sh * 0.02),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _canResend
                  ? "Didn't receive the code? "
                  : 'Resend OTP in 00:${_resendSeconds.toString().padLeft(2, '0')}',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            if (_canResend)
              GestureDetector(
                onTap: isBusy
                    ? null
                    : () {
                        context.read<PhoneAuthCubit>().resendOtp();
                        _startResendTimer();
                      },
                child: Text(
                  'Resend',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryBlue,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: context.sh * 0.02),
        Center(
          child: GestureDetector(
            onTap: () => context.read<PhoneAuthCubit>().resetToPhoneEntry(),
            child: Text(
              'Change phone number',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const Spacer(),
        Center(
          child: GradientButton(
            buttonText: isBusy ? 'Verifying...' : 'Verify OTP',
            enabled: !isBusy,
            onTap: isBusy ? null : _onVerify,
          ),
        ),
        SizedBox(height: context.sh * 0.03),
      ],
    );
  }
}
