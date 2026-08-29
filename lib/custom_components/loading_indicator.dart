import 'package:flutter/cupertino.dart';
import 'package:quick_med/utils/screen_size.dart';
import 'package:quick_med/services/app_colors.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CupertinoActivityIndicator(
        color: AppColors.primaryDark,
        animating: true,
        radius: context.sh * 0.02,
      ),
    );
  }
}
