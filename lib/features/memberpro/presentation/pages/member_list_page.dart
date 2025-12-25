import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maa3/core/role_helper.dart';
import 'package:maa3/core/app_theme.dart';
import 'package:maa3/widgets/modern_card.dart';
import 'package:maa3/features/memberpro/domain/entities/member_profile_entity.dart';
import 'package:maa3/features/memberpro/data/models/create_member_profile_model.dart';
import 'package:maa3/features/memberpro/data/models/update_member_profile_model.dart';
import 'package:maa3/features/memberpro/presentation/bloc/member_cubit.dart';
import 'package:maa3/features/memberpro/presentation/bloc/member_state.dart';

class MemberListPage extends StatefulWidget {
  const MemberListPage({super.key});

  @override
  State<MemberListPage> createState() => _MemberListPageState();
}

class _MemberListPageState extends State<MemberListPage> {
  bool canManage = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final canManageMembers = await RoleHelper.canManageMembers();
    setState(() {
      canManage = canManageMembers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Club Members',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      floatingActionButton: canManage
          ? FloatingActionButton(
              onPressed: () => _showAddMemberDialog(context),
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: BlocConsumer<MemberCubit, MemberState>(
        listener: (context, state) {
          if (state is MemberOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is MemberError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is MemberInitial) {
            context.read<MemberCubit>().loadMembers();
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MemberLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MembersLoaded) {
            if (state.members.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No members found.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<MemberCubit>().loadMembers();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.members.length,
                itemBuilder: (context, index) {
                  final member = state.members[index];
                  return MemberCard(
                    member: member,
                    canEdit: canManage,
                    canDelete: canManage,
                  );
                },
              ),
            );
          }

          if (state is MemberError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load members.\nError: ${state.message}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<MemberCubit>().loadMembers(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Something went wrong.'));
        },
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context) async {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _userNameController = TextEditingController(); // استخدام UserName
    final TextEditingController _firstNameController = TextEditingController();
    final TextEditingController _lastNameController = TextEditingController();
    final TextEditingController _emergencyContactNameController = TextEditingController();
    final TextEditingController _emergencyContactPhoneController = TextEditingController();
    final TextEditingController _medicalInfoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Member'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _userNameController,
                    decoration: const InputDecoration(labelText: 'User Name *'), // تعديل النص
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(labelText: 'First Name'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emergencyContactNameController,
                    decoration: const InputDecoration(labelText: 'Emergency Contact Name'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emergencyContactPhoneController,
                    decoration: const InputDecoration(labelText: 'Emergency Contact Phone'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _medicalInfoController,
                    decoration: const InputDecoration(labelText: 'Medical Info'),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  context.read<MemberCubit>().createMemberAction(
                    CreateMemberProfileModel(
                      userName: _userNameController.text, // استخدام UserName بدل UserId
                      firstName: _firstNameController.text.isEmpty ? null : _firstNameController.text,
                      lastName: _lastNameController.text.isEmpty ? null : _lastNameController.text,
                      emergencyContactName: _emergencyContactNameController.text.isEmpty
                          ? null
                          : _emergencyContactNameController.text,
                      emergencyContactPhone: _emergencyContactPhoneController.text.isEmpty
                          ? null
                          : _emergencyContactPhoneController.text,
                      medicalInfo: _medicalInfoController.text.isEmpty
                          ? null
                          : _medicalInfoController.text,
                      joinDate: DateTime.now(),
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class MemberCard extends StatelessWidget {
  final MemberProfileEntity member;
  final bool canEdit;
  final bool canDelete;

  const MemberCard({
    super.key,
    required this.member,
    this.canEdit = false,
    this.canDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    final fullName = '${member.firstName ?? ''} ${member.lastName ?? ''}'
        .trim();
    final displayName = fullName.isEmpty ? member.userName : fullName;

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const GradientAvatar(icon: Icons.person),
              const SizedBox(width: AppTheme.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: AppTheme.heading3.copyWith(fontSize: 18),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.alternate_email,
                          size: 14,
                          color: AppTheme.textLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          member.userName,
                          style: AppTheme.bodyMedium.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMD),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMD),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
            child: Row(
              children: [
                Expanded(
                  child: StatItem(
                    icon: Icons.calendar_today,
                    label: 'Joined',
                    value: member.joinDate.toLocal().toString().split(' ')[0],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppTheme.textLight.withOpacity(0.2),
                ),
                Expanded(
                  child: StatItem(
                    icon: Icons.book,
                    label: 'Bookings',
                    value: '${member.bookingsCount}',
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppTheme.textLight.withOpacity(0.2),
                ),
                Expanded(
                  child: StatItem(
                    icon: Icons.check_circle,
                    label: 'Attendance',
                    value: '${member.attendanceCount}',
                  ),
                ),
              ],
            ),
          ),
          if (canEdit || canDelete) ...[
            const SizedBox(height: AppTheme.spacingMD),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (canEdit)
                  ActionButton(
                    icon: Icons.edit_rounded,
                    color: AppTheme.infoColor,
                    onPressed: () => _showUpdateMemberDialog(context, member),
                    tooltip: 'Edit',
                  ),
                if (canEdit && canDelete)
                  const SizedBox(width: AppTheme.spacingSM),
                if (canDelete)
                  ActionButton(
                    icon: Icons.delete_rounded,
                    color: AppTheme.errorColor,
                    onPressed: () =>
                        _showDeleteConfirmation(context, member.id),
                    tooltip: 'Delete',
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showUpdateMemberDialog(
    BuildContext context,
    MemberProfileEntity member,
  ) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _firstNameController = TextEditingController(
      text: member.firstName ?? '',
    );
    final TextEditingController _lastNameController = TextEditingController(
      text: member.lastName ?? '',
    );
    final TextEditingController _emergencyContactNameController =
        TextEditingController(text: member.emergencyContactName ?? '');
    final TextEditingController _emergencyContactPhoneController =
        TextEditingController(text: member.emergencyContactPhone ?? '');
    final TextEditingController _medicalInfoController = TextEditingController(
      text: member.medicalInfo ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Member'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(labelText: 'First Name'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emergencyContactNameController,
                    decoration: const InputDecoration(
                      labelText: 'Emergency Contact Name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emergencyContactPhoneController,
                    decoration: const InputDecoration(
                      labelText: 'Emergency Contact Phone',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _medicalInfoController,
                    decoration: const InputDecoration(
                      labelText: 'Medical Info',
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<MemberCubit>().updateMemberAction(
                  member.id,
                  UpdateMemberProfileModel(
                    firstName: _firstNameController.text.isEmpty
                        ? null
                        : _firstNameController.text,
                    lastName: _lastNameController.text.isEmpty
                        ? null
                        : _lastNameController.text,
                    emergencyContactName:
                        _emergencyContactNameController.text.isEmpty
                        ? null
                        : _emergencyContactNameController.text,
                    emergencyContactPhone:
                        _emergencyContactPhoneController.text.isEmpty
                        ? null
                        : _emergencyContactPhoneController.text,
                    medicalInfo: _medicalInfoController.text.isEmpty
                        ? null
                        : _medicalInfoController.text,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, int memberId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Member'),
        content: const Text('Are you sure you want to delete this member?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<MemberCubit>().deleteMemberAction(memberId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
