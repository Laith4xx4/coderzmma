import 'package:equatable/equatable.dart';
import 'package:thesavage/features/coaches/domain/entities/coach_entity.dart';

abstract class CoachState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CoachInitial extends CoachState {}

class CoachLoading extends CoachState {}

class CoachesLoaded extends CoachState {
  final List<CoachEntity> coaches;

  CoachesLoaded(this.coaches);

  @override
  List<Object?> get props => [coaches];
}

class CoachError extends CoachState {
  final String message;

  CoachError(this.message);

  @override
  List<Object?> get props => [message];
}

class CoachOperationSuccess extends CoachState {
  final String message;

  CoachOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}


