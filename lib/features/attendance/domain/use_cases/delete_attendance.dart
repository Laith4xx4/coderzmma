import 'package:thesavage/features/attendance/domain/repositories/attendance_repository.dart';

class DeleteAttendance {
  final AttendanceRepository repository;

  DeleteAttendance(this.repository);

  Future<void> call(int id) {
    return repository.deleteAttendance(id);
  }
}


