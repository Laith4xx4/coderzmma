import 'package:equatable/equatable.dart';
import 'package:thesavage/features/progress/domain/entities/member_progress_entity.dart';

abstract class ProgressState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProgressInitial extends ProgressState {}

class ProgressLoading extends ProgressState {}

class ProgressLoaded extends ProgressState {
  final List<MemberProgressEntity> items;

  ProgressLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

class ProgressError extends ProgressState {
  final String message;

  ProgressError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProgressOperationSuccess extends ProgressState {
  final String message;

  ProgressOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}


