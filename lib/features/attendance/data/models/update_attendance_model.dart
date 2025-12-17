class UpdateAttendanceModel {
  final int status;

  UpdateAttendanceModel({required this.status});

  Map<String, dynamic> toJson() {
    return {
      'status': status,
    };
  }
}


