import '../entities/member_profile_entity.dart';
import '../../data/models/create_member_profile_model.dart';
import '../../data/models/update_member_profile_model.dart';

abstract class MemberRepository {
  Future<List<MemberProfileEntity>> getAllMembers();
  Future<MemberProfileEntity> getMemberById(int id);
  Future<MemberProfileEntity> createMember(CreateMemberProfileModel member);
  Future<void> updateMember(int id, UpdateMemberProfileModel member);
  Future<void> deleteMember(int id);
}