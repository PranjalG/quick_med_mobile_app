import 'package:flutter/material.dart';
import 'package:quick_med/services/theme_colours.dart';

class ThemedCard extends StatelessWidget {
  final String title;
  final String time;

  const ThemedCard({
    required this.title,
    required this.time,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        // border: Border.all(
        //   color: ThemeColours.lightGrey, // Thin, subtle border
        //   width: 0.8,
        // ),
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
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10), // Adjust radius as needed
            child: Image.asset(
              'assets/images/apollo_pharmacy.png',
              height: 90,
              fit: BoxFit.cover,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: ThemeColours.textGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$time mins',
            style: const TextStyle(fontSize: 14, color: ThemeColours.textLightGrey),
          ),
        ],
      ),
    );
  }
}
