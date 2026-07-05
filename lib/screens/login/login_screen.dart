import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_med/blocs/phone_login_cubit/phone_login_cubit.dart';
import 'package:quick_med/blocs/phone_login_cubit/phone_login_state.dart';
import 'package:quick_med/screens/login/logo_widget.dart';
import 'package:quick_med/services/app_colors.dart';
import 'package:quick_med/services/app_text_styles.dart';
import 'package:quick_med/utils/screen_size.dart';
import 'package:quick_med/custom_components/custom_shimmer.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PhoneLoginCubit(),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController phoneController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return BlocConsumer<PhoneLoginCubit, PhoneLoginState>(
      listener: (context, state) {
        if (state is PhoneLoginSuccess) {
          final phone = phoneController.text.trim();
          context.go('/otp_verification?phone=$phone');
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
        final isLoading = state is PhoneLoginLoading;

        return Scaffold(
          backgroundColor: AppColors.white,
          body: Stack(
            children: [
              // 1. Watermark Background Image
              Positioned.fill(
                child: Opacity(
                  opacity: 0.08,
                  child: Image.asset(
                    'assets/images/watermark-pattern.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // 2. Main Scroll Content
              SafeArea(
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: SizedBox(
                      height: context.sh - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const LogoWidget(),
                          
                          // Title: Login
                          Center(
                            child: Text(
                              'Login',
                              style: AppTextStyles.onboardingTitle(context),
                            ),
                          ),
                          SizedBox(height: context.sh * 0.04),

                          if (isLoading) ...[
                            // Green shimmer skeleton for the phone number input box
                            CustomShimmer(
                              width: double.infinity,
                              height: 60,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            SizedBox(height: context.sh * 0.03),

                            // Shimmer for Divider line
                            Row(
                              children: [
                                const Expanded(
                                  child: Divider(
                                    color: Color(0xFFE5E7EB),
                                    thickness: 1.5,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                  child: Text(
                                    'Or Continue With',
                                    style: AppTextStyles.skipText(context),
                                  ),
                                ),
                                const Expanded(
                                  child: Divider(
                                    color: Color(0xFFE5E7EB),
                                    thickness: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: context.sh * 0.03),

                            // Shimmer for Social Buttons Row
                            Row(
                              children: [
                                Expanded(
                                  child: CustomShimmer(
                                    width: double.infinity,
                                    height: 56,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: CustomShimmer(
                                    width: double.infinity,
                                    height: 56,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: context.sh * 0.04),

                            // Shimmer for Reset Password link
                            Center(
                              child: CustomShimmer(
                                width: 180,
                                height: 18,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ] else ...[
                            // Mobile Number Input Box
                            TextFormField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              style: AppTextStyles.inputText(context),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter mobile number';
                                }
                                if (value.length < 10) {
                                  return 'Enter a valid 10-digit mobile number';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: 'Mobile Number',
                                hintStyle: AppTextStyles.hintText(context),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 20,
                                ),
                                filled: true,
                                fillColor: AppColors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE5E7EB),
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                    width: 1.5,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                    color: AppColors.error,
                                    width: 1.5,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                    color: AppColors.error,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: context.sh * 0.03),

                            // Divider Line: "Or Continue With"
                            Row(
                              children: [
                                const Expanded(
                                  child: Divider(
                                    color: Color(0xFFE5E7EB),
                                    thickness: 1.5,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                  child: Text(
                                    'Or Continue With',
                                    style: AppTextStyles.skipText(context),
                                  ),
                                ),
                                const Expanded(
                                  child: Divider(
                                    color: Color(0xFFE5E7EB),
                                    thickness: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: context.sh * 0.03),

                            // Social Buttons Row
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSocialButton(
                                    context: context,
                                    icon: FontAwesomeIcons.facebookF,
                                    label: 'Facebook',
                                    iconColor: const Color(0xFF1877F2),
                                    onTap: () {
                                      context.go('/home_screen');
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildSocialButton(
                                    context: context,
                                    icon: FontAwesomeIcons.google,
                                    label: 'Google',
                                    iconColor: const Color(0xFFEA4335),
                                    onTap: () {
                                      context.go('/home_screen');
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: context.sh * 0.04),

                            // Forgot password link
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Reset password functionality (Mock)'),
                                  ),
                                );
                              },
                              child: Text(
                                'Forgot Your Password?',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.forgotPasswordText(context),
                              ),
                            ),
                          ],

                          const Spacer(),

                          // Primary Action Button (Login)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: GestureDetector(
                              onTap: isLoading
                                  ? null
                                  : () {
                                      if (formKey.currentState!.validate()) {
                                        context.read<PhoneLoginCubit>().sendOtp(phoneController.text);
                                      }
                                    },
                              child: Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.3),
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
                                        borderRadius: BorderRadius.all(Radius.circular(4)),
                                      )
                                    : Text(
                                        'Login',
                                        style: AppTextStyles.buttonText(context),
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
            ],
          ),
        );
      },
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
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
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
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}