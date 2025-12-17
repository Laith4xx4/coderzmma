import 'package:maa3/features/auth1/domain/entities/user.dart';

class UserModel extends User {
  // لا تقم بإعادة تعريف المتغيرات هنا لأنها موجودة في User

  UserModel({
    required super.id,
    required super.email,
    required super.role,
    super.token,
    super.firstName,   // نمررها للأب مباشرة
    super.lastName,    // نمررها للأب مباشرة
    super.phoneNumber, // نمررها للأب مباشرة
    super.dateOfBirth, // نمررها للأب مباشرة
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // استخدام toString() يضمن العمل سواء كان الـ ID نصاً أو رقماً في قاعدة البيانات
      id: json['id'].toString(),

      email: json['email'] ?? '', // تجنب الـ Null

      // هنا نضمن وجود Role حتى لو لم يرسله الباك اند
      role: json['role'] ?? 'Member',

      token: json['token'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phoneNumber: json['phoneNumber'],

      // tryParse أفضل من parse لأنه لا يسبب crash إذا كان التاريخ بتنسيق خاطئ
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'token': token,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
    };
  }
}