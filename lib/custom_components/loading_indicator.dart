import 'package:flutter/cupertino.dart';
import 'package:quick_med/services/theme_colours.dart';
import 'package:quick_med/utils/screen_size.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CupertinoActivityIndicator(
        color: ThemeColours.darkGreen,
        animating: true,
        radius: context.sh * 0.02,
      ),
    );
  }
}
