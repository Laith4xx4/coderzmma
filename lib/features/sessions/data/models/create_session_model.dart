class CreateSessionModel {
  final int coachId;
  final int classTypeId;
  final DateTime startTime;
  final DateTime endTime;
  final int capacity;
  final String? description;
  final String sessionName;   // جديد

  CreateSessionModel({
    required this.coachId,
    required this.classTypeId,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    this.description,
    required this.sessionName,
  });

  Map<String, dynamic> toJson() {
    return {
      'coachId': coachId,
      'classTypeId': classTypeId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'capacity': capacity,
      'description': description,
      'sessionName': sessionName,
    };
  }
}
