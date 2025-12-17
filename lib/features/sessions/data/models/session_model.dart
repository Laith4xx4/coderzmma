class SessionModel {
  final int id;
  final int coachId;
  final int classTypeId;
  final DateTime startTime;
  final DateTime endTime;
  final int capacity;
  final String? description;

  SessionModel({
    required this.id,
    required this.coachId,
    required this.classTypeId,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    this.description,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as int,
      coachId: json['coachId'] as int,
      classTypeId: json['classTypeId'] as int,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      capacity: json['capacity'] as int,
      description: json['description'] as String?,
    );
  }
}
