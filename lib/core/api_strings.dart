import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiStrings {
  static String get baseUrl {
    // إذا كنا نعمل على الويب، نستخدم النطاق المحلي العادي
    if (kIsWeb) return 'http://localhost:5086/api';
    
    // إذا كنا على الأندرويد، نتحقق مما إذا كنا على المحاكي
    if (Platform.isAndroid) {
      // نستخدم IP الجهاز المضيف (الكمبيوتر) للعمل على الهاتف الحقيقي
      // 192.168.100.66 هو عنوان جهازك الحالي
      return 'http://192.168.100.66:5086/api';
    }
    
    // للـ iOS أو غيره
    return 'http://localhost:5086/api';
  }

  // Auth
  static const String loginEndpoint = '/Auth/login';
  static const String registerEndpoint = '/Auth/register';

  // Members
  static const String memberProfilesEndpoint = '/MemberProfiles';

  // Coaches
  static const String coachProfilesEndpoint = '/CoachProfiles';

  // Sessions / Classes / Bookings / Attendance
  static const String sessionsEndpoint = '/Sessions';
  static const String classTypesEndpoint = '/ClassTypes';
  static const String bookingsEndpoint = '/Bookings';
  static const String attendancesEndpoint = '/Attendances';

  // Feedback & Progress
  static const String feedbackEndpoint = '/Feedbacks';
  static const String memberSetProgressEndpoint = '/MemberSetProgress';
}
