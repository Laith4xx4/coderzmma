class UpdateSessionModel {
  final DateTime? startTime;
  final DateTime? endTime;
  final int? capacity;
  final String? description;
  final String? sessionName;   // جديد

  UpdateSessionModel({
    this.startTime,
    this.endTime,
    this.capacity,
    this.description,
    this.sessionName,
  });

  Map<String, dynamic> toJson() {
    return {
      if (startTime != null) 'startTime': startTime!.toIso8601String(),
      if (endTime != null) 'endTime': endTime!.toIso8601String(),
      if (capacity != null) 'capacity': capacity,
      if (description != null) 'description': description,
      if (sessionName != null) 'sessionName': sessionName,
    };
  }
}
