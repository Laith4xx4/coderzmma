import 'dart:async'; // Added
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maa3/screen/SP.dart';
import 'package:maa3/screen/splash.dart';
import 'package:maa3/widgets/bardown.dart';
import 'core/injection_container.dart' as di;
import 'core/bloc_providers.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:easy_localization/easy_localization.dart';
// 1. استيراد الملف الذي تم إنشاؤه بواسطة flutterfire
import 'firebase_options.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 2. تحديث تهيئة Firebase لاستخدام خيارات المنصة الحالية
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize Google Mobile Ads
    await MobileAds.instance.initialize();

    await EasyLocalization.ensureInitialized();
    await di.init();
    
    runApp(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations', 
        fallbackLocale: const Locale('en'),
        child: const MyApp(),
      ),
    );
  }, (error, stack) {
    debugPrint('Global Error caught: $error\n$stack');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: appBlocProviders,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true, // اختياري: لتفعيل أحدث واجهات جوجل
        ),
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        home: const Sp(), // تأكد من إضافة const إذا كانت الشاشة ثابتة
      ),
    );
  }
}