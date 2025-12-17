import 'package:maa3/features/memberpro/data/models/create_member_profile_model.dart';
import 'package:maa3/features/memberpro/domain/entities/member_profile_entity.dart';
import 'package:maa3/features/memberpro/domain/repositories/member_repository.dart';
class CreateMember {
  final MemberRepository repository;
  CreateMember(this.repository);

  Future<MemberProfileEntity> call(CreateMemberProfileModel memberData) {
    return repository.createMember(memberData);
  }
}