import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maa3/core/role_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String _currentUserRole = '';
  int? _currentUserId;
  String? _currentUserName;
  bool _isAdmin = false;
  bool _isCoach = false;
  bool _isMember = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserRoleAndData();
  }

  Future<void> _loadUserRoleAndData() async {
    final prefs = await SharedPreferences.getInstance();

    _currentUserRole = await RoleHelper.getCurrentUserRole();
    _isAdmin = await RoleHelper.isAdmin();
    _isCoach = await RoleHelper.isCoach();
    _isMember = await RoleHelper.isMember();

    // جلب الـ ID بأكثر من طريقة
    _currentUserId = prefs.getInt('userId');
    if (_currentUserId == null) {
      String? idString = prefs.getString('userId');
      if (idString != null) {
        _currentUserId = int.tryParse(idString);
      }
    }

    // جلب الاسم: firstName + lastName إذا موجود (Google Sign-In)، وإلا userName العادي
    String? firstName = prefs.getString('firstName');
    String? lastName = prefs.getString('lastName');
    
    if (firstName != null && firstName.isNotEmpty && lastName != null && lastName.isNotEmpty) {
      _currentUserName = '$firstName $lastName';
    } else {
      _currentUserName = prefs.getString('userName') ?? 'My Account';
    }

    setState(() => _isLoading = false);

    if (mounted) {
      context.read<FeedbackCubit>().loadFeedbacks();
      context.read<MemberCubit>().loadMembers();
      context.read<CoachCubit>().loadCoaches();
      context.read<SessionCubit>().loadSessions();
    }
  }

  List<FeedbackEntity> _filterFeedbacksByRole(List<FeedbackEntity> feedbacks) {
    if (_isAdmin) return feedbacks;
    if (_isCoach) {
      return feedbacks.where((f) => f.coachId == _currentUserId).toList();
    }
    return feedbacks.where((f) => f.memberId == _currentUserId).toList();
  }

  bool _canEditFeedback(FeedbackEntity feedback) {
    return _isAdmin || (_isMember && feedback.memberId == _currentUserId);
  }

  bool _canDeleteFeedback(FeedbackEntity feedback) {
    return _isAdmin || (_isMember && feedback.memberId == _currentUserId);
  }

  bool _canAddFeedback() => _isMember || _isCoach || _isAdmin;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme.primaryColor,
          title: const Text('Feedbacks', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            const Text('Feedbacks', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_currentUserRole, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
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
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
          } else if (state is FeedbackError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${state.message}'), backgroundColor: Colors.red));
          }
        },
        builder: (context, state) {
          if (state is FeedbackLoading || state is FeedbackInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is FeedbacksLoaded) {
            final filteredFeedbacks = _filterFeedbacksByRole(state.feedbacks);
            if (filteredFeedbacks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.feedback_outlined, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(_isAdmin ? 'No feedback found.' : 'No feedback available for you.', style: const TextStyle(fontSize: 18, color: Colors.grey)),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async => context.read<FeedbackCubit>().loadFeedbacks(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredFeedbacks.length,
                itemBuilder: (context, index) {
                  final item = filteredFeedbacks[index];
                  return FeedbackCard(
                    item: item,
                    onEdit: _canEditFeedback(item) ? () => _showEditFeedbackDialog(context, item) : null,
                    onDelete: _canDeleteFeedback(item) ? () => _showDeleteDialog(context, item.id) : null,
                    showOwnerBadge: _isAdmin,
                    isOwnFeedback: item.memberId == _currentUserId,
                  );
                },
              ),
            );
          }
          return const Center(child: Text('Something went wrong.'));
        },
      ),
    );
  }

  // ================== Add Feedback Dialog ==================
  void _showAddFeedbackDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final commentsController = TextEditingController();

    // جلب القوائم
    final membersState = context.read<MemberCubit>().state;
    final coachesState = context.read<CoachCubit>().state;
    final sessionsState = context.read<SessionCubit>().state;

    final members = membersState is MembersLoaded ? membersState.members : [];
    final coaches = coachesState is CoachesLoaded ? coachesState.coaches : [];
    final sessions = sessionsState is SessionsLoaded ? sessionsState.sessions : [];

    // التحقق من توفر Sessions (مطلوب لجميع الأدوار)
    if (sessions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No sessions available. Please add sessions first.'), backgroundColor: Colors.orange),
      );
      return;
    }

    // تحديد القيم الافتراضية بناءً على الدور
    int? selectedMemberId;
    int? selectedCoachId;
    
    if (_isMember) {
      // Member: يختار Coach و Session فقط
      selectedMemberId = _currentUserId;
      if (selectedMemberId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Member ID not found. Please login again.'), backgroundColor: Colors.red),
        );
        return;
      }
      if (coaches.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No coaches available. Please add coaches first.'), backgroundColor: Colors.orange),
        );
        return;
      }
      selectedCoachId = coaches.first.id;
    } else if (_isCoach) {
      // Coach: يختار Member و Session فقط
      selectedCoachId = _currentUserId;
      if (selectedCoachId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Coach ID not found. Please login again.'), backgroundColor: Colors.red),
        );
        return;
      }
      if (members.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No members available. Please add members first.'), backgroundColor: Colors.orange),
        );
        return;
      }
      selectedMemberId = members.first.id;
    } else if (_isAdmin) {
      // Admin: يختار الكل
      if (members.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No members available. Please add members first.'), backgroundColor: Colors.orange),
        );
        return;
      }
      if (coaches.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No coaches available. Please add coaches first.'), backgroundColor: Colors.orange),
        );
        return;
      }
      selectedMemberId = members.first.id;
      selectedCoachId = coaches.first.id;
    }

    int? selectedSessionId = sessions.first.id;
    double rating = 3.0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  const Text('Add Feedback'),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Text(_currentUserRole, style: TextStyle(fontSize: 10, color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // =============== Member Field ===============
                      if (_isAdmin || _isCoach)
                        DropdownButtonFormField<int>(
                          value: selectedMemberId,
                          decoration: const InputDecoration(
                            labelText: 'Member *',
                            border: OutlineInputBorder(),
                          ),
                          items: members.map<DropdownMenuItem<int>>((m) {
                            return DropdownMenuItem(
                              value: m.id,
                              child: Text(m.userName ?? 'Member ${m.id}'),
                            );
                          }).toList(),
                          onChanged: (v) => setStateDialog(() => selectedMemberId = v),
                          validator: (v) => v == null ? 'Select a member' : null,
                        )
                      else if (_isMember)
                        InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Member',
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.person, size: 20, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _currentUserName ?? 'My Account',
                                  style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const Icon(Icons.lock, size: 16, color: Colors.grey),
                            ],
                          ),
                        ),

                      const SizedBox(height: 16),

                      // =============== Coach Dropdown ===============
                      if (_isAdmin || _isMember)
                        DropdownButtonFormField<int>(
                          value: selectedCoachId,
                          decoration: const InputDecoration(
                            labelText: 'Coach *',
                            border: OutlineInputBorder(),
                          ),
                          items: coaches.map<DropdownMenuItem<int>>((c) {
                            return DropdownMenuItem(
                              value: c.id,
                              child: Text(c.userName ?? 'Coach ${c.id}'),
                            );
                          }).toList(),
                          onChanged: (v) => setStateDialog(() => selectedCoachId = v),
                          validator: (v) => v == null ? 'Select a coach' : null,
                        )
                      else if (_isCoach)
                        InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Coach',
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.sports, size: 20, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _currentUserName ?? 'My Account',
                                  style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const Icon(Icons.lock, size: 16, color: Colors.grey),
                            ],
                          ),
                        ),

                      const SizedBox(height: 16),

                      // =============== Session Dropdown ===============
                      DropdownButtonFormField<int>(
                        value: selectedSessionId,
                        decoration: const InputDecoration(
                          labelText: 'Session *',
                          border: OutlineInputBorder(),
                        ),
                        items: sessions.map<DropdownMenuItem<int>>((s) {
                          return DropdownMenuItem(
                            value: s.id,
                            child: Text('Session #${s.id} - ${s.classTypeName}'),
                          );
                        }).toList(),
                        onChanged: (v) => setStateDialog(() => selectedSessionId = v),
                        validator: (v) => v == null ? 'Select a session' : null,
                      ),

                      const SizedBox(height: 24),

                      // =============== Rating ===============
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Rating:', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(
                                  '${rating.toStringAsFixed(1)} / 5.0',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            Slider(
                              value: rating,
                              min: 1.0,
                              max: 5.0,
                              divisions: 8,
                              label: rating.toStringAsFixed(1),
                              activeColor: AppTheme.primaryColor,
                              onChanged: (v) => setStateDialog(() => rating = v),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                5,
                                    (index) => Icon(
                                  index < rating.round() ? Icons.star : Icons.star_border,
                                  color: AppTheme.primaryColor,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // =============== Comments ===============
                      TextFormField(
                        controller: commentsController,
                        decoration: const InputDecoration(
                          labelText: 'Comments (Optional)',
                          border: OutlineInputBorder(),
                          hintText: 'Share your feedback...',
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      if (selectedMemberId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Error: Member ID is required')),
                        );
                        return;
                      }

                      if (selectedCoachId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Error: Coach ID is required')),
                        );
                        return;
                      }

                      context.read<FeedbackCubit>().createFeedbackAction(
                        CreateFeedbackModel(
                          memberId: selectedMemberId!,
                          coachId: selectedCoachId!,
                          sessionId: selectedSessionId!,
                          rating: rating,
                          comments: commentsController.text.trim().isEmpty
                              ? null
                              : commentsController.text.trim(),
                          timestamp: DateTime.now(),
                        ),
                      );
                      Navigator.pop(dialogContext);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Add Feedback', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ================== Edit Dialog ==================
  void _showEditFeedbackDialog(BuildContext context, FeedbackEntity item) {
    final formKey = GlobalKey<FormState>();
    final commentsController = TextEditingController(text: item.comments ?? '');
    double rating = item.rating;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Edit Feedback'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildInfoRow('Member', item.memberName),
                  const SizedBox(height: 4),
                  _buildInfoRow('Coach', item.coachName),
                  const SizedBox(height: 4),
                  _buildInfoRow('Session', item.sessionName),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Rating:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              '${rating.toStringAsFixed(1)} / 5.0',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: rating,
                          min: 1.0,
                          max: 5.0,
                          divisions: 8,
                          label: rating.toStringAsFixed(1),
                          activeColor: AppTheme.primaryColor,
                          onChanged: (v) => setStateDialog(() => rating = v),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            5,
                                (index) => Icon(
                              index < rating.round() ? Icons.star : Icons.star_border,
                              color: AppTheme.primaryColor,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: commentsController,
                    decoration: const InputDecoration(
                      labelText: 'Comments',
                      border: OutlineInputBorder(),
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
                context.read<FeedbackCubit>().updateFeedbackAction(
                  item.id,
                  UpdateFeedbackModel(
                    rating: rating,
                    comments: commentsController.text.trim(),
                  ),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text('Update', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int feedbackId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: AppTheme.errorColor),
            const SizedBox(width: 8),
            const Text('Delete Feedback'),
          ],
        ),
        content: const Text('Are you sure you want to delete this feedback? This action cannot be undone.'),
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

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ================== FeedbackCard ==================
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
                    colors: [ratingColor.withOpacity(0.2), ratingColor.withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                ),
                child: Icon(Icons.feedback, color: ratingColor, size: 24),
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
                        if (isOwnFeedback)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                    Text(item.sessionName, style: AppTheme.bodyMedium),
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
                    ...List.generate(
                      5,
                          (index) => Padding(
                        padding: const EdgeInsets.only(right: 2),
                        child: Icon(
                          index < item.rating.round() ? Icons.star : Icons.star_border,
                          size: 20,
                          color: ratingColor,
                        ),
                      ),
                    ),
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
                    Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(date, style: AppTheme.bodySmall),
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
                border: Border.all(color: AppTheme.textLight.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.comment, size: 18, color: AppTheme.textSecondary),
                  const SizedBox(width: AppTheme.spacingSM),
                  Expanded(child: Text(item.comments!, style: AppTheme.bodyMedium)),
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
                  Tooltip(
                    message: 'Edit',
                    child: IconButton(
                      icon: const Icon(Icons.edit_rounded),
                      color: AppTheme.infoColor,
                      onPressed: onEdit,
                    ),
                  ),
                if (onDelete != null)
                  Tooltip(
                    message: 'Delete',
                    child: IconButton(
                      icon: const Icon(Icons.delete_rounded),
                      color: AppTheme.errorColor,
                      onPressed: onDelete,
                    ),
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