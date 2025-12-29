import 'package:thesavage/features/attendance/domain/entities/attendance_entity.dart';
import 'package:thesavage/features/attendance/domain/repositories/attendance_repository.dart';

class GetAllAttendances {
  final AttendanceRepository repository;

  GetAllAttendances(this.repository);

  Future<List<AttendanceEntity>> call() {
    return repository.getAllAttendances();
  }
}


