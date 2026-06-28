import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quick_med/screens/login/logo_widget.dart';
import 'package:quick_med/services/theme_colours.dart';
import 'package:quick_med/utils/screen_size.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      // Navigate to OTP Verification screen
      context.go('/otp_verification');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: context.sh - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
            child: Stack(
              children: [
                // Top curve background
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo and App Name Header
                        const LogoWidget(),
                        
                        // Login Title
                        Center(
                          child: Text(
                            'Login',
                            style: GoogleFonts.montserrat(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF111827),
                            ),
                          ),
                        ),
                        SizedBox(height: context.sh * 0.04),

                        // Mobile Number Input Field
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            color: const Color(0xFF111827),
                            fontWeight: FontWeight.w500,
                          ),
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
                            hintStyle: GoogleFonts.montserrat(
                              color: const Color(0xFF9CA3AF),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 20,
                            ),
                            filled: true,
                            fillColor: Colors.white,
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
                                color: ThemeColours.darkGreen,
                                width: 1.5,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: ThemeColours.errorRed,
                                width: 1.5,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: ThemeColours.errorRed,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: context.sh * 0.03),

                        // Divider text: "Or Continue With"
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
                                style: GoogleFonts.montserrat(
                                  color: const Color(0xFF9CA3AF),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
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
                                icon: FontAwesomeIcons.facebookF,
                                label: 'Facebook',
                                iconColor: const Color(0xFF1877F2),
                                onTap: () {
                                  // Mock login
                                  context.go('/home_screen');
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildSocialButton(
                                icon: FontAwesomeIcons.google,
                                label: 'Google',
                                iconColor: const Color(0xFFEA4335),
                                onTap: () {
                                  // Mock login
                                  context.go('/home_screen');
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.sh * 0.04),

                        // Forgot password green link
                        GestureDetector(
                          onTap: () {
                            // Mock placeholder action
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Reset password link sent (Mock)'),
                              ),
                            );
                          },
                          child: Text(
                            'Forgot Your Password?',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              color: ThemeColours.darkGreen,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),

                        // Primary Login Button
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: GestureDetector(
                            onTap: _onLogin,
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
                              child: Text(
                                'Login',
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
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
          color: Colors.white,
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
              style: GoogleFonts.montserrat(
                color: const Color(0xFF111827),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}