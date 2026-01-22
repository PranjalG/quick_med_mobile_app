import 'package:flutter/widgets.dart';

extension ScreenExt on BuildContext {
  double get sw => MediaQuery.of(this).size.width;
  double get sh => MediaQuery.of(this).size.height;

  double fs(double size) {
    // 375 = base iPhone width (design standard)
    return size * (sw / 375);
  }
}
