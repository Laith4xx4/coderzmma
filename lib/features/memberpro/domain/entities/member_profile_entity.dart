import 'package:equatable/equatable.dart';

class MemberProfileEntity{
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

  const MemberProfileEntity({
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

}