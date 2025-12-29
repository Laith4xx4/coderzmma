import 'package:thesavage/features/feedbacks/domain/entities/feedback_entity.dart';
import 'package:thesavage/features/feedbacks/domain/repositories/feedback_repository.dart';

class GetAllFeedbacks {
  final FeedbackRepository repository;

  GetAllFeedbacks(this.repository);

  Future<List<FeedbackEntity>> call() {
    return repository.getAllFeedbacks();
  }
}


