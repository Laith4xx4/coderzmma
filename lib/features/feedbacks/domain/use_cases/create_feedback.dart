import 'package:thesavage/features/feedbacks/data/models/create_feedback_model.dart';
import 'package:thesavage/features/feedbacks/domain/entities/feedback_entity.dart';
import 'package:thesavage/features/feedbacks/domain/repositories/feedback_repository.dart';

class CreateFeedback {
  final FeedbackRepository repository;

  CreateFeedback(this.repository);

  Future<FeedbackEntity> call(CreateFeedbackModel data) {
    return repository.createFeedback(data);
  }
}


