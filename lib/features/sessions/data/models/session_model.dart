class SessionModel {
  final int id;
  final int coachId;
  final String coachName;       // جديد
  final int classTypeId;
  final String classTypeName;   // جديد
  final DateTime startTime;
  final DateTime endTime;
  final int capacity;
  final String? description;
  final String sessionName;     // جديد
  final int bookingsCount;      // جديد
  final int attendanceCount;    // جديد

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
    );
  }
}
