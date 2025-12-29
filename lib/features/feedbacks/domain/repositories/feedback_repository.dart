import 'package:thesavage/features/feedbacks/data/models/create_feedback_model.dart';
import 'package:thesavage/features/feedbacks/data/models/update_feedback_model.dart';
import 'package:thesavage/features/feedbacks/domain/entities/feedback_entity.dart';

abstract class FeedbackRepository {
  Future<List<FeedbackEntity>> getAllFeedbacks();
  Future<FeedbackEntity> getFeedbackById(int id);
  Future<FeedbackEntity> createFeedback(CreateFeedbackModel data);
  Future<void> updateFeedback(int id, UpdateFeedbackModel data);
  Future<void> deleteFeedback(int id);
}


