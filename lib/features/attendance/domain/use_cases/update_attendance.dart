import 'package:thesavage/features/attendance/data/models/update_attendance_model.dart';
import 'package:thesavage/features/attendance/domain/repositories/attendance_repository.dart';

class UpdateAttendance {
  final AttendanceRepository repository;

  UpdateAttendance(this.repository);

  Future<void> call(int id, UpdateAttendanceModel data) {
    return repository.updateAttendance(id, data);
  }
}


