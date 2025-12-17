/// تعريف كلاس User الذي يمثل المستخدم داخل التطبيق
class User {
  /// معرف فريد للمستخدم
  final String id;

  /// البريد الإلكتروني للمستخدم
  final String email;

  /// دور المستخدم (مثل "admin" أو "user")
  final String role;

  /// توكن المصادقة، قد يكون null لبعض العمليات
  final String? token;

  /// الاسم الأول للمستخدم (اختياري)
  final String? firstName;

  /// الاسم الأخير للمستخدم (اختياري)
  final String? lastName;

  /// رقم الهاتف (اختياري)
  final String? phoneNumber;

  /// تاريخ الميلاد (اختياري)
  final DateTime? dateOfBirth;

  /// الكونستركتور لإنشاء كائن User
  /// الحقول id, email, role مطلوبة، أما الباقي فهي اختياري
  User({
    required this.id,
    required this.email,
    required this.role,
    this.token,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.dateOfBirth,
  });

  /// إعادة تعريف عامل المساواة == لمقارنة كائنات User
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.id == id &&
        other.email == email &&
        other.role == role &&
        other.token == token &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.phoneNumber == phoneNumber &&
        other.dateOfBirth == dateOfBirth;
  }

  /// إعادة تعريف hashCode لدعم الاستخدام في الـ collections مثل Set أو Map
  @override
  int get hashCode {
    return id.hashCode ^
    email.hashCode ^
    role.hashCode ^
    token.hashCode ^
    firstName.hashCode ^
    lastName.hashCode ^
    phoneNumber.hashCode ^
    dateOfBirth.hashCode;
  }
}
