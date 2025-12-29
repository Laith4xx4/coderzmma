import 'package:thesavage/features/progress/data/datasource/member_progress_api_service.dart';
import 'package:thesavage/features/progress/data/models/create_member_progress_model.dart';
import 'package:thesavage/features/progress/data/models/member_progress_model.dart';
import 'package:thesavage/features/progress/data/models/update_member_progress_model.dart';
import 'package:thesavage/features/progress/domain/entities/member_progress_entity.dart';
import 'package:thesavage/features/progress/domain/repositories/member_progress_repository.dart';

class MemberProgressRepositoryImpl implements MemberProgressRepository {
  final MemberProgressApiService apiService;

  MemberProgressRepositoryImpl(this.apiService);

  MemberProgressEntity _mapModelToEntity(MemberProgressModel m) {
    return MemberProgressEntity(
      id: m.id,
      memberId: m.memberId,
      memberName: m.memberName,
      date: m.date,
      setsCompleted: m.setsCompleted,
      promotionDate: m.promotionDate,
    );
  }

  @override
  Future<List<MemberProgressEntity>> getAllProgress() async {
    final models = await apiService.getAllProgress();
    return models.map(_mapModelToEntity).toList();
  }

  @override
  Future<MemberProgressEntity> getProgressById(int id) async {
    final model = await apiService.getProgressById(id);
    return _mapModelToEntity(model);
  }

  @override
  Future<MemberProgressEntity> createProgress(
      CreateMemberProgressModel data) async {
    final model = await apiService.createProgress(data);
    return _mapModelToEntity(model);
  }

  @override
  Future<void> updateProgress(int id, UpdateMemberProgressModel data) async {
    await apiService.updateProgress(id, data);
  }

  @override
  Future<void> deleteProgress(int id) async {
    await apiService.deleteProgress(id);
  }
}


