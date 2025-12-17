class CreateAttendanceModel {
  final int sessionId;
  final int memberId;
  final int status;

  CreateAttendanceModel({
    required this.sessionId,
    required this.memberId,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'memberId': memberId,
      'status': status,
    };
  }
}


