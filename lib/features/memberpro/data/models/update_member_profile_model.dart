class UpdateMemberProfileModel {
  final String? firstName;
  final String? lastName;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? medicalInfo;

  UpdateMemberProfileModel({
    this.firstName,
    this.lastName,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.medicalInfo,
  });

  Map<String, dynamic> toJson() {
    // التصحيح: السيرفر في C# يفضل استقبال القيم حتى لو كانت فارغة لتحديثها
    return {
      'FirstName': firstName ?? '',
      'LastName': lastName ?? '',
      'EmergencyContactName': emergencyContactName ?? '',
      'EmergencyContactPhone': emergencyContactPhone ?? '',
      'MedicalInfo': medicalInfo ?? '',
    };
  }
}