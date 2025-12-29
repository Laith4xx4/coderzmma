import 'package:thesavage/features/coaches/data/models/create_coach_model.dart';
import 'package:thesavage/features/coaches/data/models/update_coach_model.dart';
import 'package:thesavage/features/coaches/domain/entities/coach_entity.dart';

abstract class CoachRepository {
  Future<List<CoachEntity>> getAllCoaches();
  Future<CoachEntity> getCoachById(int id);
  Future<CoachEntity> createCoach(CreateCoachModel data);
  Future<void> updateCoach(int id, UpdateCoachModel data);
  Future<void> deleteCoach(int id);
}


