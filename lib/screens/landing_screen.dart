import 'dart:math';

import 'package:flutter/material.dart';
import 'package:quick_med/custom_components/themed_card.dart';
import 'package:quick_med/custom_components/themed_text_field.dart';
import 'package:quick_med/services/theme_colours.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final List<String> items =
      List.generate(30, (index) => 'Apollo Pharmacy $index');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColours.appWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 20, right: 10, left: 10),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Find your medicine',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: ThemeColours.darkGreen,
                          ),
                        ),
                        Text(
                          'via nearest pharmacy',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: ThemeColours.darkGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.notifications,
                    color: ThemeColours.lightGreen,
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    child: ThemedTextField(
                      hintText: 'What do you want to order?',
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Icon(
                      Icons.tune,
                      color: ThemeColours.darkOrange,
                      size: 24,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 🔧 Number of columns
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1/1, // Width/Height ratio of each card
                  ),
                  itemBuilder: (context, index) {
                    return ThemedCard(
                      title: items[index],
                      time: Random().nextInt(41).toString(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
