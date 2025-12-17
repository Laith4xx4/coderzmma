import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:maa3/core/app_theme.dart';
import 'package:maa3/features/classtypes/presentation/pages/class_type_list_page.dart';
import 'package:maa3/screen/home.dart';
import 'package:maa3/screen/person.dart';

import 'package:maa3/widgets/sessionw.dart';

class AnimatedNavExample extends StatefulWidget {
  @override
  State<AnimatedNavExample> createState() => _AnimatedNavExampleState();
}

class _AnimatedNavExampleState extends State<AnimatedNavExample> {
  int _bottomNavIndex = 0;

  final iconList = <IconData>[
    Icons.home_rounded,
    Icons.category_rounded,
    Icons.event_rounded,
    Icons.person_rounded,
  ];

  final List<String> labels = ['Home', 'Classes', 'Sessions', 'Profile'];

  final List<Widget> screens = [
    const Home(),
    const ClassTypeListPage(),
    const Sessionw(),
    const Person(),
  ];

  final List<Color> activeColors = [
    AppTheme.primaryColor,
    AppTheme.primaryColor,
    AppTheme.primaryColor,
    AppTheme.primaryColor,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_bottomNavIndex],
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: AppTheme.elevatedShadow,
        ),
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              _bottomNavIndex = 0; // العودة للصفحة الرئيسية
            });
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.home_rounded, color: Colors.white, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: iconList.length,
        tabBuilder: (int index, bool isActive) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                iconList[index],
                size: isActive ? 26 : 24,
                color: isActive ? activeColors[index] : AppTheme.textSecondary,
              ),
              if (isActive) ...[
                const SizedBox(height: 4),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: activeColors[index],
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          );
        },
        activeIndex: _bottomNavIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.verySmoothEdge,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        backgroundColor: Colors.white,
        elevation: 8,
        shadow: BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, -2),
        ),
        onTap: (index) {
          setState(() {
            _bottomNavIndex = index;
          });
        },
      ),
    );
  }
}
