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
  final String senderType;

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
    required this.senderType,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'] as int? ?? 0,
      memberId: json['memberId'] as int? ?? 0,
      memberName: json['memberName'] as String? ?? 'Unknown Member',
      coachId: json['coachId'] as int? ?? 0,
      coachName: json['coachName'] as String? ?? 'Unknown Coach',
      sessionId: json['sessionId'] as int? ?? 0,
      sessionName: json['sessionName'] as String? ?? 'Unknown Session',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      comments: json['comments'] as String?,
      timestamp: json['timestamp'] == null 
          ? DateTime.now() 
          : DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now(),
      senderType: json['senderType'] as String? ?? 'Member', // Default to Member if missing
    );
  }
}


