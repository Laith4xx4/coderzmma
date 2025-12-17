import 'package:maa3/features/feedbacks/domain/repositories/feedback_repository.dart';

class DeleteFeedback {
  final FeedbackRepository repository;

  DeleteFeedback(this.repository);

  Future<void> call(int id) {
    return repository.deleteFeedback(id);
  }
}


