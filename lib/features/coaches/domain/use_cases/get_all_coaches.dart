import 'package:thesavage/features/coaches/domain/entities/coach_entity.dart';
import 'package:thesavage/features/coaches/domain/repositories/coach_repository.dart';

class GetAllCoaches {
  final CoachRepository repository;

  GetAllCoaches(this.repository);

  Future<List<CoachEntity>> call() {
    return repository.getAllCoaches();
  }
}


