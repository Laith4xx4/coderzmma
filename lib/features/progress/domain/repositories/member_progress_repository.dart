import 'package:maa3/features/progress/data/models/create_member_progress_model.dart';
import 'package:maa3/features/progress/data/models/update_member_progress_model.dart';
import 'package:maa3/features/progress/domain/entities/member_progress_entity.dart';

abstract class MemberProgressRepository {
  Future<List<MemberProgressEntity>> getAllProgress();
  Future<MemberProgressEntity> getProgressById(int id);
  Future<MemberProgressEntity> createProgress(CreateMemberProgressModel data);
  Future<void> updateProgress(int id, UpdateMemberProgressModel data);
  Future<void> deleteProgress(int id);
}


