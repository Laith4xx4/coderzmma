import 'package:thesavage/features/progress/domain/repositories/member_progress_repository.dart';

class DeleteProgress {
  final MemberProgressRepository repository;

  DeleteProgress(this.repository);

  Future<void> call(int id) {
    return repository.deleteProgress(id);
  }
}


