import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../custom_components/brand_curved_header.dart';
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
          if (state.needsProfileSetup) {
            context.go('/profile_setup');
          } else {
            context.go('/home_screen');
          }
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
          body: Column(
            children: [
              const BrandCurvedHeader(heightFactor: 0.22),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: showOtp
                      ? OtpEntryScreen(phoneDisplay: phoneDisplay)
                      : const PhoneEntryScreen(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
