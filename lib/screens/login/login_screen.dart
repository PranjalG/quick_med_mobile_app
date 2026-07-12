import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quick_med/blocs/email_auth_cubit/email_auth_cubit.dart';
import 'package:quick_med/blocs/email_auth_cubit/email_auth_state.dart';
import 'package:quick_med/blocs/phone_auth_cubit/phone_auth_cubit.dart';
import 'package:quick_med/blocs/phone_auth_cubit/phone_auth_state.dart';
import 'package:quick_med/screens/login/logo_widget.dart';
import 'package:quick_med/services/app_colors.dart';
import 'package:quick_med/services/app_text_styles.dart';
import 'package:quick_med/utils/screen_size.dart';
import 'package:quick_med/custom_components/custom_shimmer.dart';
import 'package:quick_med/custom_components/custom_text_field.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => EmailAuthCubit()),
        BlocProvider(create: (context) => PhoneAuthCubit()),
      ],
      child: const LoginView(),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoginMode = true;
  bool _obscurePassword = true;
  bool _usePhoneAuth = false;
  String? _verificationId;

  // OTP Resend Timer
  Timer? _resendTimer;
  int _resendTimerSeconds = 30;
  bool _canResendOtp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendTimerSeconds = 30;
      _canResendOtp = false;
    });
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimerSeconds == 0) {
        setState(() {
          _canResendOtp = true;
          _resendTimer?.cancel();
        });
      } else {
        setState(() {
          _resendTimerSeconds--;
        });
      }
    });
  }

  Future<void> _launchWhatsApp() async {
    final whatsappAppUrl = Uri.parse(
        'whatsapp://send?phone=917297815848&text=Hello%20QuickMed,%20I%20would%20like%20to%20order%20medicines.');
    final whatsappWebUrl = Uri.parse(
        'https://wa.me/917297815848?text=Hello%20QuickMed,%20I%20would%20like%20to%20order%20medicines.');
    try {
      bool launched = await launchUrl(whatsappAppUrl,
          mode: LaunchMode.externalNonBrowserApplication);
      if (!launched) {
        launched = await launchUrl(whatsappWebUrl,
            mode: LaunchMode.externalApplication);
      }
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch WhatsApp.')),
        );
      }
    } catch (e) {
      try {
        await launchUrl(whatsappWebUrl, mode: LaunchMode.externalApplication);
      } catch (innerError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error opening WhatsApp: $innerError')),
          );
        }
      }
    }
  }

  Future<void> _launchCall() async {
    final url = Uri.parse('tel:+917297815848');
    try {
      final launched = await launchUrl(url);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch Phone dialer.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error launching phone dialer: $e')),
        );
      }
    }
  }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _formKey.currentState?.reset();
      _emailController.clear();
      _passwordController.clear();
      _phoneController.clear();
      _otpController.clear();
      _verificationId = null;
      _resendTimer?.cancel();
    });
  }

  void _onSubmit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      if (_verificationId != null) {
        final code = _otpController.text.trim();
        context.read<PhoneAuthCubit>().verifyOtp(_verificationId!, code);
      } else if (_usePhoneAuth) {
        var phone = _phoneController.text.trim();
        if (!phone.startsWith('+')) {
          phone = '+91$phone';
        }
        context.read<PhoneAuthCubit>().sendOtp(phone);
      } else {
        final email = _emailController.text.trim();
        final password = _passwordController.text;

        if (_isLoginMode) {
          context.read<EmailAuthCubit>().signIn(email, password);
        } else {
          context.read<EmailAuthCubit>().signUp(email, password);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final emailState = context.watch<EmailAuthCubit>().state;
    final phoneState = context.watch<PhoneAuthCubit>().state;

    final isEmailLoading = emailState is EmailAuthLoading;
    final isPhoneLoading = phoneState is PhoneAuthLoading;
    final isLoading = isEmailLoading || isPhoneLoading;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: MultiBlocListener(
        listeners: [
          BlocListener<EmailAuthCubit, EmailAuthState>(
            listener: (context, state) {
              if (state is EmailAuthSuccess) {
                if (state.hasProfile) {
                  context.go('/home_screen');
                } else {
                  context.go('/profile_setup');
                }
              } else if (state is EmailAuthFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
          ),
          BlocListener<PhoneAuthCubit, PhoneAuthState>(
            listener: (context, state) {
              if (state is PhoneAuthCodeSent) {
                setState(() {
                  _verificationId = state.verificationId;
                });
                _startResendTimer();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('OTP sent successfully!')),
                );
              } else if (state is PhoneAuthCodeVerified) {
                if (state.hasProfile) {
                  context.go('/home_screen');
                } else {
                  context.go('/profile_setup');
                }
              } else if (state is PhoneAuthFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
          ),
        ],
        child: Stack(
          children: [
            // 1. Watermark Background Image
            Positioned.fill(
              child: Opacity(
                opacity: 0.08,
                child: Image.asset(
                  'assets/images/watermark-pattern.png',
                  fit: BoxFit.cover,
                  color: AppColors.primaryDark,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
            ),

            // 2. Main Scroll Content
            SafeArea(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: context.sh -
                          MediaQuery.of(context).padding.top -
                          MediaQuery.of(context).padding.bottom,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const LogoWidget(),

                          // Title (Login / Sign Up / OTP Verification)
                          Center(
                            child: Text(
                              _verificationId != null
                                  ? 'OTP Verification'
                                  : _usePhoneAuth
                                      ? 'Phone Authentication'
                                      : _isLoginMode
                                          ? 'Login'
                                          : 'Sign Up',
                              style: AppTextStyles.onboardingTitle(context),
                            ),
                          ),
                          SizedBox(height: context.sh * 0.04),

                          if (isLoading) ...[
                            if (_verificationId != null) ...[
                              CustomShimmer(
                                width: double.infinity,
                                height: 60,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              SizedBox(height: context.sh * 0.02),
                              CustomShimmer(
                                width: double.infinity,
                                height: 56,
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ] else if (_usePhoneAuth) ...[
                              CustomShimmer(
                                width: double.infinity,
                                height: 60,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              SizedBox(height: context.sh * 0.02),
                              CustomShimmer(
                                width: double.infinity,
                                height: 56,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              SizedBox(height: context.sh * 0.02),
                              CustomShimmer(
                                width: double.infinity,
                                height: 56,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              SizedBox(height: context.sh * 0.02),
                              CustomShimmer(
                                width: double.infinity,
                                height: 56,
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ] else ...[
                              CustomShimmer(
                                width: double.infinity,
                                height: 60,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              SizedBox(height: context.sh * 0.02),
                              CustomShimmer(
                                width: double.infinity,
                                height: 60,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              SizedBox(height: context.sh * 0.02),
                              CustomShimmer(
                                width: double.infinity,
                                height: 56,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              SizedBox(height: context.sh * 0.02),
                              CustomShimmer(
                                width: double.infinity,
                                height: 56,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              SizedBox(height: context.sh * 0.02),
                              CustomShimmer(
                                width: double.infinity,
                                height: 56,
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ],
                            SizedBox(height: context.sh * 0.03),
                          ] else ...[
                            // Auth Method Tabs (Only show if not verifying OTP)
                            if (_verificationId == null) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _usePhoneAuth = false;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: !_usePhoneAuth
                                                  ? AppColors.secondaryBlue
                                                  : Colors.transparent,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'Email',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.montserrat(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: !_usePhoneAuth
                                                ? AppColors.textPrimary
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _usePhoneAuth = true;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: _usePhoneAuth
                                                  ? AppColors.secondaryBlue
                                                  : Colors.transparent,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'Phone Number',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.montserrat(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: _usePhoneAuth
                                                ? AppColors.textPrimary
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: context.sh * 0.03),
                            ],

                            // Conditional Forms
                            if (_verificationId != null) ...[
                              // OTP Code Form
                              Center(
                                child: Text(
                                  'Enter the 6-digit code sent to ${_phoneController.text}',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              SizedBox(height: context.sh * 0.02),
                              CustomTextField(
                                controller: _otpController,
                                labelText: 'Verification Code',
                                hintText: 'Enter 6-digit OTP',
                                keyboardType: TextInputType.number,
                                prefixIcon: const Icon(Icons.security,
                                    color: AppColors.textSecondary),
                                validator: (value) {
                                  if (value == null || value.trim().length != 6) {
                                    return 'Enter a valid 6-digit OTP';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: context.sh * 0.03),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _canResendOtp
                                        ? "Didn't receive code? "
                                        : "Resend OTP in 00:${_resendTimerSeconds.toString().padLeft(2, '0')}",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  if (_canResendOtp)
                                    GestureDetector(
                                      onTap: () {
                                        context
                                            .read<PhoneAuthCubit>()
                                            .sendOtp(_phoneController.text.trim());
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
                              SizedBox(height: context.sh * 0.03),
                            ] else if (_usePhoneAuth) ...[
                              // Mobile Phone Entry Form
                              CustomTextField(
                                controller: _phoneController,
                                labelText: 'Mobile Number',
                                hintText: 'Enter 10-digit number',
                                keyboardType: TextInputType.phone,
                                prefixIcon: const Icon(Icons.phone_iphone,
                                    color: AppColors.textSecondary),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your mobile number';
                                  }
                                  final cleaned = value.replaceAll(RegExp(r'\D'), '');
                                  if (cleaned.length != 10 && !value.startsWith('+')) {
                                    return 'Enter a valid 10-digit mobile number';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: context.sh * 0.02),

                              // WhatsApp CTA Button
                              GestureDetector(
                                onTap: _launchWhatsApp,
                                child: Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF25D366),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        FontAwesomeIcons.whatsapp,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Order via WhatsApp',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: context.sh * 0.02),

                              // Call CTA Button
                              GestureDetector(
                                onTap: _launchCall,
                                child: Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2588D3),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.phone,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Order via Call',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: context.sh * 0.03),

                              // Active Google Login Button
                              _buildSocialButton(
                                context: context,
                                icon: FontAwesomeIcons.google,
                                label: 'Google',
                                iconColor: const Color(0xFFEA4335),
                                onTap: () {
                                  context.go('/home_screen');
                                },
                              ),
                              SizedBox(height: context.sh * 0.03),
                            ] else ...[
                              // Reusable Custom Email Field
                              CustomTextField(
                                controller: _emailController,
                                labelText: 'Email Address',
                                hintText: 'Enter your email',
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: const Icon(Icons.mail_outline,
                                    color: AppColors.textSecondary),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  final emailRegex = RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                  if (!emailRegex.hasMatch(value)) {
                                    return 'Enter a valid email address';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: context.sh * 0.02),

                              // Reusable Custom Password Field
                              CustomTextField(
                                controller: _passwordController,
                                labelText: 'Password',
                                hintText: 'Enter your password',
                                obscureText: _obscurePassword,
                                prefixIcon: const Icon(Icons.lock_outline,
                                    color: AppColors.textSecondary),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.textSecondary,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: context.sh * 0.02),

                              // WhatsApp CTA Button
                              GestureDetector(
                                onTap: _launchWhatsApp,
                                child: Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF25D366),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        FontAwesomeIcons.whatsapp,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Order via WhatsApp',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: context.sh * 0.02),

                              // Call CTA Button
                              GestureDetector(
                                onTap: _launchCall,
                                child: Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2588D3),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.phone,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Order via Call',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: context.sh * 0.03),

                              // Active Google Login Button
                              _buildSocialButton(
                                context: context,
                                icon: FontAwesomeIcons.google,
                                label: 'Google',
                                iconColor: const Color(0xFFEA4335),
                                onTap: () {
                                  context.go('/home_screen');
                                },
                              ),
                              SizedBox(height: context.sh * 0.03),
                            ],
                          ],

                          const Spacer(),

                          // Mode Switcher / Change Number link
                          if (!isLoading)
                            Center(
                              child: GestureDetector(
                                onTap: _verificationId != null
                                    ? () {
                                        setState(() {
                                          _verificationId = null;
                                          _otpController.clear();
                                        });
                                      }
                                    : _usePhoneAuth
                                        ? null
                                        : _toggleMode,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                  child: Text(
                                    _verificationId != null
                                        ? "Change Phone Number"
                                        : _usePhoneAuth
                                            ? ""
                                            : _isLoginMode
                                                ? "Don't have an account? Sign Up"
                                                : "Already have an account? Log In",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // Primary Action Button (Login / Sign Up / Send OTP / Verify)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: GestureDetector(
                              onTap:
                                  isLoading ? null : () => _onSubmit(context),
                              child: Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryBlue,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.secondaryBlue
                                          .withValues(alpha: 0.3),
                                      offset: const Offset(0, 8),
                                      blurRadius: 15,
                                    )
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: isLoading
                                    ? const CustomShimmer(
                                        width: 80,
                                        height: 20,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4)),
                                      )
                                    : Text(
                                        _verificationId != null
                                            ? 'Verify'
                                            : _usePhoneAuth
                                                ? 'Send OTP'
                                                : _isLoginMode
                                                    ? 'Login'
                                                    : 'Sign Up',
                                        style:
                                            AppTextStyles.buttonText(context),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.inputBorder,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.skipText(context).copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
