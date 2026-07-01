import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quick_med/utils/screen_size.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle splashTitle(BuildContext context) => GoogleFonts.palanquinDark(
        fontSize: context.fs(42),
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      );

  static TextStyle splashSubtitle(BuildContext context) => GoogleFonts.montserrat(
        fontSize: context.fs(16),
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      );

  static TextStyle body(BuildContext context) => GoogleFonts.montserrat(
        fontSize: context.fs(14),
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle bodyLarge(BuildContext context) => GoogleFonts.montserrat(
        fontSize: context.fs(16),
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle title(BuildContext context) => GoogleFonts.montserrat(
        fontSize: context.fs(20),
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle headline(BuildContext context) => GoogleFonts.montserrat(
        fontSize: context.fs(24),
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle onboardingTitle(BuildContext context) => GoogleFonts.montserrat(
        fontSize: context.fs(24),
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle onboardingSubtitle(BuildContext context) => GoogleFonts.montserrat(
        fontSize: context.fs(16),
        fontWeight: FontWeight.w500,
        color: AppColors.grey,
        height: 1.5,
      );

  static TextStyle buttonText(BuildContext context) => GoogleFonts.montserrat(
        fontSize: context.fs(18),
        fontWeight: FontWeight.bold,
        color: AppColors.white,
      );

  static TextStyle skipText(BuildContext context) => GoogleFonts.montserrat(
        fontSize: context.fs(15),
        fontWeight: FontWeight.w600,
        color: AppColors.grey,
      );

  static TextStyle inputText(BuildContext context) => GoogleFonts.montserrat(
        fontSize: context.fs(16),
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  static TextStyle hintText(BuildContext context) => GoogleFonts.montserrat(
        fontSize: context.fs(16),
        fontWeight: FontWeight.w500,
        color: AppColors.grey,
      );

  static TextStyle forgotPasswordText(BuildContext context) => GoogleFonts.montserrat(
        fontSize: context.fs(15),
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      );

  static TextStyle homeTitle(BuildContext context) => GoogleFonts.palanquinDark(
        fontSize: context.fs(20),
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      );

  static TextStyle homeHeading(BuildContext context) => GoogleFonts.montserrat(
        fontSize: context.fs(24),
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle homeSectionHeader(BuildContext context) => GoogleFonts.montserrat(
        fontSize: context.fs(18),
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle bannerTitle(BuildContext context) => GoogleFonts.montserrat(
        fontSize: context.fs(20),
        fontWeight: FontWeight.w900,
        color: AppColors.white,
      );

  static TextStyle bannerBody(BuildContext context) => GoogleFonts.montserrat(
        fontSize: context.fs(13),
        fontWeight: FontWeight.w500,
        color: AppColors.white.withValues(alpha: 0.85),
      );

  static TextStyle bannerButton(BuildContext context) => GoogleFonts.montserrat(
        fontSize: context.fs(14),
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle categoryLabel(BuildContext context) => GoogleFonts.montserrat(
        fontSize: context.fs(12),
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle chipTitle(BuildContext context) => GoogleFonts.montserrat(
        fontSize: context.fs(13),
        fontWeight: FontWeight.bold,
        color: AppColors.white,
      );

  static TextStyle chipSubtitle(BuildContext context) => GoogleFonts.montserrat(
        fontSize: context.fs(11),
        fontWeight: FontWeight.w600,
        color: AppColors.white.withValues(alpha: 0.85),
      );
}
