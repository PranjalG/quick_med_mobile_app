import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../services/app_colors.dart';
import '../bloc/phone_auth_cubit.dart';
import '../bloc/phone_auth_state.dart';
import 'otp_entry_screen.dart';
import 'phone_entry_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PhoneAuthCubit(),
      child: const AuthView(),
    );
  }
}

class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PhoneAuthCubit, PhoneAuthState>(
      listener: (context, state) {
        if (state is PhoneAuthSuccess) {
          context.go('/home_screen');
        } else if (state is PhoneAuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<PhoneAuthCubit>();
        final showOtp = switch (state) {
          PhoneAuthInitial() => false,
          PhoneAuthSuccess() => false,
          PhoneAuthCodeSent() => true,
          PhoneAuthVerifying() => true,
          PhoneAuthCodeSending() => cubit.hasActiveVerification,
          PhoneAuthFailure() => cubit.hasActiveVerification,
          // TODO: Handle this case.
          PhoneAuthState() => throw UnimplementedError(),
        };

        final phoneDisplay = cubit.phoneDisplay.isNotEmpty
            ? cubit.phoneDisplay
            : switch (state) {
                PhoneAuthCodeSent(:final phoneDisplay) => phoneDisplay,
                PhoneAuthVerifying(:final phoneDisplay) => phoneDisplay,
                _ => '',
              };

        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          body: Stack(
            children: [
              // Full-bleed medical-doodle background. BoxFit.cover keeps the
              // aspect ratio (no distortion) and crops any overflow.
              Positioned.fill(
                child: Image.asset(
                  'assets/images/Gradient.png',
                  fit: BoxFit.cover,
                ),
              ),
              // Soft mint veil so the card and text stay readable over the
              // doodles without altering the image itself.
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.74),
                        AppColors.primary.withValues(alpha: 0.82),
                        AppColors.scaffoldBackground.withValues(alpha: 0.92),
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: showOtp
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: OtpEntryScreen(phoneDisplay: phoneDisplay),
                      )
                    : const PhoneEntryScreen(),
              ),
            ],
          ),
        );
      },
    );
  }
}
