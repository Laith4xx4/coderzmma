class FeedbackModel {
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

  FeedbackModel({
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
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'] as int,
      memberId: json['memberId'] as int,
      memberName: json['memberName'] as String,
      coachId: json['coachId'] as int,
      coachName: json['coachName'] as String,
      sessionId: json['sessionId'] as int,
      sessionName: json['sessionName'] as String,
      rating: (json['rating'] as num).toDouble(),
      comments: json['comments'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}


