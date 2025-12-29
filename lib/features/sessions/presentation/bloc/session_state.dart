import 'package:equatable/equatable.dart';
import 'package:thesavage/features/sessions/domain/entities/session_entity.dart';

abstract class SessionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SessionInitial extends SessionState {}

class SessionLoading extends SessionState {}

class SessionsLoaded extends SessionState {
  final List<SessionEntity> sessions;

  SessionsLoaded(this.sessions);

  @override
  List<Object?> get props => [sessions];
}

class SessionOperationSuccess extends SessionState {
  final String message;

  SessionOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class SessionError extends SessionState {
  final String message;

  SessionError(this.message);

  @override
  List<Object?> get props => [message];
}


