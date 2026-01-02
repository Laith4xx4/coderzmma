import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiStrings {
  // ⚡ Change this to true to test local changes
  static const bool useLocalhost = false; 

  static String get baseUrl {
    if (useLocalhost) {
      if (kIsWeb) return 'http://localhost:5086/api';
      if (Platform.isAndroid) return 'http://10.0.2.2:5086/api';
      return 'http://localhost:5086/api';
    }

    if (kIsWeb) return 'http://thesavage.runasp.net/api';
    
    if (Platform.isAndroid) {
      return 'http://thesavage.runasp.net/api';
    }
    
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
