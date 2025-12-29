import 'package:thesavage/features/feedbacks/data/datasource/feedback_api_service.dart';
import 'package:thesavage/features/feedbacks/data/models/create_feedback_model.dart';
import 'package:thesavage/features/feedbacks/data/models/feedback_model.dart';
import 'package:thesavage/features/feedbacks/data/models/update_feedback_model.dart';
import 'package:thesavage/features/feedbacks/domain/entities/feedback_entity.dart';
import 'package:thesavage/features/feedbacks/domain/repositories/feedback_repository.dart';

class FeedbackRepositoryImpl implements FeedbackRepository {
  final FeedbackApiService apiService;

  FeedbackRepositoryImpl(this.apiService);

  FeedbackEntity _mapModelToEntity(FeedbackModel m) {
    return FeedbackEntity(
      id: m.id,
      memberId: m.memberId,
      memberName: m.memberName,
      coachId: m.coachId,
      coachName: m.coachName,
      sessionId: m.sessionId,
      sessionName: m.sessionName,
      rating: m.rating,
      comments: m.comments,
      timestamp: m.timestamp,
      senderType: m.senderType,
    );
  }

  @override
  Future<List<FeedbackEntity>> getAllFeedbacks() async {
    final models = await apiService.getAllFeedbacks();
    return models.map(_mapModelToEntity).toList();
  }

  @override
  Future<FeedbackEntity> getFeedbackById(int id) async {
    final model = await apiService.getFeedbackById(id);
    return _mapModelToEntity(model);
  }

  @override
  Future<FeedbackEntity> createFeedback(CreateFeedbackModel data) async {
    final model = await apiService.createFeedback(data);
    return _mapModelToEntity(model);
  }

  @override
  Future<void> updateFeedback(int id, UpdateFeedbackModel data) async {
    await apiService.updateFeedback(id, data);
  }

  @override
  Future<void> deleteFeedback(int id) async {
    await apiService.deleteFeedback(id);
  }
}


