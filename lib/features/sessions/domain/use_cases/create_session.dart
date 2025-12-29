import 'package:thesavage/features/sessions/data/models/create_session_model.dart';
import 'package:thesavage/features/sessions/domain/entities/session_entity.dart';
import 'package:thesavage/features/sessions/domain/repositories/session_repository.dart';

class CreateSession {
  final SessionRepository repository;

  CreateSession(this.repository);

  Future<SessionEntity> call(CreateSessionModel data) {
    return repository.createSession(data);
  }
}


