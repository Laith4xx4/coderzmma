import 'package:maa3/features/progress/domain/entities/member_progress_entity.dart';
import 'package:maa3/features/progress/domain/repositories/member_progress_repository.dart';

class GetAllProgress {
  final MemberProgressRepository repository;

  GetAllProgress(this.repository);

  Future<List<MemberProgressEntity>> call() {
    return repository.getAllProgress();
  }
}


