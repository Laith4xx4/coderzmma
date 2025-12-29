import 'package:thesavage/features/auth1/domain/entities/user.dart';
import 'package:thesavage/features/auth1/domain/repositories/auth_repository.dart';

/// 🧠 LoginUser:
/// هذا هو "Use Case" (حالة استخدام) في طبقة الـ Domain.
/// مسؤوليته هي تنفيذ عملية تسجيل الدخول.
/// لا يحتوي على منطق الواجهة أو الاتصال المباشر بالسيرفر.
/// فقط يستدعي الدالة من الـ Repository المناسب.
class LoginUser {
  /// المرجع إلى الـ Repository الذي يتعامل مع مصدر البيانات (API أو قاعدة بيانات)
  final AuthRepository repository;

  /// المُنشئ (Constructor) يأخذ الـ repository كمعامل
  LoginUser(this.repository);

  /// 🔹 عند استدعاء الكلاس كدالة (call)
  /// يتم تمرير البريد الإلكتروني وكلمة المرور
  /// ثم يتم إرجاع كائن من نوع [User] بعد تنفيذ عملية تسجيل الدخول.
  Future<User> call(String email, String password) {
    // يتم تمرير البيانات إلى الـ repository لتنفيذ عملية تسجيل الدخول
    return repository.login(email, password);
  }
}
