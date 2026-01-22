import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quick_med/services/strings.dart';
import 'package:quick_med/services/theme_colours.dart';
import 'package:quick_med/utils/screen_size.dart';

import '../services/text_styles.dart';

class DataErrorWidget extends StatelessWidget {
  final String? message;
  final IconData icon;

  const DataErrorWidget({
    super.key,
    this.message,
    this.icon = CupertinoIcons.exclamationmark_triangle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.sw * 0.1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: ThemeColours.errorRed,
              size: context.sh * 0.05,
            ),
            SizedBox(height: context.sh * 0.015),
            Text(
              message ?? Strings.somethingWentWrongError,
              textAlign: TextAlign.center,
              style: TextStyles.bodyLarge(context).copyWith(
                color: ThemeColours.errorRed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
