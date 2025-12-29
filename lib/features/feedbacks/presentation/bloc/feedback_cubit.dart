import 'package:bloc/bloc.dart';
import 'package:thesavage/features/feedbacks/data/models/create_feedback_model.dart';
import 'package:thesavage/features/feedbacks/data/models/update_feedback_model.dart';
import 'package:thesavage/features/feedbacks/domain/use_cases/create_feedback.dart';
import 'package:thesavage/features/feedbacks/domain/use_cases/delete_feedback.dart';
import 'package:thesavage/features/feedbacks/domain/use_cases/get_all_feedbacks.dart';
import 'package:thesavage/features/feedbacks/domain/use_cases/update_feedback.dart';
import 'package:thesavage/features/feedbacks/presentation/bloc/feedback_state.dart';

class FeedbackCubit extends Cubit<FeedbackState> {
  final GetAllFeedbacks getAllFeedbacks;
  final CreateFeedback createFeedback;
  final UpdateFeedback updateFeedback;
  final DeleteFeedback deleteFeedback;

  FeedbackCubit({
    required this.getAllFeedbacks,
    required this.createFeedback,
    required this.updateFeedback,
    required this.deleteFeedback,
  }) : super(FeedbackInitial());

  Future<void> loadFeedbacks() async {
    emit(FeedbackLoading());
    try {
      final list = await getAllFeedbacks.call();
      emit(FeedbacksLoaded(list));
    } catch (e) {
      emit(FeedbackError(e.toString()));
    }
  }

  Future<void> createFeedbackAction(CreateFeedbackModel data) async {
    emit(FeedbackLoading());
    try {
      await createFeedback.call(data);
      emit(FeedbackOperationSuccess('Feedback created successfully'));
      await loadFeedbacks();
    } catch (e) {
      emit(FeedbackError(e.toString()));
    }
  }

  Future<void> updateFeedbackAction(int id, UpdateFeedbackModel data) async {
    emit(FeedbackLoading());
    try {
      await updateFeedback.call(id, data);
      emit(FeedbackOperationSuccess('Feedback updated successfully'));
      await loadFeedbacks();
    } catch (e) {
      emit(FeedbackError(e.toString()));
    }
  }

  Future<void> deleteFeedbackAction(int id) async {
    emit(FeedbackLoading());
    try {
      await deleteFeedback.call(id);
      emit(FeedbackOperationSuccess('Feedback deleted successfully'));
      await loadFeedbacks();
    } catch (e) {
      emit(FeedbackError(e.toString()));
    }
  }
}


