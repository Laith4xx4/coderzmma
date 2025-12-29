import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thesavage/core/app_theme.dart';
import 'package:thesavage/screen/SP.dart';

import 'core/injection_container.dart' as di;
import 'core/bloc_providers.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:easy_localization/easy_localization.dart';
import 'firebase_options.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // تهيئة Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // حل مشكلة التوقف: تهيئة الإعلانات فقط إذا لم يكن الجهاز "ويب"
    // لأن مكتبة الإعلانات تسبب Crash على المتصفح إذا لم يتم إعدادها بشكل خاص
    if (!kIsWeb) {
      await MobileAds.instance.initialize();
    }

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
          scaffoldBackgroundColor: AppTheme.backgroundColor,
          brightness: Brightness.dark,
          primaryColor: AppTheme.primaryColor,
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.primaryColor,
            surface: AppTheme.cardBackground,
            onSurface: AppTheme.textPrimary,
            background: AppTheme.backgroundColor,
          ),
          useMaterial3: true,
        ),
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        home: const Sp(),
      ),
    );
  }
}