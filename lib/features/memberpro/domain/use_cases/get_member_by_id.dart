import 'package:thesavage/features/memberpro/domain/entities/member_profile_entity.dart';
import 'package:thesavage/features/memberpro/domain/repositories/member_repository.dart';


class GetMemberById {
  final MemberRepository repository;
  GetMemberById(this.repository);

  Future<MemberProfileEntity> call(int id) {
    return repository.getMemberById(id);
  }
}
