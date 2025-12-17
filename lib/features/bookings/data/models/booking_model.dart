class BookingModel {
  final int id;
  final int sessionId;
  final String sessionName;
  final int memberId;
  final String memberName;
  final DateTime bookingTime;
  final String status; // سيتم تخزين الـ enum كـ string

  BookingModel({
    required this.id,
    required this.sessionId,
    required this.sessionName,
    required this.memberId,
    required this.memberName,
    required this.bookingTime,
    required this.status,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as int,
      sessionId: json['sessionId'] as int,
      sessionName: json['sessionName'] as String,
      memberId: json['memberId'] as int,
      memberName: json['memberName'] as String,
      bookingTime: DateTime.parse(json['bookingTime'] as String),
      status: json['status'].toString(),
    );
  }
}


