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
  int? _memberId; 
  int? _coachId; 
  String? _identityUserId; // The Auth0/Identity UserID (String)
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

    // Get the Identity User ID (String)
    _identityUserId = prefs.getString('userId');

    // Get Name
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

  // Helper to resolve Domain ID from Identity ID
  bool _resolveDomainId(BuildContext context, {MemberState? memberState, CoachState? coachState}) {
    if (_isAdmin) return true;
    
    bool memberResolved = _memberId != null;
    bool coachResolved = _coachId != null;
    
    if (memberResolved && coachResolved) return true;
    if (_identityUserId == null) return false;

    memberState ??= context.read<MemberCubit>().state;
    coachState ??= context.read<CoachCubit>().state;

    if (_isMember && !memberResolved && memberState is MembersLoaded) {
      try {
        final me = memberState.members.firstWhere((m) => m.userId == _identityUserId);
        _memberId = me.id;
        memberResolved = true;
      } catch (_) {}
    }
    
    if (_isCoach && !coachResolved && coachState is CoachesLoaded) {
      try {
        final me = coachState.coaches.firstWhere((c) => c.userId == _identityUserId);
        _coachId = me.id;
        coachResolved = true;
      } catch (_) {}
    }

    return memberResolved || coachResolved;
  }

  List<FeedbackEntity> _filterFeedbacksByRole(List<FeedbackEntity> feedbacks) {
    if (_isAdmin) return feedbacks;

    return feedbacks.where((f) {
      bool isRelevant = false;
      if (_isMember && _memberId != null && f.memberId == _memberId) {
        isRelevant = true;
      }
      if (_isCoach && _coachId != null && f.coachId == _coachId) {
        isRelevant = true;
      }
      return isRelevant;
    }).toList();
  }

  bool _canEditFeedback(FeedbackEntity feedback) {
    if (_isAdmin) return true;
    if (_isMember && _memberId != null) {
      if (feedback.senderType == 'Member' && feedback.memberId == _memberId) return true;
    }
    if (_isCoach && _coachId != null) {
      if (feedback.senderType == 'Coach' && feedback.coachId == _coachId) return true;
    }
    return false;
  }

  bool _canDeleteFeedback(FeedbackEntity feedback) {
    if (_isAdmin) return true;
    if (_isMember && _memberId != null) {
      if (feedback.senderType == 'Member' && feedback.memberId == _memberId) return true;
    }
    if (_isCoach && _coachId != null) {
      if (feedback.senderType == 'Coach' && feedback.coachId == _coachId) return true;
    }
    return false;
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
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Feedbacks', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
            Text(_isAdmin ? 'Management' : 'My Reviews', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Text(
                  _currentUserRole.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _canAddFeedback()
          ? FloatingActionButton.extended(
              onPressed: () => _showAddFeedbackDialog(context),
              backgroundColor: AppTheme.primaryColor,
              icon: const Icon(Icons.add_comment_rounded, color: Colors.white),
              label: const Text('Add Review', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
      body: Builder(
        builder: (context) {
          final feedbackState = context.watch<FeedbackCubit>().state;
          final memberState = context.watch<MemberCubit>().state;
          final coachState = context.watch<CoachCubit>().state;
          final sessionState = context.watch<SessionCubit>().state;

          // Attempt to resolve Domain ID if missing
          _resolveDomainId(context, memberState: memberState, coachState: coachState);

          if (feedbackState is FeedbackLoading || memberState is MemberLoading || coachState is CoachLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (feedbackState is FeedbacksLoaded) {
            final filteredFeedbacks = _filterFeedbacksByRole(feedbackState.feedbacks);

            if (filteredFeedbacks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.feedback_outlined, size: 80, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _isAdmin ? 'No records yet.' : 'You haven\'t received or sent any reviews.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                    if (!_isAdmin) ...[
                      const SizedBox(height: 8),
                      const Text('Add your first feedback now!', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<FeedbackCubit>().loadFeedbacks();
                context.read<MemberCubit>().loadMembers();
                context.read<CoachCubit>().loadCoaches();
              },
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: filteredFeedbacks.length,
                itemBuilder: (context, index) {
                  final item = filteredFeedbacks[index];
                  // If Admin, show everything. If Member/Coach, check if it's sent by them
                  bool isByMe = false;
                  if (_isMember && _memberId != null) isByMe = item.senderType == 'Member' && item.memberId == _memberId;
                  if (_isCoach && _coachId != null) isByMe = isByMe || (item.senderType == 'Coach' && item.coachId == _coachId);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FeedbackCard(
                      item: item,
                      onEdit: _canEditFeedback(item) ? () => _showEditFeedbackDialog(context, item) : null,
                      onDelete: _canDeleteFeedback(item) ? () => _showDeleteDialog(context, item.id) : null,
                      showOwnerBadge: _isAdmin,
                      isOwnFeedback: isByMe,
                      currentUserName: _currentUserName,
                    ),
                  );
                },
              ),
            );
          }

          if (feedbackState is FeedbackError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 64, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text('Failed to load: ${feedbackState.message}', style: const TextStyle(color: Colors.redAccent)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<FeedbackCubit>().loadFeedbacks(),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Initializing...'));
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
    String senderRole = 'Member'; 

    if (_isAdmin) {
      if (members.isNotEmpty) selectedMemberId = members.first.id;
      if (coaches.isNotEmpty) selectedCoachId = coaches.first.id;
    } else {
      if (_isMember && _isCoach) {
        // Dual role: Default to acting as Member
        selectedMemberId = _memberId;
        if (coaches.isNotEmpty) selectedCoachId = coaches.first.id;
        senderRole = 'Member';
      } else if (_isMember) {
        selectedMemberId = _memberId;
        if (coaches.isNotEmpty) selectedCoachId = coaches.first.id;
        senderRole = 'Member';
      } else if (_isCoach) {
        selectedCoachId = _coachId;
        if (members.isNotEmpty) selectedMemberId = members.first.id;
        senderRole = 'Coach';
      }
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
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              titlePadding: EdgeInsets.zero,
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              title: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.add_comment_rounded, color: AppTheme.primaryColor),
                    const SizedBox(width: 12),
                    const Text('New Review', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(dialogContext),
                      style: IconButton.styleFrom(backgroundColor: Colors.white, padding: EdgeInsets.all(4)),
                    ),
                  ],
                ),
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // =============== Dual Role Selector ===============
                      if (_isMember && _isCoach && !_isAdmin) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              _buildRoleToggleItem(
                                context,
                                'As Member',
                                Icons.person_outline_rounded,
                                senderRole == 'Member',
                                () => setStateDialog(() {
                                  senderRole = 'Member';
                                  selectedMemberId = _memberId;
                                  if (coaches.isNotEmpty) selectedCoachId = coaches.first.id;
                                }),
                              ),
                              _buildRoleToggleItem(
                                context,
                                'As Coach',
                                Icons.sports_rounded,
                                senderRole == 'Coach',
                                () => setStateDialog(() {
                                  senderRole = 'Coach';
                                  selectedCoachId = _coachId;
                                  if (members.isNotEmpty) selectedMemberId = members.first.id;
                                }),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // =============== Member Selection ===============
                      if (_isAdmin || senderRole == 'Coach')
                        _buildDropdownField<int>(
                          label: 'Select Member',
                          icon: Icons.person_rounded,
                          value: selectedMemberId,
                          items: members.map((m) => DropdownMenuItem<int>(value: m.id, child: Text(m.userName ?? 'Member ${m.id}'))).toList(),
                          onChanged: (v) => setStateDialog(() => selectedMemberId = v),
                        )
                      else if (senderRole == 'Member')
                        _buildLockedField(label: 'Member (Me)', value: _currentUserName ?? 'My Account', icon: Icons.person),

                      const SizedBox(height: 16),

                      // =============== Coach Selection ===============
                      if (_isAdmin || senderRole == 'Member')
                        _buildDropdownField<int>(
                          label: 'Select Coach',
                          icon: Icons.sports_rounded,
                          value: selectedCoachId,
                          items: coaches.map((c) => DropdownMenuItem<int>(value: c.id, child: Text(c.userName ?? 'Coach ${c.id}'))).toList(),
                          onChanged: (v) => setStateDialog(() => selectedCoachId = v),
                        )
                      else if (senderRole == 'Coach')
                        _buildLockedField(label: 'Coach (Me)', value: _currentUserName ?? 'My Account', icon: Icons.sports),

                      const SizedBox(height: 16),

                      // =============== Session Selection ===============
                      _buildDropdownField<int>(
                        label: 'Select Session',
                        icon: Icons.event_note_rounded,
                        value: selectedSessionId,
                        items: sessions.map((s) => DropdownMenuItem<int>(value: s.id, child: Text('Session #${s.id} - ${s.classTypeName}'))).toList(),
                        onChanged: (v) => setStateDialog(() => selectedSessionId = v),
                      ),

                      const SizedBox(height: 24),

                      // =============== Rating Section ===============
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Rate Performance', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(12)),
                                  child: Text('${rating.toStringAsFixed(1)} / 5.0', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Slider(
                              value: rating,
                              min: 1.0,
                              max: 5.0,
                              divisions: 8,
                              activeColor: AppTheme.primaryColor,
                              onChanged: (v) => setStateDialog(() => rating = v),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (i) {
                                final isFull = i < rating.floor();
                                final isHalf = i == rating.floor() && rating % 1.0 >= 0.5;
                                return Icon(
                                  isFull ? Icons.star_rounded : (isHalf ? Icons.star_half_rounded : Icons.star_outline_rounded),
                                  color: AppTheme.primaryColor,
                                  size: 32,
                                );
                              }),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // =============== Comments ===============
                      TextFormField(
                        controller: commentsController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Feedback Comments',
                          hintText: 'Share your thoughts...',
                          alignLabelWithHint: true,
                          fillColor: Colors.grey.shade50,
                          filled: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          prefixIcon: const Padding(padding: EdgeInsets.only(bottom: 50), child: Icon(Icons.description_outlined)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            if (selectedMemberId == null || selectedCoachId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Member and Coach IDs are required')));
                                return;
                            }
                            context.read<FeedbackCubit>().createFeedbackAction(
                              CreateFeedbackModel(
                                memberId: selectedMemberId!,
                                coachId: selectedCoachId!,
                                sessionId: selectedSessionId!,
                                rating: rating,
                                comments: commentsController.text.trim().isEmpty ? null : commentsController.text.trim(),
                                timestamp: DateTime.now(),
                                senderType: senderRole,
                              ),
                            );
                            Navigator.pop(dialogContext);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text('Submit Review', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildRoleToggleItem(BuildContext context, String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? AppTheme.primaryColor : Colors.grey),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppTheme.primaryColor : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField<T>({required String label, required IconData icon, required T? value, required List<DropdownMenuItem<T>> items, required ValueChanged<T?> onChanged}) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: items,
      onChanged: onChanged,
      validator: (v) => v == null ? 'Selection required' : null,
    );
  }

  Widget _buildLockedField({required String label, required String value, required IconData icon}) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        prefixIcon: Icon(icon, size: 20, color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Row(
        children: [
          Expanded(child: Text(value, style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600))),
          const Icon(Icons.lock_rounded, size: 14, color: Colors.grey),
        ],
      ),
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
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          titlePadding: EdgeInsets.zero,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          title: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.infoColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
            ),
            child: Row(
              children: [
                const Icon(Icons.mode_edit_outline_rounded, color: AppTheme.infoColor),
                const SizedBox(width: 12),
                const Text('Edit Review', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(backgroundColor: Colors.white, padding: EdgeInsets.all(4)),
                ),
              ],
            ),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _buildCompactInfo('To', item.senderType == 'Coach' ? item.memberName : item.coachName, Icons.person_outline_rounded),
                        const Divider(height: 16),
                        _buildCompactInfo('Session', item.sessionName, Icons.history_edu_rounded),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Update Rating', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(12)),
                              child: Text('${rating.toStringAsFixed(1)} / 5.0', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Slider(
                          value: rating,
                          min: 1.0,
                          max: 5.0,
                          divisions: 8,
                          activeColor: AppTheme.primaryColor,
                          onChanged: (v) => setStateDialog(() => rating = v),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (i) {
                            final isFull = i < rating.floor();
                            return Icon(
                              isFull ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: AppTheme.primaryColor,
                              size: 32,
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: commentsController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Comments',
                      fillColor: Colors.grey.shade50,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      prefixIcon: const Padding(padding: EdgeInsets.only(bottom: 50), child: Icon(Icons.description_outlined)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          actions: [
             Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
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
                      backgroundColor: AppTheme.infoColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('Update Review', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactInfo(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87), overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, int feedbackId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        title: Icon(Icons.delete_forever_rounded, color: AppTheme.errorColor, size: 48),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Delete Review?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 12),
            Text(
              'This action cannot be undone. Are you sure you want to remove this feedback?',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.all(24),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<FeedbackCubit>().deleteFeedbackAction(feedbackId);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
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
  final String? currentUserName;

  const FeedbackCard({
    super.key,
    required this.item,
    this.onEdit,
    this.onDelete,
    this.showOwnerBadge = false,
    this.isOwnFeedback = false,
    this.currentUserName,
  });

  @override
  Widget build(BuildContext context) {
    final date = item.timestamp.toLocal().toString().split(' ')[0];
    final ratingColor = _getRatingColor(item.rating);

    // Determine Sender and Receiver names
    final String senderNameFromItem = item.senderType == 'Coach' ? item.coachName : item.memberName;
    final String senderName = (isOwnFeedback && currentUserName != null) ? currentUserName! : senderNameFromItem;
    
    final String receiverName = item.senderType == 'Coach' ? item.memberName : item.coachName;
    final String senderRole = item.senderType == 'Coach' ? 'Coach' : 'Member';
    final String receiverRole = item.senderType == 'Coach' ? 'Member' : 'Coach';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Header: Sender and Timestamp
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: ratingColor.withOpacity(0.05),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: ratingColor.withOpacity(0.1),
                    child: Icon(
                      item.senderType == 'Coach' ? Icons.sports_rounded : Icons.person_rounded,
                      size: 18,
                      color: ratingColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              senderName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            if (isOwnFeedback)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'YOU',
                                  style: TextStyle(fontSize: 9, color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          '$senderRole Review',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    date,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Relationship Row
                  Row(
                    children: [
                      Icon(Icons.arrow_right_alt_rounded, color: Colors.grey.shade400, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'To: ',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                      ),
                      Text(
                        receiverName,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '($receiverRole)',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Session info
                  Row(
                    children: [
                      Icon(Icons.event_note_rounded, color: Colors.grey.shade400, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.sessionName,
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const Divider(height: 32),

                  // Rating and Comments
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: ratingColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.white, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              item.rating.toStringAsFixed(1),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          item.comments ?? 'No comment provided.',
                          style: TextStyle(
                            fontSize: 14,
                            color: item.comments != null ? Colors.black87 : Colors.grey.shade400,
                            fontStyle: item.comments != null ? FontStyle.normal : FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Action Buttons
                  if (onEdit != null || onDelete != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (onEdit != null)
                          TextButton.icon(
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('Edit', style: TextStyle(fontSize: 12)),
                            style: TextButton.styleFrom(foregroundColor: AppTheme.infoColor),
                          ),
                        if (onDelete != null)
                          TextButton.icon(
                            onPressed: onDelete,
                            icon: const Icon(Icons.delete_outline_rounded, size: 18),
                            label: const Text('Delete', style: TextStyle(fontSize: 12)),
                            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.0) return AppTheme.successColor;
    if (rating >= 3.0) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }
}