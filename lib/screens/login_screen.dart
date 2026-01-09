import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_med/custom_components/bordered_button.dart';
import 'package:quick_med/custom_components/bordered_icon_button.dart';
import 'package:quick_med/custom_components/bordered_textfield.dart';
import 'package:quick_med/custom_components/floating_text_box.dart';
import 'package:quick_med/custom_components/gradient_button.dart';
import 'package:quick_med/services/auth.dart';

import '../blocs/login_bloc/login_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late LoginBloc _loginBloc;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pswdController = TextEditingController();

  @override
  void initState() {
    _loginBloc = LoginBloc();
    super.initState();
  }

  Future<void> signOut() async {
    await Auth().signOut();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocProvider(
      create: (_) => _loginBloc,
      child: Scaffold(
        body: SafeArea(
          child: BlocConsumer<LoginBloc, LoginState>(
            listener: (context, state) {
              if (state.loginSuccess) {
                context.go('/home_screen');
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                child: Stack(
                  children: [
                    Opacity(
                      opacity: 0.5,
                      child: Image.asset(
                        'assets/images/Gradient.png',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          SizedBox(height: screenHeight * 0.15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 16),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30)),
                                ),
                                padding: const EdgeInsets.all(24),
                                child: Image.asset(
                                  'assets/images/Logo.png',
                                  height: 80,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.1),
                          state.signUp
                              ? Column(
                                  children: [
                                    SizedBox(height: screenHeight * 0.08),
                                    BorderedTextField(
                                      label: 'Enter your email',
                                      hintText: 'email',
                                      enabled: true,
                                      allowPasting: true,
                                      controller: _emailController,
                                      onChange: (value) => _loginBloc.add(
                                        EmailChangeEvent(emailText: value ?? ''),
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.02),
                                    BorderedTextField(
                                      label: 'Enter your password',
                                      hintText: 'password',
                                      controller: _pswdController,
                                      enabled: true,
                                      allowPasting: true,
                                      obscureText: true,
                                      onChange: (value) => _loginBloc.add(
                                        PasswordChangeEvent(pswdText: value ?? ''),
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.04),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        BorderedIconButton(
                                          icon: Icons.arrow_back_rounded,
                                          onTap: () => _loginBloc.add(
                                            SignUpClickEvent(),
                                          ),
                                        ),
                                        SizedBox(width: screenWidth * 0.02),
                                        GradientButton(
                                          buttonText: 'Submit',
                                          width: 0.65,
                                          onTap: () {
                                            _loginBloc.add(
                                              SignUpEvent(
                                                email: state.email ?? '',
                                                pswd: state.pswd ?? '',
                                              ),
                                            );
                                          },
                                        )
                                      ],
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    const FloatingTextBox(
                                      text:
                                          'We deliver at your doorstep within minutes !',
                                    ),
                                    SizedBox(height: screenHeight * 0.12),
                                    GradientButton(
                                      buttonText: 'Sign in',
                                      onTap: () {
                                        context.read<LoginBloc>().add(
                                              const SignUpEvent(
                                                email: 'test@gmail.com',
                                                pswd: '0123456789',
                                              ),
                                            );
                                      },
                                    ),
                                    SizedBox(height: screenHeight * 0.02),
                                    BorderedButton(
                                      buttonText: 'Sign up',
                                      onTap: () {
                                        _loginBloc.add(SignUpClickEvent());
                                      },
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
