import 'package:flutter/material.dart';
import 'package:thesavage/core/app_theme.dart';
import 'package:thesavage/screen/SP.dart'; // الانتقال إلى شاشة فحص التوكن
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  _navigateToNext() async {
    // ننتظر قليلاً ليتمكن المستخدم من رؤية هوية التطبيق (Brand)
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // ننتقل إلى شاشة Sp التي تحتوي على الأنيميشن المتقدم وفحص التوكن
    // استخدمنا PageRouteBuilder للحصول على انتقال "تلاشي" (Fade) ناعم جداً
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const Sp(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient, // نفس التدرج الموجود في AppTheme و Sp
        ),
        child: Stack(
          children: [
            // إضافة لمسة خفيفة من الدوائر الزخرفية لتتطابق مع شاشة Sp القادمة
            Positioned(
              top: -50,
              right: -50,
              child: _buildBackgroundDecoration(200),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // أنيميشن ظهور الشعار
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.scale(
                          scale: 0.8 + (0.2 * value),
                          child: child,
                        ),
                      );
                    },
                    child: Image.asset(
                      'assets/maa3.png',
                      width: 180,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.sports_mma_rounded,
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // نص الهوية
                  const Text(
                    'MAA MANAGEMENT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 6, // تباعد واسع للفخامة
                    ),
                  ),
                ],
              ),
            ),

            // مؤشر التحميل في الأسفل بشكل أنيق
            const Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    color: Colors.white12,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundDecoration(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.03),
      ),
    );
  }
}