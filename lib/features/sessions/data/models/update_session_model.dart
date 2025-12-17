class UpdateSessionModel {
  final DateTime startTime;
  final DateTime endTime;
  final int capacity;
  final String? description;

  UpdateSessionModel({
    required this.startTime,
    required this.endTime,
    required this.capacity,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'capacity': capacity,
      'description': description,
    };
  }
}
