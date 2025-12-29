import 'package:thesavage/features/attendance/data/models/create_attendance_model.dart';
import 'package:thesavage/features/attendance/data/models/update_attendance_model.dart';
import 'package:thesavage/features/attendance/domain/entities/attendance_entity.dart';

abstract class AttendanceRepository {
  Future<List<AttendanceEntity>> getAllAttendances();
  Future<AttendanceEntity> getAttendanceById(int id);
  Future<AttendanceEntity> createAttendance(CreateAttendanceModel data);
  Future<void> updateAttendance(int id, UpdateAttendanceModel data);
  Future<void> deleteAttendance(int id);
}


