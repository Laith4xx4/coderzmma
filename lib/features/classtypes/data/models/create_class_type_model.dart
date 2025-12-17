class CreateClassTypeModel {
  final String name;
  final String description;
  final int durationMinutes;

  CreateClassTypeModel({
    required this.name,
    required this.description,
    required this.durationMinutes,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'durationMinutes': durationMinutes,
    };
  }
}


