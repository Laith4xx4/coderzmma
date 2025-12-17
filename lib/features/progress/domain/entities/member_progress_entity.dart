class MemberProgressEntity {
  final int id;
  final int memberId;
  final String memberName;
  final DateTime date;
  final int setsCompleted;
  final DateTime? promotionDate;

  MemberProgressEntity({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.date,
    required this.setsCompleted,
    this.promotionDate,
  });
}


