import 'package:thesavage/features/memberpro/domain/entities/member_profile_entity.dart';
import 'package:thesavage/features/memberpro/domain/repositories/member_repository.dart';

class GetAllMembers {
  final MemberRepository repository;
  GetAllMembers(this.repository);

  Future<List<MemberProfileEntity>> call() {
    return repository.getAllMembers();
  }
}
