import 'package:thesavage/features/classtypes/data/models/update_class_type_model.dart';
import 'package:thesavage/features/classtypes/domain/repositories/class_type_repository.dart';

class UpdateClassType {
  final ClassTypeRepository repository;

  UpdateClassType(this.repository);

  Future<void> call(int id, UpdateClassTypeModel data) {
    return repository.updateClassType(id, data);
  }
}


