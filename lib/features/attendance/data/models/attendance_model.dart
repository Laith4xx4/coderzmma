class AttendanceModel {
  final int id;
  final int sessionId;
  final String sessionName;
  final int memberId;
  final String memberName;
  final String status;

  AttendanceModel({
    required this.id,
    required this.sessionId,
    required this.sessionName,
    required this.memberId,
    required this.memberName,
    required this.status,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as int,
      sessionId: json['sessionId'] as int,
      sessionName: json['sessionName'] as String,
      memberId: json['memberId'] as int,
      memberName: json['memberName'] as String,
      status: json['status'].toString(),
    );
  }
}


