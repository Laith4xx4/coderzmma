class CreateMemberProfileModel {
  final String userId;
  final String? firstName;
  final String? lastName;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? medicalInfo;
  final DateTime joinDate;

  CreateMemberProfileModel({
    required this.userId,
    this.firstName,
    this.lastName,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.medicalInfo,
    required this.joinDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'FirstName': firstName,
      'LastName': lastName,
      'EmergencyContactName': emergencyContactName,
      'EmergencyContactPhone': emergencyContactPhone,
      'MedicalInfo': medicalInfo,
      'JoinDate': joinDate.toIso8601String(),
    };
  }
}