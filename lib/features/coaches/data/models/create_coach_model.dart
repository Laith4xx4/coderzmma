class CreateCoachModel {
  final String userName; // صار يمثل المستخدم
  final String bio;
  final String specialization;
  final String? certifications;

  CreateCoachModel({
    required this.userName, // أصبح إلزاميًا
    required this.bio,
    required this.specialization,
    this.certifications,
  });

  Map<String, dynamic> toJson() {
    return {
      'UserName': userName, // مطابق للـ DTO الجديد
      'Bio': bio,
      'Specialization': specialization,
      if (certifications != null) 'Certifications': certifications,
    };
  }
}
