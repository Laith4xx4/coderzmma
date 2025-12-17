class MemberProgressModel {
  final int id;
  final int memberId;
  final String memberName;
  final DateTime date;
  final int setsCompleted;
  final DateTime? promotionDate;

  MemberProgressModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.date,
    required this.setsCompleted,
    this.promotionDate,
  });

  factory MemberProgressModel.fromJson(Map<String, dynamic> json) {
    return MemberProgressModel(
      id: json['id'] as int,
      memberId: json['memberId'] as int,
      memberName: json['memberName'] as String,
      date: DateTime.parse(json['date'] as String),
      setsCompleted: json['setsCompleted'] as int,
      promotionDate: json['promotionDate'] != null
          ? DateTime.parse(json['promotionDate'] as String)
          : null,
    );
  }
}
