import 'package:maa3/features/memberpro/data/models/update_member_profile_model.dart';
import 'package:maa3/features/memberpro/domain/entities/member_profile_entity.dart';
import 'package:maa3/features/memberpro/domain/repositories/member_repository.dart';


class UpdateMember {
  final MemberRepository repository;
  UpdateMember(this.repository);

  Future<void> call(int id, UpdateMemberProfileModel memberData) {
    return repository.updateMember(id, memberData);
  }
}