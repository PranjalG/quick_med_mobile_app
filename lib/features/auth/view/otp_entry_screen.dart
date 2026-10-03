import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../custom_components/primary_button.dart';
import '../../../screens/login/logo_widget.dart';
import '../../../services/app_colors.dart';
import '../../../services/app_text_styles.dart';
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

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PhoneAuthCubit>().state;
    final isBusy = state is PhoneAuthVerifying ||
        (state is PhoneAuthCodeSending &&
            context.read<PhoneAuthCubit>().hasActiveVerification);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.fs(20)),
              child: Column(
                children: [
                  SizedBox(height: context.sh * 0.02),
                  const LogoWidget(widthFactor: 0.26),
                  SizedBox(height: context.sh * 0.04),
                  _buildCard(context, isBusy),
                  SizedBox(height: context.fs(16)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, bool isBusy) {
    final bool hasError = _inlineError != null;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.fs(24)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(context.fs(28)),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryNavy.withValues(alpha: 0.10),
            offset: const Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Verify OTP', style: AppTextStyles.title(context)),
          SizedBox(height: context.fs(8)),
          Text(
            'Enter the 6-digit code sent to\n${widget.phoneDisplay}',
            style: AppTextStyles.body(context).copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: context.fs(24)),
          Text(
            'VERIFICATION CODE',
            style: AppTextStyles.categoryLabel(context).copyWith(
              color: AppColors.brandGreenDeep,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: context.fs(8)),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(context.fs(14)),
              border: Border.all(
                color: hasError ? AppColors.error : AppColors.inputBorder,
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              style: AppTextStyles.inputText(context),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: InputDecoration(
                hintText: '6-digit OTP',
                hintStyle: AppTextStyles.hintText(context).copyWith(
                  color: AppColors.neutralLight,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: context.fs(16),
                  vertical: context.fs(17),
                ),
              ),
              onChanged: (value) {
                if (_inlineError != null) {
                  setState(() => _inlineError = null);
                }
                final digits = value.replaceAll(RegExp(r'\D'), '');
                if (digits.length == 6) {
                  _onVerify();
                }
              },
              onSubmitted: (_) => _onVerify(),
            ),
          ),
          if (hasError)
            Padding(
              padding: EdgeInsets.only(top: context.fs(6), left: context.fs(4)),
              child: Text(
                _inlineError!,
                style: AppTextStyles.body(context).copyWith(
                  color: AppColors.error,
                  fontSize: context.fs(12),
                ),
              ),
            ),
          SizedBox(height: context.fs(16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _canResend
                    ? "Didn't receive the code? "
                    : 'Resend OTP in 00:${_resendSeconds.toString().padLeft(2, '0')}',
                style: AppTextStyles.body(context).copyWith(
                  color: AppColors.textSecondary,
                  fontSize: context.fs(13),
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
                    style: AppTextStyles.body(context).copyWith(
                      color: AppColors.brandTeal,
                      fontWeight: FontWeight.bold,
                      fontSize: context.fs(13),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: context.fs(12)),
          Center(
            child: GestureDetector(
              onTap: () => context.read<PhoneAuthCubit>().resetToPhoneEntry(),
              child: Text(
                'Change phone number',
                style: AppTextStyles.body(context).copyWith(
                  color: AppColors.brandGreenDeep,
                  fontWeight: FontWeight.bold,
                  fontSize: context.fs(13),
                ),
              ),
            ),
          ),
          SizedBox(height: context.fs(24)),
          PrimaryButton(
            label: isBusy ? 'Verifying...' : 'Verify OTP',
            enabled: !isBusy,
            onTap: isBusy ? null : _onVerify,
          ),
        ],
      ),
    );
  }
}
