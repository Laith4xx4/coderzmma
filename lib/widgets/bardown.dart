import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:thesavage/core/app_theme.dart';
import 'package:thesavage/features/classtypes/presentation/pages/class_type_list_page.dart';
import 'package:thesavage/screen/AboutPage.dart';
import 'package:thesavage/screen/home.dart';
import 'package:thesavage/screen/person.dart';
import 'package:thesavage/widgets/sessionw.dart';

class AnimatedNavExample extends StatefulWidget {
  const AnimatedNavExample({super.key});

  @override
  State<AnimatedNavExample> createState() => _AnimatedNavExampleState();
}

class _AnimatedNavExampleState extends State<AnimatedNavExample> {
  int _selectedIndex = 1;

  final List<Widget> _screens = const [

    ClassTypeListPage(),
    Home(),
    AboutPage(),
    Person(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // نحافظ على ثبات حالة كل صفحة باستخدام IndexedStack
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),

      // شريط تنقل سفلي بتصميم GNav
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: GNav(
              gap: 10,
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              rippleColor: AppTheme.primaryColor.withOpacity(0.1),
              hoverColor: AppTheme.primaryColor.withOpacity(0.05),
              activeColor: Colors.white,
              iconSize: 24,
              padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              duration: const Duration(milliseconds: 250),
              tabBorderRadius: 24,
              backgroundColor: Colors.white,
              color: AppTheme.textSecondary,
              tabBackgroundColor: AppTheme.primaryColor,
              tabs: const [

                GButton(
                  icon: Icons.event_rounded,
                  text: 'Classes',
                ),
                GButton(
                  icon: Icons.home_rounded,
                  text: 'Home',
                ),
                GButton(
                  icon: Icons.event_rounded,
                  text: 'About',
                ),
                GButton(
                  icon: Icons.person_rounded,
                  text: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}