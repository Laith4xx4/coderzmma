import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:maa3/core/app_theme.dart';
import 'package:maa3/features/classtypes/presentation/pages/class_type_list_page.dart';
import 'package:maa3/screen/home.dart';
import 'package:maa3/screen/person.dart';
import 'package:maa3/widgets/sessionw.dart';

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
    Icons.calendar_month_rounded, // Sessions
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
        height: 65,
        width: 65,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient, // تدرج السكني والأسود
          shape: BoxShape.circle,
          boxShadow: AppTheme.elevatedShadow,
          border: Border.all(color: Colors.white, width: 2), // إطار أبيض لإبرازه
        ),
        child: FloatingActionButton(
          onPressed: () {
            setState(() => _bottomNavIndex = 0);
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.home_filled, color: Colors.white, size: 30),
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
              const SizedBox(height: 4),
              // مؤشر سفلي أنيق عند التفعيل
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isActive ? 12 : 0,
                height: 2,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          );
        },
        activeIndex: _bottomNavIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.softEdge, // نعومة أكثر للانحناء
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        backgroundColor: Colors.white, // خلفية بيضاء نقية
        elevation: 20,
        onTap: (index) => setState(() => _bottomNavIndex = index),
        shadow: Shadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, -5),
        ),
      ),
    );
  }
}