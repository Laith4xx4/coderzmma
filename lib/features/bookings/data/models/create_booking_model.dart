class CreateBookingModel {
  final int sessionId;
  final int memberId;
  final DateTime bookingTime;
  final int status;

  CreateBookingModel({
    required this.sessionId,
    required this.memberId,
    required this.bookingTime,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'memberId': memberId,
      'bookingTime': bookingTime.toIso8601String(),
      'status': status,
    };
  }
}


