import 'package:thesavage/features/attendance/data/datasource/attendance_api_service.dart';
import 'package:thesavage/features/attendance/data/models/attendance_model.dart';
import 'package:thesavage/features/attendance/data/models/create_attendance_model.dart';
import 'package:thesavage/features/attendance/data/models/update_attendance_model.dart';
import 'package:thesavage/features/attendance/domain/entities/attendance_entity.dart';
import 'package:thesavage/features/attendance/domain/repositories/attendance_repository.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceApiService apiService;

  AttendanceRepositoryImpl(this.apiService);

  AttendanceEntity _mapModelToEntity(AttendanceModel m) {
    return AttendanceEntity(
      id: m.id,
      sessionId: m.sessionId,
      sessionName: m.sessionName,
      memberId: m.memberId,
      memberName: m.memberName,
      status: m.status,
    );
  }

  @override
  Future<List<AttendanceEntity>> getAllAttendances() async {
    final models = await apiService.getAllAttendances();
    return models.map(_mapModelToEntity).toList();
  }

  @override
  Future<AttendanceEntity> getAttendanceById(int id) async {
    final model = await apiService.getAttendanceById(id);
    return _mapModelToEntity(model);
  }

  @override
  Future<AttendanceEntity> createAttendance(CreateAttendanceModel data) async {
    final model = await apiService.createAttendance(data);
    return _mapModelToEntity(model);
  }

  @override
  Future<void> updateAttendance(int id, UpdateAttendanceModel data) async {
    await apiService.updateAttendance(id, data);
  }

  @override
  Future<void> deleteAttendance(int id) async {
    await apiService.deleteAttendance(id);
  }
}


