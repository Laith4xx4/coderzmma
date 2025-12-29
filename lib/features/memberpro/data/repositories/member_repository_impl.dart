import 'package:thesavage/features/memberpro/data/datasource/member_api_service.dart';
import 'package:thesavage/features/memberpro/domain/entities/member_profile_entity.dart';
import 'package:thesavage/features/memberpro/domain/repositories/member_repository.dart';

import '../models/create_member_profile_model.dart';
import '../models/update_member_profile_model.dart';
import '../models/member_profile_model.dart'; // تم استيراد المودل الرئيسي

class MemberRepositoryImpl implements MemberRepository {
  final MemberApiService apiService;

  MemberRepositoryImpl(this.apiService);

  @override
  Future<List<MemberProfileEntity>> getAllMembers() async {
    // 1. استدعاء خدمة API للحصول على نماذج البيانات (Models)
    final model = await apiService.getAllMembers();

    // 2. تحويل النماذج إلى كيانات (Entities) نظيفة
    return model.map(_mapModelToEntity).toList();
  }

  @override
  Future<MemberProfileEntity> getMemberById(int id) async {
    final memberModel = await apiService.getMemberById(id);
    return _mapModelToEntity(memberModel);
  }

  @override
  Future<MemberProfileEntity> createMember(CreateMemberProfileModel memberData) async {
    // الـ API يُرجع الـ MemberProfileModel الكامل بعد الإنشاء (مع الـ ID الجديد)
    final createdMemberModel = await apiService.createMember(memberData);
    // نقوم بتحويله إلى Entity قبل إعادته
    return _mapModelToEntity(createdMemberModel);
  }

  @override
  Future<void> updateMember(int id, UpdateMemberProfileModel memberData) async {
    // استدعاء خدمة API لتحديث العضو
    await apiService.updateMember(id, memberData);
  }

  @override
  Future<void> deleteMember(int id) async {
    // استدعاء خدمة API لحذف العضو
    await apiService.deleteMember(id);
  }

  /// دالة مساعدة لتحويل MemberProfileModel إلى MemberProfileEntity
  /// هذا يمنع تكرار الكود ويجعل عملية التحويل أكثر وضوحًا
  MemberProfileEntity _mapModelToEntity(MemberProfileModel model) {
    return MemberProfileEntity(
      id: model.id,
      userId: model.userId,
      userName: model.userName,
      firstName: model.firstName,
      lastName: model.lastName,
      emergencyContactName: model.emergencyContactName,
      emergencyContactPhone: model.emergencyContactPhone,
      medicalInfo: model.medicalInfo,
      joinDate: model.joinDate,
      bookingsCount: model.bookingsCount,
      attendanceCount: model.attendanceCount,
      feedbacksGivenCount: model.feedbacksGivenCount,
      progressRecordsCount: model.progressRecordsCount,
    );
  }
}