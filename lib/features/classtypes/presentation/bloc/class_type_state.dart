import 'package:equatable/equatable.dart';
import 'package:thesavage/features/classtypes/domain/entities/class_type_entity.dart';

abstract class ClassTypeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ClassTypeInitial extends ClassTypeState {}

class ClassTypeLoading extends ClassTypeState {}

class ClassTypesLoaded extends ClassTypeState {
  final List<ClassTypeEntity> classTypes;

  ClassTypesLoaded(this.classTypes);

  @override
  List<Object?> get props => [classTypes];
}

class ClassTypeError extends ClassTypeState {
  final String message;

  ClassTypeError(this.message);

  @override
  List<Object?> get props => [message];
}

class ClassTypeOperationSuccess extends ClassTypeState {
  final String message;

  ClassTypeOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}


