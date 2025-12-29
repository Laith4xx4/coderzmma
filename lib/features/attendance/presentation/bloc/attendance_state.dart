import 'package:equatable/equatable.dart';
import 'package:thesavage/features/attendance/domain/entities/attendance_entity.dart';

abstract class AttendanceState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendancesLoaded extends AttendanceState {
  final List<AttendanceEntity> attendances;

  AttendancesLoaded(this.attendances);

  @override
  List<Object?> get props => [attendances];
}

class AttendanceError extends AttendanceState {
  final String message;

  AttendanceError(this.message);

  @override
  List<Object?> get props => [message];
}

class AttendanceOperationSuccess extends AttendanceState {
  final String message;

  AttendanceOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}


