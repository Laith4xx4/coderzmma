import 'package:thesavage/features/attendance/data/models/create_attendance_model.dart';
import 'package:thesavage/features/attendance/domain/entities/attendance_entity.dart';
import 'package:thesavage/features/attendance/domain/repositories/attendance_repository.dart';

class CreateAttendance {
  final AttendanceRepository repository;

  CreateAttendance(this.repository);

  Future<AttendanceEntity> call(CreateAttendanceModel data) {
    return repository.createAttendance(data);
  }
}


