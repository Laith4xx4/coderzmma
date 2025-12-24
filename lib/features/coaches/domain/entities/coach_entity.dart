class CoachEntity {
  final int id;
  final String userId;
  final String userName;

  // حقول اختيارية:
  final String? bio;
  final String? specialization;
  final String? certifications;

  final int sessionsCount;
  final int feedbacksCount;

  const CoachEntity({
    required this.id,
    required this.userId,
    required this.userName,
    this.bio,
    this.specialization,
    this.certifications,
    required this.sessionsCount,
    required this.feedbacksCount,
  });
}