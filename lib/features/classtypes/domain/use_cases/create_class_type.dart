import 'package:maa3/features/classtypes/data/models/create_class_type_model.dart';
import 'package:maa3/features/classtypes/domain/entities/class_type_entity.dart';
import 'package:maa3/features/classtypes/domain/repositories/class_type_repository.dart';

class CreateClassType {
  final ClassTypeRepository repository;

  CreateClassType(this.repository);

  Future<ClassTypeEntity> call(CreateClassTypeModel data) {
    return repository.createClassType(data);
  }
}


