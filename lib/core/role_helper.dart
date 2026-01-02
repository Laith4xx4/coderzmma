import 'package:shared_preferences/shared_preferences.dart';

class RoleHelper {
  static const String adminRole = 'Admin';
  static const String coachRole = 'Coach';
  static const String memberRole = 'Member';

  /// جلب معرف المستخدم الحالي (ID)
  static Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("userId");
  }

  /// جلب اسم المستخدم الحالي (UserName) - جديد
  static Future<String?> getCurrentUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("userName"); // تأكد من تخزينه بهذا الاسم عند تسجيل الدخول
  }

  static Future<String> getCurrentUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("userRole") ?? memberRole;
  }

  static Future<bool> isAdmin() async {
    final role = await getCurrentUserRole();
    return role.toLowerCase() == adminRole.toLowerCase();
  }

  static Future<bool> isCoach() async {
    final role = await getCurrentUserRole();
    return role.toLowerCase() == coachRole.toLowerCase();
  }

  static Future<bool> isMember() async {
    final role = await getCurrentUserRole();
    return role.toLowerCase() == memberRole.toLowerCase();
  }

  static Future<bool> isClient() async {
    final role = await getCurrentUserRole();
    return role.toLowerCase() == 'client';
  }
  /// Check if user can manage members (Admin only)
  static Future<bool> canManageMembers() async {
    return await isAdmin();
  }

  /// Check if user can manage coaches (Admin only)
  static Future<bool> canManageCoaches() async {
    return await isAdmin();
  }

  /// Check if user can manage sessions (Admin only)
  static Future<bool> canManageSessions() async {
    return await isAdmin();
  }

  /// Check if user can manage class types (Admin only)
  static Future<bool> canManageClassTypes() async {
    return await isAdmin();
  }

  /// Check if user can manage bookings (Admin, Coach, Member)
  static Future<bool> canManageBookings() async {
    return true; // All roles can manage bookings
  }

  /// Check if user can manage attendance (Admin and Coach)
  static Future<bool> canManageAttendance() async {
    return await isAdmin() || await isCoach();
  }

  /// Check if user can manage feedbacks (All roles)
  static Future<bool> canManageFeedbacks() async {
    return true; // All roles can manage feedbacks
  }

  /// Check if user can manage progress (Admin and Coach)
  static Future<bool> canManageProgress() async {
    return await isAdmin() || await isCoach();
  }

  /// Check if user can view all data (Admin only)
  static Future<bool> canViewAllData() async {
    return await isAdmin();
  }
}
