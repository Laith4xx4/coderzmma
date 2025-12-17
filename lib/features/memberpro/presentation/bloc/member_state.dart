
import 'package:equatable/equatable.dart';

import '../../domain/entities/member_profile_entity.dart';

abstract class MemberState extends Equatable {
  const MemberState();

  @override
  List<Object> get props => [];
}

class MemberInitial extends MemberState {}

class MemberLoading extends MemberState {}

class MembersLoaded extends MemberState {
  final List<MemberProfileEntity> members;

  const MembersLoaded(this.members);

  @override
  List<Object> get props => [members];
}

class MemberOperationSuccess extends MemberState {
  final String message;

  const MemberOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class MemberError extends MemberState {
  final String message;

  const MemberError(this.message);

  @override
  List<Object> get props => [message];
}