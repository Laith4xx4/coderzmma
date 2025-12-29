import 'package:bloc/bloc.dart';
import 'package:thesavage/features/coaches/data/models/create_coach_model.dart';
import 'package:thesavage/features/coaches/data/models/update_coach_model.dart';
import 'package:thesavage/features/coaches/domain/use_cases/create_coach.dart';
import 'package:thesavage/features/coaches/domain/use_cases/delete_coach.dart';
import 'package:thesavage/features/coaches/domain/use_cases/get_all_coaches.dart';
import 'package:thesavage/features/coaches/domain/use_cases/update_coach.dart';
import 'package:thesavage/features/coaches/presentation/bloc/coach_state.dart';

class CoachCubit extends Cubit<CoachState> {
  final GetAllCoaches getAllCoaches;
  final CreateCoach createCoach;
  final UpdateCoach updateCoach;
  final DeleteCoach deleteCoach;

  CoachCubit({
    required this.getAllCoaches,
    required this.createCoach,
    required this.updateCoach,
    required this.deleteCoach,
  }) : super(CoachInitial());

  Future<void> loadCoaches() async {
    emit(CoachLoading());
    try {
      final coaches = await getAllCoaches.call();
      emit(CoachesLoaded(coaches));
    } catch (e) {
      emit(CoachError(e.toString()));
    }
  }

  Future<void> createCoachAction(CreateCoachModel data) async {
    emit(CoachLoading());
    try {
      await createCoach.call(data);
      emit(CoachOperationSuccess('Coach created successfully'));
      await loadCoaches();
    } catch (e) {
      emit(CoachError(e.toString()));
    }
  }

  Future<void> updateCoachAction(int id, UpdateCoachModel data) async {
    emit(CoachLoading());
    try {
      await updateCoach.call(id, data);
      emit(CoachOperationSuccess('Coach updated successfully'));
      await loadCoaches();
    } catch (e) {
      emit(CoachError(e.toString()));
    }
  }

  Future<void> deleteCoachAction(int id) async {
    emit(CoachLoading());
    try {
      await deleteCoach.call(id);
      emit(CoachOperationSuccess('Coach deleted successfully'));
      await loadCoaches();
    } catch (e) {
      emit(CoachError(e.toString()));
    }
  }
}


