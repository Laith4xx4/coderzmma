import 'package:bloc/bloc.dart';
import 'package:thesavage/features/attendance/data/models/create_attendance_model.dart';
import 'package:thesavage/features/attendance/data/models/update_attendance_model.dart';
import 'package:thesavage/features/attendance/domain/use_cases/create_attendance.dart';
import 'package:thesavage/features/attendance/domain/use_cases/delete_attendance.dart';
import 'package:thesavage/features/attendance/domain/use_cases/get_all_attendances.dart';
import 'package:thesavage/features/attendance/domain/use_cases/update_attendance.dart';
import 'package:thesavage/features/attendance/presentation/bloc/attendance_state.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  final GetAllAttendances getAllAttendances;
  final CreateAttendance createAttendance;
  final UpdateAttendance updateAttendance;
  final DeleteAttendance deleteAttendance;

  AttendanceCubit({
    required this.getAllAttendances,
    required this.createAttendance,
    required this.updateAttendance,
    required this.deleteAttendance,
  }) : super(AttendanceInitial());

  Future<void> loadAttendances() async {
    emit(AttendanceLoading());
    try {
      final attendances = await getAllAttendances.call();
      emit(AttendancesLoaded(attendances));
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

  Future<void> createAttendanceAction(CreateAttendanceModel data) async {
    emit(AttendanceLoading());
    try {
      await createAttendance.call(data);
      emit(AttendanceOperationSuccess('Attendance created successfully'));
      await loadAttendances();
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

  Future<void> updateAttendanceAction(int id, UpdateAttendanceModel data) async {
    emit(AttendanceLoading());
    try {
      await updateAttendance.call(id, data);
      emit(AttendanceOperationSuccess('Attendance updated successfully'));
      await loadAttendances();
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

  Future<void> deleteAttendanceAction(int id) async {
    emit(AttendanceLoading());
    try {
      await deleteAttendance.call(id);
      emit(AttendanceOperationSuccess('Attendance deleted successfully'));
      await loadAttendances();
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }
}


