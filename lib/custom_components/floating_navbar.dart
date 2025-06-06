import 'package:flutter/material.dart';

class FloatingNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap; // callback to notify parent when tab changes

  const FloatingNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static final List<String> _icons = [
    'assets/icons/home.png',
    'assets/icons/profile_icon.png',
    'assets/icons/cart.png',
  ];

  static final List<String> _labels = ['Home', 'Profile', 'Cart'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: onTap,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              selectedItemColor: Colors.deepPurple,
              unselectedItemColor: Colors.grey,
              backgroundColor: Colors.white,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              items: List.generate(
                _icons.length,
                (index) {
                  final isActive = index == currentIndex;
                  return BottomNavigationBarItem(
                    label: '',
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: isActive
                          ? BoxDecoration(
                              border: Border.all(
                                  color: Colors.green.shade100, width: 2),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.green.shade100,
                            )
                          : null,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            _icons[index],
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: 8),
                          isActive ? SizedBox(
                            width: 50,
                            child: Text(
                              _labels[index],
                              style: TextStyle(
                                color: Colors.green.shade500,
                              ),
                            ),
                          ) : const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
