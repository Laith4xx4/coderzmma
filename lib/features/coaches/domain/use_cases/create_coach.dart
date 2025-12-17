import 'package:maa3/features/coaches/data/models/create_coach_model.dart';
import 'package:maa3/features/coaches/domain/entities/coach_entity.dart';
import 'package:maa3/features/coaches/domain/repositories/coach_repository.dart';

class CreateCoach {
  final CoachRepository repository;

  CreateCoach(this.repository);

  Future<CoachEntity> call(CreateCoachModel data) {
    return repository.createCoach(data);
  }
}


