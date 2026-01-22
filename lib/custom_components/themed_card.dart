import 'dart:math';

import 'package:flutter/material.dart';
import 'package:quick_med/services/strings.dart';
import 'package:quick_med/services/theme_colours.dart';
import 'package:quick_med/utils/screen_size.dart';

class ThemedCard extends StatelessWidget {
  final String title;
  final String subTitle;

  const ThemedCard({
    required this.title,
    required this.subTitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: context.sh * 0.01),
      // padding: EdgeInsets.symmetric(vertical: context.sh * 0.01, horizontal: context.sw * 0.01),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        // gradient: const LinearGradient(
        //   colors: [
        //     Color(0xFFFFFFFF), // White
        //     Color(0xFFF0F0F0),
        //     Color(0xFFF0F0F0),
        //     Color(0xFFF0F0F0),// Light Grey
        //   ],
        //   begin: Alignment.bottomLeft,
        //   end: Alignment.topRight,
        //   stops: [0, 0.2, 0.8, 1]
        // ),
        color: ThemeColours.appWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              Random().nextInt(10) % 2 == 0
                  ? 'assets/images/paracetamol.png'
                  : 'assets/images/levocitrizine.jpg',
              height: context.sh * 0.1,
              fit: BoxFit.cover,
            ),
          ),
          Row(
            children: [
              SizedBox(width: context.sw * 0.04),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: context.sh * 0.014,
                      color: ThemeColours.textGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${Strings.rupeeSymbol} $subTitle',
                    style: TextStyle(
                      fontSize: context.sh * 0.016,
                      color: ThemeColours.textLightGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
