import 'package:thesavage/features/classtypes/domain/repositories/class_type_repository.dart';

class DeleteClassType {
  final ClassTypeRepository repository;

  DeleteClassType(this.repository);

  Future<void> call(int id) {
    return repository.deleteClassType(id);
  }
}


