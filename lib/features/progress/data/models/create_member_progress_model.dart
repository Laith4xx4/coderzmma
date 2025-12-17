class CreateMemberProgressModel {
  final int memberId;
  final DateTime date;
  final int setsCompleted;
  final DateTime? promotionDate;

  CreateMemberProgressModel({
    required this.memberId,
    required this.date,
    required this.setsCompleted,
    this.promotionDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'date': date.toIso8601String(),
      'setsCompleted': setsCompleted,
      'promotionDate': promotionDate?.toIso8601String(),
    };
  }
}


