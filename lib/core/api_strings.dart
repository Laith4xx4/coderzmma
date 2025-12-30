import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiStrings {
  static String get baseUrl {

    if (kIsWeb) return 'http://thesavage.runasp.net/api';
    

    if (Platform.isAndroid) {

      // 192.168.100.66 هو عنوان جهازك الحالي
      return 'http://thesavage.runasp.net/api';
    }
    
    // للـ iOS أو غيره
    return 'http://thesavage.runasp.net/api';
  }

  // Auth
  static const String loginEndpoint = '/Auth/login';
  static const String registerEndpoint = '/Auth/register';

  // Users
  static const String usersEndpoint = '/Users';
  static String usersByRoleEndpoint(String role) => '/Users/role/$role';

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
