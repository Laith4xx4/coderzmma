import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maa3/core/app_theme.dart';
import 'package:maa3/widgets/modern_card.dart';
import 'package:maa3/features/feedbacks/domain/entities/feedback_entity.dart';
import 'package:maa3/features/feedbacks/data/models/create_feedback_model.dart';
import 'package:maa3/features/feedbacks/data/models/update_feedback_model.dart';
import 'package:maa3/features/feedbacks/presentation/bloc/feedback_cubit.dart';
import 'package:maa3/features/feedbacks/presentation/bloc/feedback_state.dart';
import 'package:maa3/features/memberpro/presentation/bloc/member_cubit.dart';
import 'package:maa3/features/memberpro/presentation/bloc/member_state.dart';
import 'package:maa3/features/coaches/presentation/bloc/coach_cubit.dart';
import 'package:maa3/features/coaches/presentation/bloc/coach_state.dart';
import 'package:maa3/features/sessions/presentation/bloc/session_cubit.dart';
import 'package:maa3/features/sessions/presentation/bloc/session_state.dart';

class FeedbackListPage extends StatefulWidget {
  const FeedbackListPage({super.key});

  @override
  State<FeedbackListPage> createState() => _FeedbackListPageState();
}

class _FeedbackListPageState extends State<FeedbackListPage> {
  @override
  void initState() {
    super.initState();
    context.read<FeedbackCubit>().loadFeedbacks();
    context.read<MemberCubit>().loadMembers();
    context.read<CoachCubit>().loadCoaches();
    context.read<SessionCubit>().loadSessions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text(
          'Feedbacks',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFeedbackDialog(context),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocConsumer<FeedbackCubit, FeedbackState>(
        listener: (context, state) {
          if (state is FeedbackOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is FeedbackError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is FeedbackInitial || state is FeedbackLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FeedbacksLoaded) {
            if (state.feedbacks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.feedback_outlined, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'No feedback found.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<FeedbackCubit>().loadFeedbacks();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.feedbacks.length,
                itemBuilder: (context, index) {
                  final item = state.feedbacks[index];
                  return FeedbackCard(
                    item: item,
                    onEdit: () => _showEditFeedbackDialog(context, item),
                    onDelete: () => _showDeleteDialog(context, item.id),
                  );
                },
              ),
            );
          }

          if (state is FeedbackError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load feedback.\nError: ${state.message}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<FeedbackCubit>().loadFeedbacks(),
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

  void _showAddFeedbackDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final membersState = context.read<MemberCubit>().state;
    final coachesState = context.read<CoachCubit>().state;
    final sessionsState = context.read<SessionCubit>().state;
    
    List<dynamic> members = [];
    List<dynamic> coaches = [];
    List<dynamic> sessions = [];
    
    if (membersState is MembersLoaded) {
      members = membersState.members;
    }
    if (coachesState is CoachesLoaded) {
      coaches = coachesState.coaches;
    }
    if (sessionsState is SessionsLoaded) {
      sessions = sessionsState.sessions;
    }

    final TextEditingController _commentsController = TextEditingController();
    int? selectedMemberId;
    int? selectedCoachId;
    int? selectedSessionId;
    double rating = 5.0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Feedback'),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(labelText: 'Member *'),
                        items: members.map<DropdownMenuItem<int>>((member) {
                          return DropdownMenuItem<int>(
                            value: member.id,
                            child: Text(member.userName),
                          );
                        }).toList(),
                        onChanged: (value) => selectedMemberId = value,
                        validator: (value) => value == null ? 'Select a member' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(labelText: 'Coach *'),
                        items: coaches.map<DropdownMenuItem<int>>((coach) {
                          return DropdownMenuItem<int>(
                            value: coach.id,
                            child: Text(coach.userName),
                          );
                        }).toList(),
                        onChanged: (value) => selectedCoachId = value,
                        validator: (value) => value == null ? 'Select a coach' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(labelText: 'Session *'),
                        items: sessions.map<DropdownMenuItem<int>>((session) {
                          return DropdownMenuItem<int>(
                            value: session.id,
                            child: Text('Session #${session.id}'),
                          );
                        }).toList(),
                        onChanged: (value) => selectedSessionId = value,
                        validator: (value) => value == null ? 'Select a session' : null,
                      ),
                      const SizedBox(height: 16),
                      Text('Rating: ${rating.toStringAsFixed(1)}'),
                      Slider(
                        value: rating,
                        min: 1.0,
                        max: 5.0,
                        divisions: 4,
                        label: rating.toStringAsFixed(1),
                        onChanged: (value) {
                          setState(() {
                            rating = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _commentsController,
                        decoration: const InputDecoration(labelText: 'Comments (Optional)'),
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
                    if (_formKey.currentState!.validate() &&
                        selectedMemberId != null &&
                        selectedCoachId != null &&
                        selectedSessionId != null) {
                      context.read<FeedbackCubit>().createFeedbackAction(
                        CreateFeedbackModel(
                          memberId: selectedMemberId!,
                          coachId: selectedCoachId!,
                          sessionId: selectedSessionId!,
                          rating: rating,
                          comments: _commentsController.text.isEmpty
                              ? null
                              : _commentsController.text,
                          timestamp: DateTime.now(),
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
      },
    );
  }

  void _showEditFeedbackDialog(BuildContext context, FeedbackEntity item) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _commentsController = TextEditingController(text: item.comments ?? '');
    double rating = item.rating;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Feedback'),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Rating: ${rating.toStringAsFixed(1)}'),
                      Slider(
                        value: rating,
                        min: 1.0,
                        max: 5.0,
                        divisions: 4,
                        label: rating.toStringAsFixed(1),
                        onChanged: (value) {
                          setState(() {
                            rating = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _commentsController,
                        decoration: const InputDecoration(labelText: 'Comments'),
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
                    context.read<FeedbackCubit>().updateFeedbackAction(
                      item.id,
                      UpdateFeedbackModel(
                        rating: rating,
                        comments: _commentsController.text.isEmpty
                            ? null
                            : _commentsController.text,
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
      },
    );
  }

  void _showDeleteDialog(BuildContext context, int feedbackId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Feedback'),
        content: const Text('Are you sure you want to delete this feedback?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<FeedbackCubit>().deleteFeedbackAction(feedbackId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class FeedbackCard extends StatelessWidget {
  final FeedbackEntity item;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const FeedbackCard({
    super.key,
    required this.item,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final date = item.timestamp.toLocal().toString().split(' ')[0];
    final time = TimeOfDay.fromDateTime(item.timestamp.toLocal());

    final ratingColor = _getRatingColor(item.rating);

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ratingColor.withOpacity(0.2),
                      ratingColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                ),
                child: Icon(
                  Icons.feedback,
                  color: ratingColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.memberName} → ${item.coachName}',
                      style: AppTheme.heading3.copyWith(fontSize: 18),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.sessionName,
                      style: AppTheme.bodyMedium,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ...List.generate(5, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 2),
                        child: Icon(
                          index < item.rating.round()
                              ? Icons.star
                              : Icons.star_border,
                          size: 20,
                          color: ratingColor,
                        ),
                      );
                    }),
                    const SizedBox(width: 12),
                    Text(
                      '${item.rating.toStringAsFixed(1)}/5.0',
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ratingColor,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (item.comments != null && item.comments!.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingMD),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMD),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                border: Border.all(
                  color: AppTheme.textLight.withOpacity(0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.comment,
                    size: 18,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: AppTheme.spacingSM),
                  Expanded(
                    child: Text(
                      item.comments!,
                      style: AppTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
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

  Color _getRatingColor(double rating) {
    if (rating >= 4.0) return AppTheme.successColor;
    if (rating >= 3.0) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }
}
