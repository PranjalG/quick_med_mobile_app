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
    final isSending = state is PhoneAuthCodeSending &&
        !context.read<PhoneAuthCubit>().hasActiveVerification;

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
                  SizedBox(height: context.sh * 0.05),
                  _buildCard(context, isSending),
                  SizedBox(height: context.fs(20)),
                  _buildFooter(context),
                  SizedBox(height: context.fs(16)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, bool isSending) {
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
          Text('Login with phone', style: AppTextStyles.title(context)),
          SizedBox(height: context.fs(8)),
          Text(
            "Enter your mobile number.\nWe'll send a 6-digit OTP.",
            style: AppTextStyles.body(context).copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: context.fs(24)),
          Text(
            'MOBILE NUMBER',
            style: AppTextStyles.categoryLabel(context).copyWith(
              color: AppColors.brandGreenDeep,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: context.fs(8)),
          _buildPhoneField(context),
          SizedBox(height: context.fs(24)),
          PrimaryButton(
            label: isSending ? 'Sending OTP...' : 'Send OTP',
            enabled: !isSending,
            onTap: isSending ? null : _onSendOtp,
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneField(BuildContext context) {
    final bool hasError = _inlineError != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(context.fs(14)),
            border: Border.all(
              color: hasError ? AppColors.error : AppColors.inputBorder,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.fs(16)),
                child: Text(
                  '+91',
                  style: AppTextStyles.inputText(context).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                width: 1.5,
                height: context.fs(28),
                color: AppColors.inputBorder,
              ),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  style: AppTextStyles.inputText(context),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: InputDecoration(
                    hintText: '10-digit number',
                    hintStyle: AppTextStyles.hintText(context).copyWith(
                      color: AppColors.neutralLight,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: context.fs(16),
                      vertical: context.fs(17),
                    ),
                  ),
                  onChanged: (_) {
                    if (_inlineError != null) {
                      setState(() => _inlineError = null);
                    }
                  },
                  onSubmitted: (_) => _onSendOtp(),
                ),
              ),
            ],
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
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: context.fs(14),
              color: AppColors.textSecondary,
            ),
            SizedBox(width: context.fs(6)),
            Text(
              'Your number is safe with us',
              style: AppTextStyles.body(context).copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: context.fs(12),
              ),
            ),
          ],
        ),
        SizedBox(height: context.fs(14)),
        Text(
          'By continuing you agree to our Terms & Privacy Policy',
          textAlign: TextAlign.center,
          style: AppTextStyles.body(context).copyWith(
            color: AppColors.neutralLight,
            fontSize: context.fs(11),
          ),
        ),
      ],
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
