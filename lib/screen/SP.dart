import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team1/features/auth1/presentation/pages/login_screen.dart';
import 'package:team1/screen/home.dart';

import 'screen/AnimatedNavExample.dart'; // شاشة الهوم — عدل المسار إذا لازم

class Sp extends StatefulWidget {
  const Sp({super.key});

  @override
  State<Sp> createState() => _SpState();
}

class _SpState extends State<Sp> {

  @override
  void initState() {
    super.initState();
    checkToken(); // 👈 فحص التوكن عند فتح الصفحة
  }

  Future<void> checkToken() async {
    await Future.delayed(const Duration(seconds: 3)); // سبلاش

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token"); // 👈 قراءة التوكن

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      // ✔ إذا فيه توكن → الهوم
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) =>   AnimatedNavExample()),
      );
    } else {
      // ✔ إذا ما فيه توكن → لوجن
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF129AA6),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: AssetImage('assets/Online_LS__1_-removebg-preview.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'ecommerce',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
