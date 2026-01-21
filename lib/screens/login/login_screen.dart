import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_med/custom_components/bordered_button.dart';
import 'package:quick_med/custom_components/bordered_icon_button.dart';
import 'package:quick_med/custom_components/bordered_textfield.dart';
import 'package:quick_med/custom_components/floating_text_box.dart';
import 'package:quick_med/custom_components/gradient_button.dart';
import 'package:quick_med/custom_components/loading_indicator.dart';
import 'package:quick_med/screens/login/logo_widget.dart';
import 'package:quick_med/services/auth.dart';
import 'package:quick_med/services/enum.dart';
import 'package:quick_med/utils/screen_size.dart';

import '../../blocs/login_bloc/login_bloc.dart';

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
    return BlocProvider(
      create: (_) => _loginBloc,
      child: Scaffold(
        body: SafeArea(
          child: BlocConsumer<LoginBloc, LoginState>(
            listener: (context, state) {
              if (state.loginResponseStatus == Status.success) {
                context.go('/home_screen');
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                child: Stack(
                  children: [
                    Opacity(
                      opacity: 1,
                      child: Image.asset(
                        'assets/images/Gradient.png',
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(context.sw * 0.02),
                      child: Column(
                        children: [
                          const LogoWidget(),
                          state.loginResponseStatus == Status.loading
                              ? SizedBox(
                                  height: context.sh * 0.5,
                                  child: const LoadingIndicator(),
                                )
                              : !state.userLogin
                                  ? Column(
                                      children: [
                                        const FloatingTextBox(
                                          text:
                                              'We deliver at your doorstep within minutes !',
                                        ),
                                        SizedBox(height: context.sh * 0.14),
                                        GradientButton(
                                          buttonText: 'Sign in',
                                          onTap: () {
                                            _loginBloc.add(SignInClickEvent());
                                          },
                                        ),
                                        SizedBox(height: context.sh * 0.02),
                                        BorderedButton(
                                          buttonText: 'Sign up',
                                          onTap: () {
                                            _loginBloc.add(SignUpClickEvent());
                                          },
                                        ),
                                      ],
                                    )
                                  : state.userLoginType == UserLogin.signUp
                                      ?
                                      // sign up action widget
                                      Padding(
                                          padding: EdgeInsets.only(
                                            left: context.sw * 0.07,
                                            right: context.sw * 0.07,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                  height: context.sh * 0.106),
                                              BorderedTextField(
                                                label: 'Enter your email',
                                                hintText: '',
                                                enabled: true,
                                                controller: _emailController,
                                                keyboardType:
                                                    TextInputType.emailAddress,
                                                inputFormatter: [
                                                  FilteringTextInputFormatter
                                                      .allow(
                                                    RegExp(
                                                        r'[a-zA-Z0-9@._\-+]'),
                                                  ),
                                                  FilteringTextInputFormatter
                                                      .deny(RegExp(r'\s')),
                                                ],
                                                errorText: state.emailErrorText,
                                                textInputAction:
                                                    TextInputAction.done,
                                                onSubmit: () {
                                                  _loginBloc.add(
                                                    EmailValidateEvent(),
                                                  );
                                                },
                                                onChange: (value) {
                                                  context.read<LoginBloc>().add(
                                                        EmailChangeEvent(
                                                          emailText:
                                                              value ?? '',
                                                        ),
                                                      );
                                                },
                                              ),
                                              SizedBox(
                                                  height: context.sh * 0.02),
                                              BorderedTextField(
                                                label: 'Enter your password',
                                                hintText: '',
                                                controller: _pswdController,
                                                enabled: true,
                                                allowPasting: true,
                                                obscureText: true,
                                                onChange: (value) =>
                                                    _loginBloc.add(
                                                  PasswordChangeEvent(
                                                    pswdText: value ?? '',
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                  height: context.sh * 0.04),
                                              Row(
                                                children: [
                                                  BorderedIconButton(
                                                    icon: Icons
                                                        .arrow_back_rounded,
                                                    onTap: () => _loginBloc.add(
                                                      BackButtonClick(),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width: context.sw * 0.02),
                                                  GradientButton(
                                                    buttonText: 'Submit',
                                                    width: 0.6,
                                                    enabled:
                                                        (state.emailErrorText ==
                                                                    null ||
                                                                state.emailErrorText ==
                                                                    '') &&
                                                            state.pswd != null,
                                                    onTap: () {
                                                      _loginBloc.add(
                                                        SignUpEvent(
                                                          email:
                                                              state.email ?? '',
                                                          pswd:
                                                              state.pswd ?? '',
                                                        ),
                                                      );
                                                    },
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      : state.userLoginType == UserLogin.signIn
                                          ?
                                          // sign in action widget
                                          Column(
                                              children: [
                                                SizedBox(
                                                    height: context.sh * 0.12),
                                                BorderedButton(
                                                  buttonText:
                                                      'Sign in with Google',
                                                  trailingIcon:
                                                      FontAwesomeIcons.google,
                                                  onTap: () {},
                                                ),
                                                SizedBox(
                                                    height: context.sh * 0.02),
                                                BorderedButton(
                                                  buttonText:
                                                      'Sign in with Apple',
                                                  trailingIcon:
                                                      Icons.apple_rounded,
                                                  onTap: () {},
                                                ),
                                                SizedBox(
                                                    height: context.sh * 0.04),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                        width:
                                                            context.sw * 0.08),
                                                    BorderedIconButton(
                                                      icon: Icons
                                                          .arrow_back_rounded,
                                                      onTap: () =>
                                                          _loginBloc.add(
                                                        BackButtonClick(),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )
                                          : const SizedBox.shrink(),
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
