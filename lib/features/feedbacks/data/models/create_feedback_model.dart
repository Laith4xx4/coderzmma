class CreateFeedbackModel {
  final int memberId;
  final int coachId;
  final int sessionId;
  final double rating;
  final String? comments;
  final DateTime timestamp;
  final String senderType; // 'Member' or 'Coach'

  CreateFeedbackModel({
    required this.memberId,
    required this.coachId,
    required this.sessionId,
    required this.rating,
    this.comments,
    required this.timestamp,
    required this.senderType,
  });

  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'coachId': coachId,
      'sessionId': sessionId,
      'rating': rating,
      'comments': comments,
      'timestamp': timestamp.toIso8601String(),
      'senderType': senderType,
    };
  }
}


