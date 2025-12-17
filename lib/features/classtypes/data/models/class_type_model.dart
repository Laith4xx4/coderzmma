class ClassTypeModel {
  final int id;
  final String name;
  final String description;
  final int durationMinutes;
  final int sessionsCount;

  ClassTypeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.durationMinutes,
    required this.sessionsCount,
  });

  factory ClassTypeModel.fromJson(Map<String, dynamic> json) {
    return ClassTypeModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      durationMinutes: json['durationMinutes'] as int,
      sessionsCount: json['sessionsCount'] as int,
    );
  }
}


