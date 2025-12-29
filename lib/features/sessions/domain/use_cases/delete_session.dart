import 'package:thesavage/features/sessions/domain/repositories/session_repository.dart';

class DeleteSession {
  final SessionRepository repository;

  DeleteSession(this.repository);

  Future<void> call(int id) {
    return repository.deleteSession(id);
  }
}
