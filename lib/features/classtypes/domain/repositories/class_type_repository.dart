import 'package:thesavage/features/classtypes/data/models/create_class_type_model.dart';
import 'package:thesavage/features/classtypes/data/models/update_class_type_model.dart';
import 'package:thesavage/features/classtypes/domain/entities/class_type_entity.dart';

abstract class ClassTypeRepository {
  Future<List<ClassTypeEntity>> getAllClassTypes();
  Future<ClassTypeEntity> getClassTypeById(int id);
  Future<ClassTypeEntity> createClassType(CreateClassTypeModel data);
  Future<void> updateClassType(int id, UpdateClassTypeModel data);
  Future<void> deleteClassType(int id);
}


