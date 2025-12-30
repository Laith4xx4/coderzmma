import 'package:thesavage/features/bookings/data/models/booking_model.dart';

class SessionModel {
  final int id;
  final int coachId;
  final String coachName;
  final int classTypeId;
  final String classTypeName;
  final DateTime startTime;
  final DateTime endTime;
  final int capacity;
  final String? description;
  final String sessionName;
  final int bookingsCount;
  final int attendanceCount;
  final List<BookingModel> bookings; // جديد

  SessionModel({
    required this.id,
    required this.coachId,
    required this.coachName,
    required this.classTypeId,
    required this.classTypeName,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    this.description,
    required this.sessionName,
    required this.bookingsCount,
    required this.attendanceCount,
    this.bookings = const [], // جديد
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as int,
      coachId: json['coachId'] as int,
      coachName: json['coachName'] as String? ?? '',
      classTypeId: json['classTypeId'] as int,
      classTypeName: json['classTypeName'] as String? ?? '',
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      capacity: json['capacity'] as int,
      description: json['description'] as String?,
      sessionName: json['sessionName'] as String? ?? '',
      bookingsCount: json['bookingsCount'] as int? ?? 0,
      attendanceCount: json['attendanceCount'] as int? ?? 0,
      bookings: (json['bookings'] as List?)
              ?.map((e) => BookingModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
