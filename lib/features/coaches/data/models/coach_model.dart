class CoachModel {
  final int id;
  final String userId;
  final String? bio;
  final String userName;
  final String? specialization;
  final String? certifications;
  final int sessionsCount;
  final int feedbacksCount;

  CoachModel({
    required this.id,
    required this.userId,
    this.bio,
    required this.userName,
    this.specialization,
    this.certifications,
    required this.sessionsCount,
    required this.feedbacksCount,
  });

  factory CoachModel.fromJson(Map<String, dynamic> json) {
    return CoachModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      userId: (json['userId'] ?? '').toString(),

      // يمكن أن تكون null → نجعلها String?
      bio: json['bio']?.toString(),

      // نقرأ userName أو username حسب ما يرجعه الـ API
      userName: (json['userName'] ?? json['username'] ?? '').toString(),

      specialization: json['specialization']?.toString(),
      certifications: json['certifications']?.toString(),

      sessionsCount: json['sessionsCount'] is int
          ? json['sessionsCount'] as int
          : int.tryParse(json['sessionsCount']?.toString() ?? '') ?? 0,
      feedbacksCount: json['feedbacksCount'] is int
          ? json['feedbacksCount'] as int
          : int.tryParse(json['feedbacksCount']?.toString() ?? '') ?? 0,
    );
  }
}