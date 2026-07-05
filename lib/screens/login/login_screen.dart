import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quick_med/blocs/email_auth_cubit/email_auth_cubit.dart';
import 'package:quick_med/blocs/email_auth_cubit/email_auth_state.dart';
import 'package:quick_med/screens/login/logo_widget.dart';
import 'package:quick_med/services/app_colors.dart';
import 'package:quick_med/services/app_text_styles.dart';
import 'package:quick_med/utils/screen_size.dart';
import 'package:quick_med/custom_components/custom_shimmer.dart';
import 'package:quick_med/custom_components/custom_text_field.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EmailAuthCubit(),
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  bool _isLoginMode = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _formKey.currentState?.reset();
      _emailController.clear();
      _passwordController.clear();
    });
  }

  void _onSubmit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      
      if (_isLoginMode) {
        context.read<EmailAuthCubit>().signIn(email, password);
      } else {
        context.read<EmailAuthCubit>().signUp(email, password);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EmailAuthCubit, EmailAuthState>(
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
      builder: (context, state) {
        final isLoading = state is EmailAuthLoading;

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
                  key: _formKey,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: SizedBox(
                      height: context.sh - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const LogoWidget(),
                          
                          // Title (Login / Sign Up)
                          Center(
                            child: Text(
                              _isLoginMode ? 'Login' : 'Sign Up',
                              style: AppTextStyles.onboardingTitle(context),
                            ),
                          ),
                          SizedBox(height: context.sh * 0.04),

                          if (isLoading) ...[
                            // Green shimmer skeleton for form fields
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
                            SizedBox(height: context.sh * 0.03),

                            // Shimmer for Divider line
                            Row(
                              children: [
                                const Expanded(child: Divider(color: Color(0xFFE5E7EB), thickness: 1.5)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                  child: Text('Or Continue With', style: AppTextStyles.skipText(context)),
                                ),
                                const Expanded(child: Divider(color: Color(0xFFE5E7EB), thickness: 1.5)),
                              ],
                            ),
                            SizedBox(height: context.sh * 0.03),

                            // Shimmer for Social Buttons
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
                          ] else ...[
                            // Reusable Custom Email Field
                            CustomTextField(
                              controller: _emailController,
                              labelText: 'Email Address',
                              hintText: 'Enter your email',
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: const Icon(Icons.mail_outline, color: Color(0xFF6B7280)),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your email';
                                }
                                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
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
                              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6B7280)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: const Color(0xFF6B7280),
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
                            SizedBox(height: context.sh * 0.03),

                            // Divider Line
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

                            // Social Buttons
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
                          ],

                          const Spacer(),

                          // Mode Switcher (Login <-> Sign Up Link)
                          if (!isLoading)
                            GestureDetector(
                              onTap: _toggleMode,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                child: Text(
                                  _isLoginMode
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

                          // Primary Action Button (Login / Sign Up)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: GestureDetector(
                              onTap: isLoading ? null : () => _onSubmit(context),
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
                                        _isLoginMode ? 'Login' : 'Sign Up',
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