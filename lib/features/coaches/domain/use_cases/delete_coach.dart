import 'package:maa3/features/coaches/domain/repositories/coach_repository.dart';

class DeleteCoach {
  final CoachRepository repository;

  DeleteCoach(this.repository);

  Future<void> call(int id) {
    return repository.deleteCoach(id);
  }
}


