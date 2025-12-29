import 'package:thesavage/features/classtypes/data/datasource/class_type_api_service.dart';
import 'package:thesavage/features/classtypes/data/models/class_type_model.dart';
import 'package:thesavage/features/classtypes/data/models/create_class_type_model.dart';
import 'package:thesavage/features/classtypes/data/models/update_class_type_model.dart';
import 'package:thesavage/features/classtypes/domain/entities/class_type_entity.dart';
import 'package:thesavage/features/classtypes/domain/repositories/class_type_repository.dart';

class ClassTypeRepositoryImpl implements ClassTypeRepository {
  final ClassTypeApiService apiService;

  ClassTypeRepositoryImpl(this.apiService);

  ClassTypeEntity _mapModelToEntity(ClassTypeModel m) {
    return ClassTypeEntity(
      id: m.id,
      name: m.name,
      description: m.description,
      durationMinutes: m.durationMinutes,
      sessionsCount: m.sessionsCount,
    );
  }

  @override
  Future<List<ClassTypeEntity>> getAllClassTypes() async {
    final models = await apiService.getAllClassTypes();
    return models.map(_mapModelToEntity).toList();
  }

  @override
  Future<ClassTypeEntity> getClassTypeById(int id) async {
    final model = await apiService.getClassTypeById(id);
    return _mapModelToEntity(model);
  }

  @override
  Future<ClassTypeEntity> createClassType(CreateClassTypeModel data) async {
    final model = await apiService.createClassType(data);
    return _mapModelToEntity(model);
  }

  @override
  Future<void> updateClassType(int id, UpdateClassTypeModel data) async {
    await apiService.updateClassType(id, data);
  }

  @override
  Future<void> deleteClassType(int id) async {
    await apiService.deleteClassType(id);
  }
}


