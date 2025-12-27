class FeedbackEntity {
  final int id;
  final int memberId;
  final String memberName;
  final int coachId;
  final String coachName;
  final int sessionId;
  final String sessionName;
  final double rating;
  final String? comments;
  final DateTime timestamp;
  final String senderType;

  FeedbackEntity({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.coachId,
    required this.coachName,
    required this.sessionId,
    required this.sessionName,
    required this.rating,
    this.comments,
    required this.timestamp,
    required this.senderType,
  });
}


