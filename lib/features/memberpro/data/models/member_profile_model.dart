class MemberProfileModel {
  final int id;
  final String userId;
  final String userName;
  final String? firstName;
  final String? lastName;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? medicalInfo;
  final DateTime joinDate;
  final int bookingsCount;
  final int attendanceCount;
  final int feedbacksGivenCount;
  final int progressRecordsCount;

  MemberProfileModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.firstName,
    this.lastName,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.medicalInfo,
    required this.joinDate,
    required this.bookingsCount,
    required this.attendanceCount,
    required this.feedbacksGivenCount,
    required this.progressRecordsCount,
  });

  factory MemberProfileModel.fromJson(Map<String, dynamic> json) {
    return MemberProfileModel(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      emergencyContactName: json['emergencyContactName'],
      emergencyContactPhone: json['emergencyContactPhone'],
      medicalInfo: json['medicalInfo'],
      joinDate: DateTime.parse(json['joinDate']),
      bookingsCount: json['bookingsCount'],
      attendanceCount: json['attendanceCount'],
      feedbacksGivenCount: json['feedbacksGivenCount'],
      progressRecordsCount: json['progressRecordsCount'],
    );
  }
}