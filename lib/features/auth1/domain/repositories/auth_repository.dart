// استيراد كلاس User من مجلد الـ domain entities
import 'package:maa3/features/auth1/domain/entities/user.dart';

// تعريف واجهة (abstract class) لمستودع المصادقة
abstract class AuthRepository {
  /// دالة لتسجيل دخول المستخدم
  /// تأخذ البريد الإلكتروني وكلمة المرور كمعاملات
  /// تعيد Future يحتوي على كائن User عند نجاح تسجيل الدخول
  Future<User> login(String email, String password);

  /// دالة لتسجيل مستخدم جديد
  /// تأخذ الحقول الأساسية + الحقول الاختيارية
  /// تعيد Future يحتوي على كائن User عند نجاح التسجيل
  Future<User> register({
    required String email,
    required String password,
    required String role,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    DateTime? dateOfBirth,
  });
  Future<User> getUserProfile(String email);
}
