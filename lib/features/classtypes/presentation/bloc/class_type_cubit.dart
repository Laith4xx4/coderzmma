import 'package:bloc/bloc.dart';
import 'package:thesavage/features/classtypes/data/models/create_class_type_model.dart';
import 'package:thesavage/features/classtypes/data/models/update_class_type_model.dart';
import 'package:thesavage/features/classtypes/domain/use_cases/create_class_type.dart';
import 'package:thesavage/features/classtypes/domain/use_cases/delete_class_type.dart';
import 'package:thesavage/features/classtypes/domain/use_cases/get_all_class_types.dart';
import 'package:thesavage/features/classtypes/domain/use_cases/update_class_type.dart';
import 'package:thesavage/features/classtypes/presentation/bloc/class_type_state.dart';

class ClassTypeCubit extends Cubit<ClassTypeState> {
  final GetAllClassTypes getAllClassTypes;
  final CreateClassType createClassType;
  final UpdateClassType updateClassType;
  final DeleteClassType deleteClassType;

  ClassTypeCubit({
    required this.getAllClassTypes,
    required this.createClassType,
    required this.updateClassType,
    required this.deleteClassType,
  }) : super(ClassTypeInitial());

  Future<void> loadClassTypes() async {
    emit(ClassTypeLoading());
    try {
      final list = await getAllClassTypes.call();
      emit(ClassTypesLoaded(list));
    } catch (e) {
      emit(ClassTypeError(e.toString()));
    }
  }

  Future<void> createClassTypeAction(CreateClassTypeModel data) async {
    emit(ClassTypeLoading());
    try {
      await createClassType.call(data);
      emit(ClassTypeOperationSuccess('Class type created successfully'));
      await loadClassTypes();
    } catch (e) {
      emit(ClassTypeError(e.toString()));
    }
  }

  Future<void> updateClassTypeAction(int id, UpdateClassTypeModel data) async {
    emit(ClassTypeLoading());
    try {
      await updateClassType.call(id, data);
      emit(ClassTypeOperationSuccess('Class type updated successfully'));
      await loadClassTypes();
    } catch (e) {
      emit(ClassTypeError(e.toString()));
    }
  }

  Future<void> deleteClassTypeAction(int id) async {
    emit(ClassTypeLoading());
    try {
      await deleteClassType.call(id);
      emit(ClassTypeOperationSuccess('Class type deleted successfully'));
      await loadClassTypes();
    } catch (e) {
      emit(ClassTypeError(e.toString()));
    }
  }
}


