import 'package:equatable/equatable.dart';
import 'package:thesavage/features/feedbacks/domain/entities/feedback_entity.dart';

abstract class FeedbackState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FeedbackInitial extends FeedbackState {}

class FeedbackLoading extends FeedbackState {}

class FeedbacksLoaded extends FeedbackState {
  final List<FeedbackEntity> feedbacks;

  FeedbacksLoaded(this.feedbacks);

  @override
  List<Object?> get props => [feedbacks];
}

class FeedbackError extends FeedbackState {
  final String message;

  FeedbackError(this.message);

  @override
  List<Object?> get props => [message];
}

class FeedbackOperationSuccess extends FeedbackState {
  final String message;

  FeedbackOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}


