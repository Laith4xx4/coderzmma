import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:thesavage/core/app_theme.dart';
import 'package:thesavage/features/classtypes/presentation/pages/class_type_list_page.dart';
import 'package:thesavage/screen/home.dart';
import 'package:thesavage/screen/person.dart';
import 'package:thesavage/widgets/sessionw.dart';

import '../screen/AboutPage.dart';

class AnimatedNavExample extends StatefulWidget {
  const AnimatedNavExample({super.key});

  @override
  State<AnimatedNavExample> createState() => _AnimatedNavExampleState();
}

class _AnimatedNavExampleState extends State<AnimatedNavExample> {
  int _bottomNavIndex = 0;

  final iconList = <IconData>[
    Icons.grid_view_rounded,     // Home
    Icons.fitness_center_rounded, // Classes
    Icons.info_outline_rounded,         // About, // Sessions
    Icons.account_circle_rounded, // Profile
  ];

  final List<Widget> screens = [
    const Home(),
    const ClassTypeListPage(),

    const AboutPage(),
    const Person(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // لجعل المحتوى يظهر خلف الانحناءات بشكل جميل
      body: screens[_bottomNavIndex],

      // الزر العائم بتصميم أسود فخم (Monochrome)
      floatingActionButton: Container(
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ],
          border: Border.all(color: const Color(0xFF112117), width: 4), // Dark ring around FAB
        ),
        child: FloatingActionButton(
          onPressed: () {
            setState(() => _bottomNavIndex = 0);
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.home_rounded, color: Color(0xFF112117), size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: iconList.length,
        tabBuilder: (int index, bool isActive) {
          final color = isActive ? AppTheme.primaryColor : AppTheme.textLight;
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                iconList[index],
                size: isActive ? 28 : 24,
                color: color,
              ),
              if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 4, height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.5), blurRadius: 6)]
                ),
              )
            ],
          );
        },
        activeIndex: _bottomNavIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.smoothEdge, 
        leftCornerRadius: 20,
        rightCornerRadius: 20,
        backgroundColor: const Color(0xFF2B2A2A), // Dark Green Card Color
        elevation: 0,
        onTap: (index) => setState(() => _bottomNavIndex = index),
      ),
    );
  }
}