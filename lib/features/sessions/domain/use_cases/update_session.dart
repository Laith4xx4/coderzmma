import 'package:thesavage/features/sessions/data/models/update_session_model.dart';
import 'package:thesavage/features/sessions/domain/repositories/session_repository.dart';

class UpdateSession {
  final SessionRepository repository;

  UpdateSession(this.repository);

  Future<void> call(int id, UpdateSessionModel data) {
    return repository.updateSession(id, data);
  }
}


