import 'package:maa3/features/feedbacks/data/models/update_feedback_model.dart';
import 'package:maa3/features/feedbacks/domain/repositories/feedback_repository.dart';

class UpdateFeedback {
  final FeedbackRepository repository;

  UpdateFeedback(this.repository);

  Future<void> call(int id, UpdateFeedbackModel data) {
    return repository.updateFeedback(id, data);
  }
}


