import 'package:thesavage/features/memberpro/domain/entities/member_profile_entity.dart';
import 'package:thesavage/features/memberpro/domain/repositories/member_repository.dart';


class DeleteMember {
  final MemberRepository repository;
  DeleteMember(this.repository);

  Future<void> call(int id) {
    return repository.deleteMember(id);
  }
}