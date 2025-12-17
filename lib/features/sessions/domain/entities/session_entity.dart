class SessionEntity {
  final int id;
  final int coachId;
  final int classTypeId;
  final DateTime startTime;
  final DateTime endTime;
  final int capacity;
  final String? description;

  SessionEntity({
    required this.id,
    required this.coachId,
    required this.classTypeId,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    this.description,
  });
}


