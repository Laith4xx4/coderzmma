class CoachEntity {
  final int id;
  final String userId;
  final String bio;
  final String specialization;
  final String? certifications;
  final String userName;
  final int sessionsCount;
  final int feedbacksCount;

  CoachEntity({
    required this.id,
    required this.userId,
    required this.bio,
    required this.specialization,
    this.certifications,
    required this.userName,
    required this.sessionsCount,
    required this.feedbacksCount,
  });
}


