import 'package:thesavage/features/coaches/domain/repositories/coach_repository.dart';

class DeleteCoach {
  final CoachRepository repository;

  DeleteCoach(this.repository);

  Future<void> call(int id) {
    return repository.deleteCoach(id);
  }
}


