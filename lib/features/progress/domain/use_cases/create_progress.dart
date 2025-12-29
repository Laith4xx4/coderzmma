import 'package:thesavage/features/progress/data/models/create_member_progress_model.dart';
import 'package:thesavage/features/progress/domain/entities/member_progress_entity.dart';
import 'package:thesavage/features/progress/domain/repositories/member_progress_repository.dart';

class CreateProgress {
  final MemberProgressRepository repository;

  CreateProgress(this.repository);

  Future<MemberProgressEntity> call(CreateMemberProgressModel data) {
    return repository.createProgress(data);
  }
}


