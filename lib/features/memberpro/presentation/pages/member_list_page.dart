import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thesavage/core/role_helper.dart';
import 'package:thesavage/core/app_theme.dart';
import 'package:thesavage/widgets/modern_card.dart';
import 'package:thesavage/features/memberpro/domain/entities/member_profile_entity.dart';
import 'package:thesavage/features/memberpro/data/models/create_member_profile_model.dart';
import 'package:thesavage/features/memberpro/data/models/update_member_profile_model.dart';
import 'package:thesavage/features/memberpro/presentation/bloc/member_cubit.dart';
import 'package:thesavage/features/memberpro/presentation/bloc/member_state.dart';
import 'package:thesavage/features/users/data/datasource/user_api_service.dart';
import 'package:thesavage/features/users/domain/entities/user_entity.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MemberListPage extends StatefulWidget {
  const MemberListPage({super.key});

  @override
  State<MemberListPage> createState() => _MemberListPageState();
}

class _MemberListPageState extends State<MemberListPage> {
  bool canManage = false;
  
  // Users with Member Role State
  List<UserEntity> _usersWithMemberRole = [];
  bool _isLoadingUsers = false;
  String? _userLoadError;
  final UserApiService _userApiService = UserApiService();

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _loadUsersWithMemberRole();
  }

  Future<void> _loadUsersWithMemberRole() async {
    setState(() {
      _isLoadingUsers = true;
      _userLoadError = null;
    });

    try {
      final users = await _userApiService.getUsersByRole('Member');
      // Filter out users who already have a profile if possible, 
      // but for now we just show all users with the role.
      // Ideally backend would handle this or we cross-reference ID.
      setState(() {
        _usersWithMemberRole = users;
        _isLoadingUsers = false;
      });
    } catch (e) {
      print('Error loading users with Member role: $e');
      setState(() {
        _userLoadError = e.toString();
        _isLoadingUsers = false;
        // Don't clear list on error to keep old data if available
      });
    }
  }

  Future<void> _refreshAll() async {
    final memberCubit = context.read<MemberCubit>();
    await Future.wait([
      memberCubit.getAllMembers.call().then((members) { 
        // Manually triggering state emission if needed or just rely on loadMembers
        memberCubit.loadMembers();
      }),
      _loadUsersWithMemberRole(),
    ]);
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
        centerTitle: true,
        backgroundColor: AppTheme.primaryDark,
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

          // Combine both lists
          List<MemberProfileEntity> memberProfiles = [];
          
          if (state is MembersLoaded) {
            memberProfiles = state.members;
          }

          return RefreshIndicator(
            onRefresh: _refreshAll,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Section 1: Users with "Member" Role (Sync Needed)
                if (_isLoadingUsers)
                   const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator())),
                
                if (_usersWithMemberRole.isNotEmpty) ...[
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Users with Member Role (Sync)',
                        style: AppTheme.heading3.copyWith(fontSize: 16, color: AppTheme.warningColor),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 20, color: AppTheme.primaryColor),
                        onPressed: _loadUsersWithMemberRole,
                        tooltip: 'Refresh Users List',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_userLoadError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text('Error syncing: $_userLoadError', style: const TextStyle(color: Colors.red, fontSize: 12)),
                    ),
                  ..._usersWithMemberRole.map((user) => UserMemberCard(
                    user: user,
                    onTap: () => _showAddMemberDialog(context, prefilledUserName: user.userName),
                  )),
                  const SizedBox(height: 16),
                  const Divider(thickness: 1, color: AppTheme.primaryLight),
                  const SizedBox(height: 16),
                ],

                // Section 2: Full Member Profiles
                Text(
                  'Member Profiles',
                  style: AppTheme.heading3.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 8),

                if (state is MemberLoading)
                  const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
                
                if (state is MemberError)
                   Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Error loading profiles: ${state.message}', style: const TextStyle(color: Colors.red)),
                    ),
                  ),

                if (state is MembersLoaded) ...[
                   if (state.members.isEmpty && _usersWithMemberRole.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text('No members found.', style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                   ...state.members.map((member) => Padding(
                     padding: const EdgeInsets.only(bottom: 8.0),
                     child: MemberCard(
                        member: member,
                        canEdit: canManage,
                        canDelete: canManage,
                      ),
                   )),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context, {String? prefilledUserName}) async {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _userNameController = TextEditingController(text: prefilledUserName ?? ''); // استخدام UserName
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
                    readOnly: prefilledUserName != null, // Lock if prefilled
                    decoration: InputDecoration(
                      labelText: 'User Name *',
                      filled: prefilledUserName != null,
                    ),
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

class UserMemberCard extends StatelessWidget {
  final UserEntity user;
  final VoidCallback onTap;

  const UserMemberCard({super.key, required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        child: Padding(
            padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Visual distinction: different colored avatar or badge
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.warningColor, width: 2), // Changed to valid color
                ),
                child: const GradientAvatar(
                  icon: Icons.person_outline,
                  size: 40, 
                ),
              ),
              const SizedBox(width: AppTheme.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user.userName,
                          style: AppTheme.heading3.copyWith(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.warningColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppTheme.warningColor.withOpacity(0.5)),
                          ),
                          child: const Text(
                            'Member Role',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.warningColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (user.firstName != null || user.lastName != null)
                      Text(
                        '${user.firstName ?? ''} ${user.lastName ?? ''}',
                        style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
                      ),
                     const SizedBox(height: 4),
                     Row(
                       children: [
                         const Icon(Icons.email_outlined, size: 12, color: AppTheme.textLight),
                         const SizedBox(width: 4),
                         Text(user.email, style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
                       ],
                     )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
