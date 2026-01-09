import 'package:flutter/widgets.dart';

extension ScreenExt on BuildContext {
  double get sw => MediaQuery.of(this).size.width;
  double get sh => MediaQuery.of(this).size.height;
}
