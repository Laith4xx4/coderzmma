import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thesavage/core/app_theme.dart';
import 'package:thesavage/widgets/modern_card.dart';
import 'package:thesavage/features/coaches/domain/entities/coach_entity.dart';
import 'package:thesavage/features/coaches/data/models/create_coach_model.dart';
import 'package:thesavage/features/coaches/data/models/update_coach_model.dart';
import 'package:thesavage/features/coaches/presentation/bloc/coach_cubit.dart';
import 'package:thesavage/features/coaches/presentation/bloc/coach_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thesavage/features/users/data/datasource/user_api_service.dart';
import 'package:thesavage/features/users/domain/entities/user_entity.dart';

import '../../../../core/role_helper.dart';

class CoachListPage extends StatefulWidget {
  const CoachListPage({super.key});


  @override
  State<CoachListPage> createState() => _CoachListPageState();
}

class _CoachListPageState extends State<CoachListPage> {
  final UserApiService _userApiService = UserApiService();
  List<UserEntity> _usersWithCoachRole = [];
  bool _isLoadingUsers = false;
  String? _userLoadError;
  bool _canManage = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    context.read<CoachCubit>().loadCoaches();
  }

  Future<void> _checkPermissions() async {
     final canManage = await RoleHelper.canManageCoaches();
     setState(() {
       _canManage = canManage;
     });
     if (canManage) {
        _loadUsersWithCoachRole();
     }
  }

  Future<void> _loadUsersWithCoachRole() async {
    // ... existing code
    setState(() {
      _isLoadingUsers = true;
      _userLoadError = null;
    });

    try {
      final users = await _userApiService.getUsersByRole('Coach');
      setState(() {
        _usersWithCoachRole = users;
        _isLoadingUsers = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _userLoadError = e.toString();
          _isLoadingUsers = false;
        });
      }
    }
  }

  Future<void> _refreshAll() async {
    context.read<CoachCubit>().loadCoaches();
    if (_canManage) {
      await _loadUsersWithCoachRole();
    }
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
          'Coaches',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      floatingActionButton: _canManage ? FloatingActionButton(
        onPressed: () => _showAddCoachDialog(context),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.black),
      ) : null,
      body: BlocConsumer<CoachCubit, CoachState>(
        listener: (context, state) {
          if (state is CoachOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is CoachError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CoachInitial || state is CoachLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CoachesLoaded) {


            return RefreshIndicator(
              onRefresh: _refreshAll,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Users with Coach role section
                  if (_isLoadingUsers)
                     const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator())),

                  if (_userLoadError != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Error syncing users: $_userLoadError', style: const TextStyle(color: Colors.red, fontSize: 12)),
                    ),

                  if (_canManage && _usersWithCoachRole.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      child: Row(
                        children: [
                          Icon(Icons.person_add_alt_1_rounded, color: AppTheme.infoColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Users with Coach Role',
                            style: AppTheme.heading3.copyWith(fontSize: 16),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(Icons.refresh_rounded, color: AppTheme.primaryColor),
                            onPressed: _loadUsersWithCoachRole,
                            tooltip: 'Refresh coaches',
                            splashRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    ..._usersWithCoachRole.map((user) => UserCoachCard(
                      user: user,
                      onTap: () => _showAddCoachDialog(context, prefilledUserName: user.userName),
                    )),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 12),
                  ],
                  
                  // Coach profiles section
                  if (state.coaches.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      child: Row(
                        children: [
                          Icon(Icons.sports_gymnastics_rounded, color: AppTheme.successColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Coach Profiles',
                            style: AppTheme.heading3.copyWith(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    ...state.coaches.map((coach) => CoachCard(
                      coach: coach,
                      onEdit: _canManage ? () => _showEditCoachDialog(context, coach) : null,
                      onDelete: _canManage ? () => _showDeleteDialog(context, coach.id) : null,
                    )),
                  ],
                  
                  // Show message if both are empty
                  if (state.coaches.isEmpty && _usersWithCoachRole.isEmpty) ...[
                    const SizedBox(height: 100),
                    Center(
                      child: Column(
                        children: const [
                          Icon(Icons.person_outline, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No coaches found.',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          if (state is CoachError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load coaches.\nError: ${state.message}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<CoachCubit>().loadCoaches(),
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

  void _showAddCoachDialog(BuildContext context, {String? prefilledUserName}) async {
    final formKey = GlobalKey<FormState>();
    final userNameController = TextEditingController(text: prefilledUserName ?? '');
    final bioController = TextEditingController();
    final specializationController = TextEditingController();
    final certificationsController = TextEditingController();

    // If no prefilled name, try to use current user email
    if (prefilledUserName == null) {
      final prefs = await SharedPreferences.getInstance();
      final currentUserEmail = prefs.getString("userEmail") ?? "";
      userNameController.text = currentUserEmail;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Coach'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: userNameController,
                    readOnly: prefilledUserName != null, // Lock if prefilled
                    decoration: InputDecoration(
                      labelText: 'User Name *',
                      filled: prefilledUserName != null,
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: specializationController,
                    decoration:
                        const InputDecoration(labelText: 'Specialization *'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: bioController,
                    decoration: const InputDecoration(labelText: 'Bio *'),
                    maxLines: 3,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: certificationsController,
                    decoration: const InputDecoration(
                      labelText: 'Certifications (Optional)',
                    ),
                    maxLines: 2,
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
                if (formKey.currentState!.validate()) {
                  context.read<CoachCubit>().createCoachAction(
                        CreateCoachModel(
                          userName: userNameController.text,
                          bio: bioController.text,
                          specialization: specializationController.text,
                          certifications:
                              certificationsController.text.isEmpty
                                  ? null
                                  : certificationsController.text,
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

  void _showEditCoachDialog(BuildContext context, CoachEntity coach) {
    final formKey = GlobalKey<FormState>();
    final bioController =
        TextEditingController(text: coach.bio ?? ''); // ← null-safe
    final specializationController =
        TextEditingController(text: coach.specialization ?? '');
    final certificationsController =
        TextEditingController(text: coach.certifications ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Coach'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: specializationController,
                    decoration:
                        const InputDecoration(labelText: 'Specialization *'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: bioController,
                    decoration: const InputDecoration(labelText: 'Bio *'),
                    maxLines: 3,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: certificationsController,
                    decoration: const InputDecoration(
                      labelText: 'Certifications (Optional)',
                    ),
                    maxLines: 2,
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
                if (formKey.currentState!.validate()) {
                  context.read<CoachCubit>().updateCoachAction(
                        coach.id,
                        UpdateCoachModel(
                          bio: bioController.text,
                          specialization: specializationController.text,
                          certifications:
                              certificationsController.text.isEmpty
                                  ? null
                                  : certificationsController.text,
                        ),
                      );
                  Navigator.pop(context);
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, int coachId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Coach'),
        content: const Text('Are you sure you want to delete this coach?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CoachCubit>().deleteCoachAction(coachId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class CoachCard extends StatelessWidget {
  final CoachEntity coach;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CoachCard({
    super.key,
    required this.coach,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
                      coach.userName,
                      style: AppTheme.heading3.copyWith(fontSize: 18),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        coach.specialization ?? '', // ← null-safe
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
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
              borderRadius:
              BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
            child: Text(
              coach.bio ?? '', // ← null-safe
              style: AppTheme.bodyMedium,
            ),
          ),
          if (coach.certifications != null &&
              coach.certifications!.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingMD),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingSM),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                borderRadius:
                BorderRadius.circular(AppTheme.borderRadiusMedium),
                border: Border.all(
                  color: AppTheme.successColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.verified,
                    size: 18,
                    color: AppTheme.successColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      coach.certifications!,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppTheme.spacingMD),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMD),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius:
              BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
            child: Row(
              children: [
                Expanded(
                  child: StatItem(
                    icon: Icons.calendar_today,
                    label: 'Sessions',
                    value: '${coach.sessionsCount}',
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppTheme.textLight.withOpacity(0.2),
                ),
                Expanded(
                  child: StatItem(
                    icon: Icons.feedback,
                    label: 'Feedbacks',
                    value: '${coach.feedbacksCount}',
                  ),
                ),
              ],
            ),
          ),
          if (onEdit != null || onDelete != null) ...[
            const SizedBox(height: AppTheme.spacingMD),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onEdit != null)
                  ActionButton(
                    icon: Icons.edit_rounded,
                    color: AppTheme.infoColor,
                    onPressed: onEdit!,
                    tooltip: 'Edit',
                  ),
                if (onEdit != null && onDelete != null)
                  const SizedBox(width: AppTheme.spacingSM),
                if (onDelete != null)
                  ActionButton(
                    icon: Icons.delete_rounded,
                    color: AppTheme.errorColor,
                    onPressed: onDelete!,
                    tooltip: 'Delete',
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class UserCoachCard extends StatelessWidget {
  final UserEntity user;
  final VoidCallback onTap; // Added callback

  const UserCoachCard({
    super.key,
    required this.user,
    required this.onTap, // Required now
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      child: InkWell( // Wrap in InkWell for tap interaction
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        child: Padding( // Add padding inside InkWell for ripple effect
          padding: const EdgeInsets.all(8.0), // Optional: Adjust padding if needed
          child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Row(
                 children: [
                   Container(
                     padding: const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.infoColor.withOpacity(0.8),
                      AppTheme.infoColor,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: AppTheme.heading3.copyWith(fontSize: 18),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${user.userName}',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.infoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.infoColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_user_rounded,
                      size: 16,
                      color: AppTheme.infoColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Coach Role',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.infoColor,
                        fontWeight: FontWeight.w600,
                      ),
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
                Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: AppTheme.infoColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'User account with Coach role. Create a coach profile for detailed information.',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingMD),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMD),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.email_outlined, user.email),
                if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.phone_outlined, user.phoneNumber!),
                ],
              ],
            ),
          ),
        ],
      ),
    )
      )
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textLight),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}