class CreateMemberProfileModel {
  final String userName;
  final String? firstName;
  final String? lastName;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? medicalInfo;
  final DateTime joinDate;

  CreateMemberProfileModel({
    required this.userName,
    this.firstName,
    this.lastName,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.medicalInfo,
    required this.joinDate,
  });

  // التصحيح في تحويل البيانات لضمان عدم إرسال حقول إجبارية فارغة للسيرفر
  Map<String, dynamic> toJson() {
    return {
      'UserName': userName,
      'FirstName': firstName ?? '', // نضع نصاً فارغاً إذا كان null لتجنب مشاكل الـ Backend
      'LastName': lastName ?? '',
      'EmergencyContactName': emergencyContactName ?? '',
      'EmergencyContactPhone': emergencyContactPhone ?? '',
      'MedicalInfo': medicalInfo ?? '',
      'JoinDate': joinDate.toIso8601String(),
    };
  }

  // إضافة factory من أجل التحويل من JSON في حال احتجت لعرض البيانات بعد إنشائها
  factory CreateMemberProfileModel.fromJson(Map<String, dynamic> json) {
    return CreateMemberProfileModel(
      userName: json['userName'] ?? '', // استخدام ?? لضمان عدم استقبال Null
      firstName: json['firstName'],
      lastName: json['lastName'],
      emergencyContactName: json['emergencyContactName'],
      emergencyContactPhone: json['emergencyContactPhone'],
      medicalInfo: json['medicalInfo'],
      joinDate: json['joinDate'] != null
          ? DateTime.parse(json['joinDate'])
          : DateTime.now(),
    );
  }
}