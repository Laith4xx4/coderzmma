class AttendanceEntity {
  final int id;
  final int sessionId;
  final String sessionName;
  final int memberId;
  final String memberName;
  final String status;

  AttendanceEntity({
    required this.id,
    required this.sessionId,
    required this.sessionName,
    required this.memberId,
    required this.memberName,
    required this.status,
  });
}


