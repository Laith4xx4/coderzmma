import 'package:thesavage/features/sessions/domain/entities/session_entity.dart';
import 'package:thesavage/features/sessions/domain/repositories/session_repository.dart';

class GetSessionById {
  final SessionRepository repository;

  GetSessionById(this.repository);

  Future<SessionEntity> call(int id) {
    return repository.getSessionById(id);
  }
}


