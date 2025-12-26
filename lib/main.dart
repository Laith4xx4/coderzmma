// lib/main.dart
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 2. تحديث تهيئة Firebase لاستخدام خيارات المنصة الحالية
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await EasyLocalization.ensureInitialized();
  await di.init();
  runApp(const MyApp());
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
        home: const Sp(), // تأكد من إضافة const إذا كانت الشاشة ثابتة
      ),
    );
  }
}