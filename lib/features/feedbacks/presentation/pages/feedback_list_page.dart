import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maa3/core/role_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maa3/core/app_theme.dart';
// import 'package:maa3/core/helpers/role_helper.dart';
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
  // ✅ متغيرات الصلاحيات
  String _currentUserRole = '';
  int? _currentUserId;
  bool _isAdmin = false;
  bool _isCoach = false;
  bool _isMember = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserRoleAndData();
  }

  /// ✅ تحميل دور المستخدم والبيانات
  Future<void> _loadUserRoleAndData() async {
    final prefs = await SharedPreferences.getInstance();


    _currentUserRole = await RoleHelper.getCurrentUserRole();
    _currentUserId = prefs.getInt('userId');
    _isAdmin = await RoleHelper.isAdmin();
    _isCoach = await RoleHelper.isCoach();
    _isMember = await RoleHelper.isMember();

    setState(() {
      _isLoading = false;
    });

    // تحميل البيانات
    if (mounted) {
      context.read<FeedbackCubit>().loadFeedbacks();
      context.read<MemberCubit>().loadMembers();
      context.read<CoachCubit>().loadCoaches();
      context.read<SessionCubit>().loadSessions();
    }
  }

  /// ✅ فلترة الفيدباك حسب الصلاحيات
  List<FeedbackEntity> _filterFeedbacksByRole(List<FeedbackEntity> feedbacks) {
    if (_isAdmin) {
      // Admin يرى كل الفيدباك
      return feedbacks;
    } else if (_isCoach) {
      // Coach يرى الفيدباك الموجه له فقط
      return feedbacks.where((f) => f.coachId == _currentUserId).toList();
    } else {
      // Member يرى الفيدباك الخاص به فقط
      return feedbacks.where((f) => f.memberId == _currentUserId).toList();
    }
  }

  /// ✅ التحقق من إمكانية تعديل الفيدباك
  bool _canEditFeedback(FeedbackEntity feedback) {
    if (_isAdmin) return true;
    if (_isMember && feedback.memberId == _currentUserId) return true;
    return false;
  }

  /// ✅ التحقق من إمكانية حذف الفيدباك
  bool _canDeleteFeedback(FeedbackEntity feedback) {
    if (_isAdmin) return true;
    if (_isMember && feedback.memberId == _currentUserId) return true;
    return false;
  }

  /// ✅ التحقق من إمكانية إضافة فيدباك
  bool _canAddFeedback() {
    // الكل يمكنه إضافة فيدباك
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme.primaryColor,
          title: const Text(
            'Feedbacks',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: Row(
          children: [
            const Text(
              'Feedbacks',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            // ✅ عرض دور المستخدم
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _currentUserRole,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        elevation: 0,
      ),
      // ✅ FAB حسب الصلاحيات
      floatingActionButton: _canAddFeedback()
          ? FloatingActionButton(
        onPressed: () => _showAddFeedbackDialog(context),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
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
            // ✅ فلترة حسب الصلاحيات
            final filteredFeedbacks = _filterFeedbacksByRole(state.feedbacks);

            if (filteredFeedbacks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.feedback_outlined, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      _isAdmin
                          ? 'No feedback found.'
                          : 'No feedback available for you.',
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    if (_isMember) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Add your first feedback!',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
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
                itemCount: filteredFeedbacks.length,
                itemBuilder: (context, index) {
                  final item = filteredFeedbacks[index];
                  return FeedbackCard(
                    item: item,
                    // ✅ إظهار أزرار التعديل والحذف حسب الصلاحيات
                    onEdit: _canEditFeedback(item)
                        ? () => _showEditFeedbackDialog(context, item)
                        : null,
                    onDelete: _canDeleteFeedback(item)
                        ? () => _showDeleteDialog(context, item.id)
                        : null,
                    showOwnerBadge: _isAdmin,
                    isOwnFeedback: item.memberId == _currentUserId,
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

    // ✅ للعضو: تعيين memberId تلقائياً
    int? selectedMemberId = _isMember ? _currentUserId : null;
    int? selectedCoachId;
    int? selectedSessionId;
    double rating = 5.0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  const Text('Add Feedback'),
                  const Spacer(),
                  // ✅ عرض دور المستخدم في الحوار
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _currentUserRole,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ✅ إظهار dropdown العضو فقط للـ Admin
                      if (_isAdmin)
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
                        )
                      else
                      // ✅ للعضو: عرض اسمه فقط
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.person, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                'Feedback from: You',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                            ],
                          ),
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
    final TextEditingController _commentsController =
    TextEditingController(text: item.comments ?? '');
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
                      // ✅ عرض معلومات الفيدباك
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow('Member', item.memberName),
                            const SizedBox(height: 4),
                            _buildInfoRow('Coach', item.coachName),
                            const SizedBox(height: 4),
                            _buildInfoRow('Session', item.sessionName),
                          ],
                        ),
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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

// ✅ تحديث FeedbackCard لدعم الصلاحيات
class FeedbackCard extends StatelessWidget {
  final FeedbackEntity item;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showOwnerBadge;
  final bool isOwnFeedback;

  const FeedbackCard({
    super.key,
    required this.item,
    this.onEdit,
    this.onDelete,
    this.showOwnerBadge = false,
    this.isOwnFeedback = false,
  });

  @override
  Widget build(BuildContext context) {
    final date = item.timestamp.toLocal().toString().split(' ')[0];
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${item.memberName} → ${item.coachName}',
                            style: AppTheme.heading3.copyWith(fontSize: 18),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // ✅ Badge للفيدباك الخاص بالمستخدم
                        if (isOwnFeedback)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'You',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
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
          // ✅ أزرار التعديل والحذف حسب الصلاحيات
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