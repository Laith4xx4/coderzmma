import 'package:maa3/features/coaches/data/datasource/coach_api_service.dart';
import 'package:maa3/features/coaches/data/models/coach_model.dart';
import 'package:maa3/features/coaches/data/models/create_coach_model.dart';
import 'package:maa3/features/coaches/data/models/update_coach_model.dart';
import 'package:maa3/features/coaches/domain/entities/coach_entity.dart';
import 'package:maa3/features/coaches/domain/repositories/coach_repository.dart';

class CoachRepositoryImpl implements CoachRepository {
  final CoachApiService apiService;

  CoachRepositoryImpl(this.apiService);

  CoachEntity _mapModelToEntity(CoachModel m) {
    return CoachEntity(
      id: m.id,
      userId: m.userId,
      bio: m.bio,
      specialization: m.specialization,
      certifications: m.certifications,
      userName: m.userName,
      sessionsCount: m.sessionsCount,
      feedbacksCount: m.feedbacksCount,
    );
  }

  @override
  Future<List<CoachEntity>> getAllCoaches() async {
    final models = await apiService.getAllCoaches();
    return models.map(_mapModelToEntity).toList();
  }

  @override
  Future<CoachEntity> getCoachById(int id) async {
    final model = await apiService.getCoachById(id);
    return _mapModelToEntity(model);
  }

  @override
  Future<CoachEntity> createCoach(CreateCoachModel data) async {
    final model = await apiService.createCoach(data);
    return _mapModelToEntity(model);
  }

  @override
  Future<void> updateCoach(int id, UpdateCoachModel data) async {
    await apiService.updateCoach(id, data);
  }

  @override
  Future<void> deleteCoach(int id) async {
    await apiService.deleteCoach(id);
  }
}


