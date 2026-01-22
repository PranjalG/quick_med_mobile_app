import 'package:flutter/material.dart';
import 'package:quick_med/utils/screen_size.dart';

class TextStyles {
  static TextStyle body(BuildContext context) => TextStyle(
    fontSize: context.fs(14),
    fontWeight: FontWeight.w400,
  );

  static TextStyle bodyLarge(BuildContext context) => TextStyle(
    fontSize: context.fs(16),
    fontWeight: FontWeight.w400,
  );

  static TextStyle subtitle(BuildContext context) => TextStyle(
    fontSize: context.fs(18),
    fontWeight: FontWeight.w500,
  );

  static TextStyle title(BuildContext context) => TextStyle(
    fontSize: context.fs(20),
    fontWeight: FontWeight.w600,
  );

  static TextStyle headline(BuildContext context) => TextStyle(
    fontSize: context.fs(24),
    fontWeight: FontWeight.bold,
  );
}
