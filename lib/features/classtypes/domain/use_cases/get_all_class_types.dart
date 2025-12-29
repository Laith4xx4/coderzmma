import 'package:thesavage/features/classtypes/domain/entities/class_type_entity.dart';
import 'package:thesavage/features/classtypes/domain/repositories/class_type_repository.dart';

class GetAllClassTypes {
  final ClassTypeRepository repository;

  GetAllClassTypes(this.repository);

  Future<List<ClassTypeEntity>> call() {
    return repository.getAllClassTypes();
  }
}


