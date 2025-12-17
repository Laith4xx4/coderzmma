class CoachModel {
  final int id;
  final String userId;
  final String bio;
  final String specialization;
  final String? certifications;
  final String userName;
  final int sessionsCount;
  final int feedbacksCount;

  CoachModel({
    required this.id,
    required this.userId,
    required this.bio,
    required this.specialization,
    this.certifications,
    required this.userName,
    required this.sessionsCount,
    required this.feedbacksCount,
  });

  factory CoachModel.fromJson(Map<String, dynamic> json) {
    return CoachModel(
      id: json['id'] as int,
      userId: json['userId'] as String,
      bio: json['bio'] as String,
      specialization: json['specialization'] as String,
      certifications: json['certifications'] as String?,
      userName: json['userName'] as String,
      sessionsCount: json['sessionsCount'] as int,
      feedbacksCount: json['feedbacksCount'] as int,
    );
  }
}


