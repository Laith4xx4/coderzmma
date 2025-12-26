import 'package:flutter/material.dart';
import 'package:maa3/core/app_theme.dart';
import 'package:maa3/features/auth1/presentation/pages/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/AnimatedNavExample.dart';

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
      duration: const Duration(milliseconds: 1200), // تقليل وقت الأنيميشن قليلاً لسرعة الاستجابة
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // ⚡ البدء بفحص التوكن فوراً دون انتظار 3 ثوانٍ
    checkToken();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> checkToken() async {
    // 1. نبدأ بجلب البيانات من الذاكرة بالتوازي مع الأنيميشن
    // final prefs = await SharedPreferences.getInstance();
    // final String token = prefs.getString("token") ?? "";

    // حذف التوكن عند بدء التطبيق لضمان عدم الحفظ (بناءً على طلب المستخدم)
    // await prefs.remove('token'); 

    // 2. ننتظر فقط الحد الأدنى المطلوب للأنيميشن
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // 3. الانتقال دائماً لشاشة تسجيل الدخول
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // خلفية ثابتة لمنع "الومضات"
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
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
                      'MAA',
                      style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 8),
                    ),
                    const SizedBox(height: 50),
                    // مؤشر تحميل صغير جداً لا يشتت الانتباه
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