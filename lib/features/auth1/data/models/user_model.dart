import 'package:thesavage/features/auth1/domain/entities/user.dart';

class UserModel extends User {
  // إزالة const
  UserModel({
    required super.id,
    required super.email,
    required super.role,
    required super.userName,
    super.token,
    super.firstName,
    super.lastName,
    super.phoneNumber,
    super.dateOfBirth,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final dateString = json['dateOfBirth'] ?? json['DateOfBirth'];

    String role = 'Member';
    if (json.containsKey('role') && json['role'] != null && json['role'].toString().isNotEmpty) {
      role = json['role'].toString();
    } else if (json.containsKey('roles') && json['roles'] is List && (json['roles'] as List).isNotEmpty) {
      role = (json['roles'] as List).first.toString();
    }

    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: role,
      userName: (json['userName'] ?? json['UserName'] ?? '').toString(),
      token: json['token']?.toString(),
      firstName: json['firstName'] ?? json['FirstName'],
      lastName: json['lastName'] ?? json['LastName'],
      phoneNumber: json['phoneNumber'] ?? json['PhoneNumber'],
      dateOfBirth: dateString != null ? DateTime.tryParse(dateString.toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'userName': userName,
      'token': token,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
    };
  }
}
