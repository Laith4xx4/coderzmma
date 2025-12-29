import 'package:thesavage/features/sessions/domain/entities/session_entity.dart';
import 'package:thesavage/features/sessions/domain/repositories/session_repository.dart';

class GetAllSessions {
  final SessionRepository repository;

  GetAllSessions(this.repository);

  Future<List<SessionEntity>> call() {
    return repository.getAllSessions();
  }
}
