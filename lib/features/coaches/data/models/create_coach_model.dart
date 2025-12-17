class CreateCoachModel {
  final String userId;
  final String bio;
  final String specialization;
  final String? certifications;

  CreateCoachModel({
    required this.userId,
    required this.bio,
    required this.specialization,
    this.certifications,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'bio': bio,
      'specialization': specialization,
      'certifications': certifications,
    };
  }
}


