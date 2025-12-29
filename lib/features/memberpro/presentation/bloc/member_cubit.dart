import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
// لم نعد بحاجة لاستيراد flutter_bloc هنا
// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thesavage/features/memberpro/data/models/create_member_profile_model.dart';
import 'package:thesavage/features/memberpro/data/models/update_member_profile_model.dart';
import 'package:thesavage/features/memberpro/domain/entities/member_profile_entity.dart';
import 'package:thesavage/features/memberpro/domain/use_cases/create_member.dart';
import 'package:thesavage/features/memberpro/domain/use_cases/delete_member.dart';
import 'package:thesavage/features/memberpro/domain/use_cases/get_all_members.dart';
import 'package:thesavage/features/memberpro/domain/use_cases/update_member.dart';
import 'package:thesavage/features/memberpro/presentation/bloc/member_state.dart';

class MemberCubit extends Cubit<MemberState> {
  final GetAllMembers getAllMembers;
  final CreateMember createMember;
  final UpdateMember updateMember;
  final DeleteMember deleteMember;

  MemberCubit({
    required this.getAllMembers,
    required this.createMember,
    required this.updateMember,
    required this.deleteMember,
  }) : super(MemberInitial());

  Future<void> loadMembers() async {
    emit(MemberLoading());
    try {
      final members = await getAllMembers.call(); // استخدم call()
      emit(MembersLoaded(members));
    } catch (e) {
      emit(MemberError(e.toString()));
    }
  }

  Future<void> createMemberAction(CreateMemberProfileModel memberData) async {
    emit(MemberLoading());
    try {
      await createMember.call(memberData); // استخدم call()
      emit(const MemberOperationSuccess('Member created successfully'));
      await loadMembers(); // إعادة تحميل القائمة بعد الإنشاء
    } catch (e) {
      emit(MemberError(e.toString()));
    }
  }

  Future<void> updateMemberAction(int id, UpdateMemberProfileModel memberData) async {
    emit(MemberLoading());
    try {
      await updateMember.call(id, memberData); // استخدم call()
      emit(const MemberOperationSuccess('Member updated successfully'));
      await loadMembers(); // إعادة تحميل القائمة بعد التحديث
    } catch (e) {
      emit(MemberError(e.toString()));
    }
  }

  Future<void> deleteMemberAction(int id) async {
    emit(MemberLoading());
    try {
      await deleteMember.call(id); // استخدم call()
      emit(const MemberOperationSuccess('Member deleted successfully'));
      await loadMembers(); // إعادة تحميل القائمة بعد الحذف
    } catch (e) {
      emit(MemberError(e.toString()));
    }
  }
}
