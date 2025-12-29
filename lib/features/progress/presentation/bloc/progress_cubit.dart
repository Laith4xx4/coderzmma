import 'package:bloc/bloc.dart';
import 'package:thesavage/features/progress/data/models/create_member_progress_model.dart';
import 'package:thesavage/features/progress/data/models/update_member_progress_model.dart';
import 'package:thesavage/features/progress/domain/use_cases/create_progress.dart';
import 'package:thesavage/features/progress/domain/use_cases/delete_progress.dart';
import 'package:thesavage/features/progress/domain/use_cases/get_all_progress.dart';
import 'package:thesavage/features/progress/domain/use_cases/update_progress.dart';
import 'package:thesavage/features/progress/presentation/bloc/progress_state.dart';

class ProgressCubit extends Cubit<ProgressState> {
  final GetAllProgress getAllProgress;
  final CreateProgress createProgress;
  final UpdateProgress updateProgress;
  final DeleteProgress deleteProgress;

  ProgressCubit({
    required this.getAllProgress,
    required this.createProgress,
    required this.updateProgress,
    required this.deleteProgress,
  }) : super(ProgressInitial());

  Future<void> loadProgress() async {
    emit(ProgressLoading());
    try {
      final list = await getAllProgress.call();
      emit(ProgressLoaded(list));
    } catch (e) {
      emit(ProgressError(e.toString()));
    }
  }

  Future<void> createProgressAction(CreateMemberProgressModel data) async {
    emit(ProgressLoading());
    try {
      await createProgress.call(data);
      emit(ProgressOperationSuccess('Progress created successfully'));
      await loadProgress();
    } catch (e) {
      emit(ProgressError(e.toString()));
    }
  }

  Future<void> updateProgressAction(
      int id, UpdateMemberProgressModel data) async {
    emit(ProgressLoading());
    try {
      await updateProgress.call(id, data);
      emit(ProgressOperationSuccess('Progress updated successfully'));
      await loadProgress();
    } catch (e) {
      emit(ProgressError(e.toString()));
    }
  }

  Future<void> deleteProgressAction(int id) async {
    emit(ProgressLoading());
    try {
      await deleteProgress.call(id);
      emit(ProgressOperationSuccess('Progress deleted successfully'));
      await loadProgress();
    } catch (e) {
      emit(ProgressError(e.toString()));
    }
  }
}


