import 'package:maa3/features/memberpro/domain/entities/member_profile_entity.dart';
import 'package:maa3/features/memberpro/domain/repositories/member_repository.dart';


class GetMemberById {
  final MemberRepository repository;
  GetMemberById(this.repository);

  Future<MemberProfileEntity> call(int id) {
    return repository.getMemberById(id);
  }
}
