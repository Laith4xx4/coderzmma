import 'package:maa3/features/coaches/domain/entities/coach_entity.dart';
import 'package:maa3/features/coaches/domain/repositories/coach_repository.dart';

class GetAllCoaches {
  final CoachRepository repository;

  GetAllCoaches(this.repository);

  Future<List<CoachEntity>> call() {
    return repository.getAllCoaches();
  }
}


