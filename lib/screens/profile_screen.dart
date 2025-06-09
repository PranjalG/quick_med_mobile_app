import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.directional(
            start: double.minPositive * 2,
            textDirection: TextDirection.ltr,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Anastasiya'),
                          Text('anastasiya@gmail.com'),
                        ],
                      ),
                      const SizedBox(width: 50),
                      Image.asset(
                        'assets/images/profile_woman.png',
                        height: 140,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: DraggableScrollableSheet(
              initialChildSize: 0.3,
              minChildSize: 0.2,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: 50,
                    itemBuilder: (context, index) => ListTile(
                      title: Text('Item $index'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
