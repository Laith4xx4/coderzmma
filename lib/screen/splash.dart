import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team1/SP.dart';
// import 'package:team1/screens/auth/login_screen.dart';
// import 'package:team1/screens/main_feed_screen.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    goTo();
    print("splash screen");
  }

  goTo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? remember = prefs.getBool('isRememberMe');
    print('remember me value is : $remember');

    // تأخير 3 ثواني قبل الانتقال
    await Future.delayed(const Duration(seconds: 3));



       Navigator.pushReplacement(
         context,
         MaterialPageRoute(builder: (context) => Sp()),
       );

      // انتقل لشاشة تسجيل الدخول إذا لم يحدد المستخدم تذكرني
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => LoginScreen()),
      // );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF129AA6), // purple background
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // لتوسيط المحتوى عموديًا
          children: [
            Container(
              width: 200,
              height: 200,
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.circular(20),
              //   image: const DecorationImage(
              //     image: AssetImage('assets/rt.png'),
              //     fit: BoxFit.cover,
              //   ),
              // ),
            ),
            const SizedBox(height: 20),
            // const Text(
            //   'ecommerce',
            //   style: TextStyle(
            //     color: Colors.white,
            //     fontSize: 20,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
