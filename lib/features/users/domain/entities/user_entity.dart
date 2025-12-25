class UserEntity {
  final String id;
  final String userName;
  final String email;
  final String? phoneNumber;
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final String role;

  UserEntity({
    required this.id,
    required this.userName,
    required this.email,
    this.phoneNumber,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    required this.role,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as String,
      userName: json['userName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      role: (json['role'] ?? json['Role'] ?? 'User') as String,
    );
  }

  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return userName;
  }
}
