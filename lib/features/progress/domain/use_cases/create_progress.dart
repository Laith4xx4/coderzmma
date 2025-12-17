import 'package:maa3/features/progress/data/models/create_member_progress_model.dart';
import 'package:maa3/features/progress/domain/entities/member_progress_entity.dart';
import 'package:maa3/features/progress/domain/repositories/member_progress_repository.dart';

class CreateProgress {
  final MemberProgressRepository repository;

  CreateProgress(this.repository);

  Future<MemberProgressEntity> call(CreateMemberProgressModel data) {
    return repository.createProgress(data);
  }
}


