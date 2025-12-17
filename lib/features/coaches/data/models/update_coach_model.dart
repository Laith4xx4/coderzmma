class UpdateCoachModel {
  final String bio;
  final String specialization;
  final String? certifications;

  UpdateCoachModel({
    required this.bio,
    required this.specialization,
    this.certifications,
  });

  Map<String, dynamic> toJson() {
    return {
      'bio': bio,
      'specialization': specialization,
      'certifications': certifications,
    };
  }
}


