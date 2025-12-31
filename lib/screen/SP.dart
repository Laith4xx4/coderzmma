import 'package:flutter/material.dart';
import 'package:thesavage/core/app_theme.dart';
import 'package:thesavage/features/auth1/presentation/pages/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thesavage/features/auth1/presentation/pages/onboarding_page.dart'; // Import Onboarding
import 'package:thesavage/screen/person.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thesavage/features/auth1/presentation/bloc/auth_cubit.dart';
import '../widgets/AnimatedNavExample.dart'; // Import Home/Person

class Sp extends StatefulWidget {
  const Sp({super.key});

  @override
  State<Sp> createState() => _SpState();
}

class _SpState extends State<Sp> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
    
    // Start navigation check
    _checkNavigation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkNavigation() async {
    try {
      // 1. Minimum Splash Duration
      await Future.delayed(const Duration(milliseconds: 2000));
      
      if (!mounted) return;

      final prefs = await SharedPreferences.getInstance();
      
      // 2. Check Valid Token
      final String? token = prefs.getString("token");
      final bool hasToken = token != null && token.isNotEmpty;
      
      // 3. Check Onboarding
      final bool seenOnboarding = prefs.getBool('onboarding_seen') ?? false;

      // 4. Navigate based on state
      if (!seenOnboarding) {
        // First time user -> Onboarding
        Navigator.pushReplacement(
            context, _createRoute(const OnboardingPage()));
      } else if (hasToken) {
        // Logged in user -> Home
        // Refresh profile to ensure fresh data (like userId)
        context.read<AuthCubit>().fetchUserProfile();
        
        Navigator.pushReplacement(
            context, _createRoute(const AnimatedNavExample()));
      } else {
        // Returning user, no session -> Login
        Navigator.pushReplacement(
            context, _createRoute(const LoginScreen()));
      }
    } catch (e) {
      debugPrint('Error in splash navigation: $e');
      // Fallback
      if (mounted) {
         Navigator.pushReplacement(
            context, _createRoute(const LoginScreen()));
      }
    }
  }
  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 800),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppTheme.primaryGradiente),
        child: Stack(
          children: [
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 120, height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: const Icon(Icons.sports_mma_rounded, size: 50, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'savage',
                      style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 8),
                    ),
                    const SizedBox(height: 50),
                    const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white24)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}