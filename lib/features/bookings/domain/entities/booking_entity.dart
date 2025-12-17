class BookingEntity {
  final int id;
  final int sessionId;
  final String sessionName;
  final int memberId;
  final String memberName;
  final DateTime bookingTime;
  final String status;

  BookingEntity({
    required this.id,
    required this.sessionId,
    required this.sessionName,
    required this.memberId,
    required this.memberName,
    required this.bookingTime,
    required this.status,
  });
}


