import 'package:maa3/features/progress/data/models/update_member_progress_model.dart';
import 'package:maa3/features/progress/domain/repositories/member_progress_repository.dart';

class UpdateProgress {
  final MemberProgressRepository repository;

  UpdateProgress(this.repository);

  Future<void> call(int id, UpdateMemberProgressModel data) {
    return repository.updateProgress(id, data);
  }
}


