import 'package:maa3/features/auth1/domain/entities/user.dart';
import 'package:maa3/features/auth1/domain/repositories/auth_repository.dart';

class RegisterUser {
  final AuthRepository repository;

  RegisterUser(this.repository);

  /// دالة تسجيل مستخدم جديد
  /// الآن تدعم الحقول الاختيارية مثل الاسم الأول/الأخير، رقم الهاتف وتاريخ الميلاد
  Future<User> call({
    required String email,
    required String password,
    required String role,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    DateTime? dateOfBirth,
  }) {
    return repository.register(
      email: email,
      password: password,
      role: role,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      dateOfBirth: dateOfBirth,
    );
  }
}
