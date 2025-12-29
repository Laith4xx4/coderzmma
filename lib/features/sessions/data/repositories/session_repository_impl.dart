import 'package:thesavage/features/sessions/data/datasource/session_api_service.dart';
import 'package:thesavage/features/sessions/data/models/session_model.dart';
import 'package:thesavage/features/sessions/data/models/create_session_model.dart';
import 'package:thesavage/features/sessions/data/models/update_session_model.dart';
import 'package:thesavage/features/sessions/domain/entities/session_entity.dart';
import 'package:thesavage/features/sessions/domain/repositories/session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  final SessionApiService apiService;

  SessionRepositoryImpl(this.apiService);

  SessionEntity _mapModelToEntity(SessionModel m) {
    return SessionEntity(
      id: m.id,
      coachId: m.coachId,
      coachName: m.coachName ?? '',
      classTypeId: m.classTypeId,
      classTypeName: m.classTypeName ?? '',
      startTime: m.startTime,
      endTime: m.endTime,
      capacity: m.capacity,
      description: m.description,
      sessionName: m.sessionName ?? '',
      bookingsCount: m.bookingsCount ?? 0,
      attendanceCount: m.attendanceCount ?? 0,
    );
  }

  @override
  Future<List<SessionEntity>> getAllSessions() async {
    final List<SessionModel> models = await apiService.getAllSessions();
    return models.map(_mapModelToEntity).toList();
  }

  @override
  Future<SessionEntity> getSessionById(int id) async {
    final model = await apiService.getSessionById(id);
    return _mapModelToEntity(model);
  }

  @override
  Future<SessionEntity> createSession(CreateSessionModel data) async {
    final model = await apiService.createSession(data);
    return _mapModelToEntity(model);
  }

  @override
  Future<void> updateSession(int id, UpdateSessionModel data) async {
    await apiService.updateSession(id, data);
  }

  @override
  Future<void> deleteSession(int id) async {
    await apiService.deleteSession(id);
  }
}
