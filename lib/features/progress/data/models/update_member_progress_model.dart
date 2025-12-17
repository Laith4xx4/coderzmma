class UpdateMemberProgressModel {
  final int setsCompleted;
  final DateTime? promotionDate;

  UpdateMemberProgressModel({
    required this.setsCompleted,
    this.promotionDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'setsCompleted': setsCompleted,
      'promotionDate': promotionDate?.toIso8601String(),
    };
  }
}


