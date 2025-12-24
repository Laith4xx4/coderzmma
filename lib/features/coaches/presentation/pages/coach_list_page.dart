import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maa3/core/app_theme.dart';
import 'package:maa3/widgets/modern_card.dart';
import 'package:maa3/features/coaches/domain/entities/coach_entity.dart';
import 'package:maa3/features/coaches/data/models/create_coach_model.dart';
import 'package:maa3/features/coaches/data/models/update_coach_model.dart';
import 'package:maa3/features/coaches/presentation/bloc/coach_cubit.dart';
import 'package:maa3/features/coaches/presentation/bloc/coach_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoachListPage extends StatefulWidget {
  const CoachListPage({super.key});

  @override
  State<CoachListPage> createState() => _CoachListPageState();
}

class _CoachListPageState extends State<CoachListPage> {
  @override
  void initState() {
    super.initState();
    context.read<CoachCubit>().loadCoaches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text(
          'Coaches',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCoachDialog(context),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
            if (state.coaches.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.person_outline, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No coaches found.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<CoachCubit>().loadCoaches();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.coaches.length,
                itemBuilder: (context, index) {
                  final coach = state.coaches[index];
                  return CoachCard(
                    coach: coach,
                    onEdit: () => _showEditCoachDialog(context, coach),
                    onDelete: () => _showDeleteDialog(context, coach.id),
                  );
                },
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

  void _showAddCoachDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final userNameController = TextEditingController();
    final bioController = TextEditingController();
    final specializationController = TextEditingController();
    final certificationsController = TextEditingController();

    // الحصول على البريد الإلكتروني الحالي كـ default UserName (إن وُجد)
    final prefs = await SharedPreferences.getInstance();
    final currentUserEmail = prefs.getString("userEmail") ?? "";
    userNameController.text = currentUserEmail;

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
                    decoration:
                    const InputDecoration(labelText: 'User Name *'),
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
        content:
        const Text('Are you sure you want to delete this coach?'),
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