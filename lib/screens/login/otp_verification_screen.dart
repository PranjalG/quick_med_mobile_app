import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quick_med/blocs/phone_login_cubit/phone_login_cubit.dart';
import 'package:quick_med/blocs/phone_login_cubit/phone_login_state.dart';
import 'package:quick_med/screens/login/logo_widget.dart';
import 'package:quick_med/services/theme_colours.dart';
import 'package:quick_med/services/app_colors.dart';
import 'package:quick_med/utils/screen_size.dart';

class OtpVerificationScreen extends StatelessWidget {
  final String phoneNumber;
  const OtpVerificationScreen({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PhoneLoginCubit(),
      child: OtpVerificationView(phoneNumber: phoneNumber),
    );
  }
}

class OtpVerificationView extends StatefulWidget {
  final String phoneNumber;
  const OtpVerificationView({super.key, required this.phoneNumber});

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  
  Timer? _timer;
  int _secondsRemaining = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 30;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _canResend = true;
          _timer?.cancel();
        }
      });
    });
  }

  void _resendOtp(BuildContext context) {
    if (_canResend) {
      _startTimer();
      context.read<PhoneLoginCubit>().sendOtp(widget.phoneNumber);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP has been resent to ${widget.phoneNumber} successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _onVerify(BuildContext context) {
    String otp = _controllers.map((c) => c.text).join();
    if (otp.length == 6) {
      context.read<PhoneLoginCubit>().verifyOtp(widget.phoneNumber, otp);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the full 6-digit verification code.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PhoneLoginCubit, PhoneLoginState>(
      listener: (context, state) {
        if (state is PhoneOtpVerifySuccess) {
          if (state.hasProfile) {
            context.go('/home_screen');
          } else {
            context.go('/profile_setup');
          }
        } else if (state is PhoneOtpVerifyFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (state is PhoneLoginFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is PhoneOtpVerifying || state is PhoneLoginLoading;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
              onPressed: isLoading ? null : () => context.go('/login'),
            ),
          ),
          extendBodyBehindAppBar: true,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                height: context.sh - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom - 56,
                child: Stack(
                  children: [
                    // Background pattern gradient
                    Opacity(
                      opacity: 0.8,
                      child: Image.asset(
                        'assets/images/Gradient.png',
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header Logo Widget
                          const LogoWidget(),

                          // Verification Shield graphic
                          Center(
                            child: Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                color: ThemeColours.darkGreen.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.shield_outlined,
                                size: 40,
                                color: ThemeColours.darkGreen,
                              ),
                            ),
                          ),
                          SizedBox(height: context.sh * 0.03),

                          // Title
                          Text(
                            'OTP Verification',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Subtitle showing passed phone number
                          Text(
                            'Enter the 6-digit code sent to ${widget.phoneNumber}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: const Color(0xFF9CA3AF),
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: isLoading ? null : () => context.go('/login'),
                            child: Text(
                              'Change/Edit Number',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                color: ThemeColours.darkGreen,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          SizedBox(height: context.sh * 0.04),

                          // OTP 6 digit fields
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (index) {
                              return SizedBox(
                                width: context.sw * 0.12,
                                height: 56,
                                child: TextFormField(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  enabled: !isLoading,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF111827),
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(1),
                                  ],
                                  onChanged: (value) {
                                    if (value.isNotEmpty) {
                                      if (index < 5) {
                                        _focusNodes[index + 1].requestFocus();
                                      } else {
                                        _focusNodes[index].unfocus();
                                        // Auto-submit OTP once 6th digit is entered
                                        _onVerify(context);
                                      }
                                    } else {
                                      if (index > 0) {
                                        _focusNodes[index - 1].requestFocus();
                                      }
                                    }
                                  },
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    filled: true,
                                    fillColor: Colors.white,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFE5E7EB),
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: ThemeColours.darkGreen,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          SizedBox(height: context.sh * 0.04),

                          // Countdown or resend button
                          Center(
                            child: _canResend
                                ? TextButton(
                                    onPressed: isLoading ? null : () => _resendOtp(context),
                                    style: TextButton.styleFrom(
                                      foregroundColor: ThemeColours.darkGreen,
                                    ),
                                    child: Text(
                                      'Resend OTP',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Resend OTP in 00:${_secondsRemaining.toString().padLeft(2, '0')}',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      color: const Color(0xFF9CA3AF),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                          const Spacer(),

                          // Verify primary button
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: GestureDetector(
                              onTap: isLoading ? null : () => _onVerify(context),
                              child: Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  color: ThemeColours.darkGreen,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: ThemeColours.darkGreen.withValues(alpha: 0.3),
                                      offset: const Offset(0, 8),
                                      blurRadius: 15,
                                    )
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Text(
                                        'Verify',
                                        style: GoogleFonts.montserrat(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
