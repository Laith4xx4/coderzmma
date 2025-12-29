import 'package:thesavage/features/coaches/data/models/update_coach_model.dart';
import 'package:thesavage/features/coaches/domain/repositories/coach_repository.dart';

class UpdateCoach {
  final CoachRepository repository;

  UpdateCoach(this.repository);

  Future<void> call(int id, UpdateCoachModel data) {
    return repository.updateCoach(id, data);
  }
}


