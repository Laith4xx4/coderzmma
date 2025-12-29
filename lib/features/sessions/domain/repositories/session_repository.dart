import 'package:thesavage/features/sessions/domain/entities/session_entity.dart';
import 'package:thesavage/features/sessions/data/models/create_session_model.dart';
import 'package:thesavage/features/sessions/data/models/update_session_model.dart';

abstract class SessionRepository {
  Future<List<SessionEntity>> getAllSessions();
  Future<SessionEntity> getSessionById(int id);
  Future<SessionEntity> createSession(CreateSessionModel data);
  Future<void> updateSession(int id, UpdateSessionModel data);
  Future<void> deleteSession(int id);
}


