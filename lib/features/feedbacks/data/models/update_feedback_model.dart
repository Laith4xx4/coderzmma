class UpdateFeedbackModel {
  final double rating;
  final String? comments;

  UpdateFeedbackModel({
    required this.rating,
    this.comments,
  });

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'comments': comments,
    };
  }
}


