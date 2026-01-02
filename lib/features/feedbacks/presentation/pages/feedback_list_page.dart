import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:thesavage/core/role_helper.dart';
import 'package:thesavage/core/app_theme.dart';
// import 'package:thesavage/widgets/modern_card.dart'; // Using inline custom styling for specific Stitch look
import 'package:thesavage/features/feedbacks/domain/entities/feedback_entity.dart';
import 'package:thesavage/features/feedbacks/data/models/create_feedback_model.dart';
import 'package:thesavage/features/feedbacks/data/models/update_feedback_model.dart';
import 'package:thesavage/features/feedbacks/presentation/bloc/feedback_cubit.dart';
import 'package:thesavage/features/feedbacks/presentation/bloc/feedback_state.dart';
import 'package:thesavage/features/memberpro/presentation/bloc/member_cubit.dart';
import 'package:thesavage/features/memberpro/presentation/bloc/member_state.dart';
import 'package:thesavage/features/coaches/presentation/bloc/coach_cubit.dart';
import 'package:thesavage/features/coaches/presentation/bloc/coach_state.dart';
import 'package:thesavage/features/sessions/presentation/bloc/session_cubit.dart';
import 'package:thesavage/features/sessions/presentation/bloc/session_state.dart';

class FeedbackListPage extends StatefulWidget {
  const FeedbackListPage({super.key});

  @override
  State<FeedbackListPage> createState() => _FeedbackListPageState();
}

class _FeedbackListPageState extends State<FeedbackListPage> {
  String _currentUserRole = '';
  int? _memberId;
  int? _coachId;
  String? _identityUserId;
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

    _identityUserId = prefs.getString('userId');
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
    if (_isMember && _memberId != null && feedback.senderType == 'Member' && feedback.memberId == _memberId) return true;
    if (_isCoach && _coachId != null && feedback.senderType == 'Coach' && feedback.coachId == _coachId) return true;
    return false;
  }

  bool _canDeleteFeedback(FeedbackEntity feedback) {
    return _canEditFeedback(feedback);
  }

  bool _canAddFeedback() => _isMember || _isCoach || _isAdmin;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Builder(
                builder: (context) {
                  final feedbackState = context.watch<FeedbackCubit>().state;
                  final memberState = context.watch<MemberCubit>().state;
                  final coachState = context.watch<CoachCubit>().state;

                  _resolveDomainId(context, memberState: memberState, coachState: coachState);

                  if (feedbackState is FeedbackLoading || memberState is MemberLoading || coachState is CoachLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
                  }

                  if (feedbackState is FeedbacksLoaded) {
                    final filteredFeedbacks = _filterFeedbacksByRole(feedbackState.feedbacks);

                    if (filteredFeedbacks.isEmpty) {
                      return _buildEmptyState();
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<FeedbackCubit>().loadFeedbacks();
                        context.read<MemberCubit>().loadMembers();
                        context.read<CoachCubit>().loadCoaches();
                      },
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                        children: [
                          _buildRatingSummary(filteredFeedbacks),
                          const SizedBox(height: 24),
                          Text("Recent Reviews", style: AppTheme.heading3.copyWith(fontSize: 18)),
                          const SizedBox(height: 16),
                          ...filteredFeedbacks.map((item) {
                            bool isByMe = false;
                            if (_isMember && _memberId != null) isByMe = item.senderType == 'Member' && item.memberId == _memberId;
                            if (_isCoach && _coachId != null) isByMe = isByMe || (item.senderType == 'Coach' && item.coachId == _coachId);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: FeedbackCard(
                                item: item,
                                onEdit: _canEditFeedback(item) ? () => _showEditFeedbackDialog(context, item) : null,
                                onDelete: _canDeleteFeedback(item) ? () => _showDeleteDialog(context, item.id) : null,
                                showOwnerBadge: _isAdmin,
                                isOwnFeedback: isByMe,
                                currentUserName: _currentUserName,
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  }

                  if (feedbackState is FeedbackError) {
                    return Center(child: Text('Error: ${feedbackState.message}', style: const TextStyle(color: Colors.red)));
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _canAddFeedback()
          ? FloatingActionButton.extended(
              onPressed: () => _showAddFeedbackDialog(context),
              backgroundColor: AppTheme.primaryColor,
              icon: const Icon(Icons.add_comment_rounded, color: Color(0xFF112117)),
              label: const Text('Add Review', style: TextStyle(color: Color(0xFF112117), fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.maybePop(context),
          ),
          Column(
            children: [
              Text("Feedbacks", style: AppTheme.heading3),
              Text(_isAdmin ? 'Management' : 'My Reviews', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
            ],
          ),
          // Role Badge
          Container(
             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
             decoration: BoxDecoration(
               color: Colors.white.withOpacity(0.1),
               borderRadius: BorderRadius.circular(12),
               border: Border.all(color: Colors.white.withOpacity(0.1)),
             ),
             child: Text(
               _currentUserRole.toUpperCase(),
               style: const TextStyle(color: AppTheme.primaryColor, fontSize: 10, fontWeight: FontWeight.bold),
             ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
     return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined, size: 64, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(
              "No feedback yet",
              style: AppTheme.bodyLarge.copyWith(color: Colors.grey),
            ),
          ],
        ),
     );
  }

  Widget _buildRatingSummary(List<FeedbackEntity> feedbacks) {
    if (feedbacks.isEmpty) return const SizedBox();

    double avg = feedbacks.map((e) => e.rating).reduce((a, b) => a + b) / feedbacks.length;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1A3224), const Color(0xFF112117)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Overall Rating", style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                     Text(avg.toStringAsFixed(1), style: GoogleFonts.lexend(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white, height: 1)),
                     const SizedBox(width: 8),
                     Padding(
                       padding: const EdgeInsets.only(bottom: 8.0),
                       child: Row(
                         children: List.generate(5, (index) => Icon(
                           index < avg.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                           color: const Color(0xFFFFD700), // Gold
                           size: 18,
                         )),
                       ),
                     )
                  ],
                ),
                const SizedBox(height: 8),
                Text("Based on ${feedbacks.length} reviews", style: AppTheme.bodySmall),
              ],
            ),
          ),
          // Maybe a progress bar chart here in future?
        ],
      ),
    );
  }

  // ================== Dialogs ================== (Keeping logic, updating UI)
  void _showAddFeedbackDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final commentsController = TextEditingController();

    final membersState = context.read<MemberCubit>().state;
    final coachesState = context.read<CoachCubit>().state;
    final sessionsState = context.read<SessionCubit>().state;

    final members = membersState is MembersLoaded ? membersState.members : [];
    final coaches = coachesState is CoachesLoaded ? coachesState.coaches : [];
    final sessions = sessionsState is SessionsLoaded ? sessionsState.sessions : [];

    if (sessions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No sessions available.'), backgroundColor: Colors.orange));
      return;
    }

    int? selectedMemberId;
    int? selectedCoachId;
    String senderRole = 'Member'; 

    if (_isAdmin) {
      if (members.isNotEmpty) selectedMemberId = members.first.id;
      if (coaches.isNotEmpty) selectedCoachId = coaches.first.id;
    } else {
      if (_isMember && _isCoach) {
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
    double rating = 5.0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            // Filter sessions by selected coach
            final filteredSessions = sessions.where((s) => s.coachId == selectedCoachId).toList();

            // Ensure selectedSessionId is valid for the current filteredSessions
            if (selectedSessionId != null && !filteredSessions.any((s) => s.id == selectedSessionId)) {
              selectedSessionId = filteredSessions.isNotEmpty ? filteredSessions.first.id : null;
            } else if (selectedSessionId == null && filteredSessions.isNotEmpty) {
              selectedSessionId = filteredSessions.first.id;
            }

            return AlertDialog(
              backgroundColor: AppTheme.cardBackground,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text("New Review", style: AppTheme.heading3),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       if (_isMember && _isCoach && !_isAdmin) ...[
                          // Dual Role Toggle (Simplified for brevity)
                          Row(children: [Text("Posting as $senderRole", style: const TextStyle(color: Colors.white))]),
                          const SizedBox(height: 16),
                       ],
                       // Member
                       if (_isAdmin || senderRole == 'Coach')
                          _buildDropdown<int>(
                             "Select Member",
                             selectedMemberId,
                             members.map<DropdownMenuItem<int>>((m) => DropdownMenuItem(value: m.id, child: Text(m.userName))).toList(),
                             (v) => setStateDialog(() => selectedMemberId = v),
                          )
                       else
                          _buildReadOnlyField("Member (Me)", _currentUserName ?? ''),

                       const SizedBox(height: 16),
                       // Coach
                       if (_isAdmin || senderRole == 'Member')
                          _buildDropdown<int>(
                             "Select Coach",
                             selectedCoachId,
                             coaches.map<DropdownMenuItem<int>>((c) => DropdownMenuItem(value: c.id, child: Text(c.userName))).toList(),
                             (v) => setStateDialog(() {
                               selectedCoachId = v;
                             }),
                          )
                       else
                          _buildReadOnlyField("Coach (Me)", _currentUserName ?? ''),

                       const SizedBox(height: 16),
                       // Session
                       _buildDropdown<int>(
                         "Select Session",
                         selectedSessionId,
                         filteredSessions.map<DropdownMenuItem<int>>((s) => DropdownMenuItem(value: s.id, child: Text('${s.sessionName} (${s.classTypeName})'))).toList(),
                         (v) => setStateDialog(() => selectedSessionId = v),
                       ),
                       
                       const SizedBox(height: 24),
                       Text("Rating: ${rating.toStringAsFixed(1)}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                       Slider(
                         value: rating, min: 1, max: 5, divisions: 4,
                         activeColor: AppTheme.primaryColor,
                         onChanged: (v) => setStateDialog(() => rating = v),
                       ),
                       
                       const SizedBox(height: 16),
                       TextFormField(
                         controller: commentsController,
                         maxLines: 3,
                         style: const TextStyle(color: Colors.white),
                         decoration: InputDecoration(
                           labelText: 'Comments',
                           labelStyle: const TextStyle(color: Colors.grey),
                           enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                           focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryColor)),
                         ),
                       )
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate() && selectedMemberId != null && selectedCoachId != null) {
                      context.read<FeedbackCubit>().createFeedbackAction(
                         CreateFeedbackModel(
                           memberId: selectedMemberId!,
                           coachId: selectedCoachId!,
                           sessionId: selectedSessionId!,
                           rating: rating,
                           comments: commentsController.text.trim().isEmpty ? null : commentsController.text.trim(),
                           timestamp: DateTime.now(),
                           senderType: senderRole
                         )
                      );
                      Navigator.pop(dialogContext);
                    }
                  },
                  style: AppTheme.primaryButtonStyle,
                  child: const Text("Submit"),
                )
              ],
            );
          },
        );
      },
    );
  }

  void _showEditFeedbackDialog(BuildContext context, FeedbackEntity item) {
    // Similar Logic, reused styles
    final commentsController = TextEditingController(text: item.comments ?? '');
    double rating = item.rating;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: AppTheme.cardBackground,
          title: Text("Edit Review", style: AppTheme.heading3),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               Text("Rating: ${rating.toStringAsFixed(1)}", style: const TextStyle(color: Colors.white)),
               Slider(
                 value: rating, min: 1, max: 5, divisions: 4,
                 activeColor: AppTheme.primaryColor,
                 onChanged: (v) => setState(() => rating = v),
               ),
               TextField(
                 controller: commentsController,
                 style: const TextStyle(color: Colors.white),
                 decoration: const InputDecoration(labelText: "Comments", labelStyle: TextStyle(color: Colors.grey)),
               )
            ],
          ),
          actions: [
             TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
             ElevatedButton(
               style: AppTheme.primaryButtonStyle,
               onPressed: () {
                 context.read<FeedbackCubit>().updateFeedbackAction(item.id, UpdateFeedbackModel(rating: rating, comments: commentsController.text));
                 Navigator.pop(context);
               },
               child: const Text("Update"),
             )
          ],
        )
      )
    );
  }

  void _showDeleteDialog(BuildContext context, int id) {
     showDialog(
       context: context,
       builder: (_) => AlertDialog(
          backgroundColor: AppTheme.cardBackground,
          title: const Text("Delete Review", style: TextStyle(color: Colors.white)),
          content: const Text("Are you sure?", style: TextStyle(color: Colors.grey)),
          actions: [
             TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
             TextButton(
               onPressed: () {
                 context.read<FeedbackCubit>().deleteFeedbackAction(id);
                 Navigator.pop(context);
               },
               child: const Text("Delete", style: TextStyle(color: Colors.red)),
             ),
          ],
       )
     );
  }

  Widget _buildDropdown<T>(String label, T? value, List<DropdownMenuItem<T>> items, ValueChanged<T?> onChanged) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items.map((e) => DropdownMenuItem<T>(
        value: e.value, 
        child: DefaultTextStyle(style: const TextStyle(color: Colors.white), child: e.child) // Fix text color in dropdown
      )).toList(),
      dropdownColor: AppTheme.cardBackground,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      style: const TextStyle(color: Colors.grey),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        fillColor: Colors.black12,
        filled: true,
        border: OutlineInputBorder(borderSide: BorderSide.none),
      ),
    );
  }
}

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
    // Resolving Names
    final String senderName = (isOwnFeedback && currentUserName != null) ? currentUserName! : (item.senderType == 'Coach' ? item.coachName : item.memberName);
    final String senderRole = item.senderType; 
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey.shade700,
                radius: 20,
                child: Icon(senderRole == 'Coach' ? Icons.sports : Icons.person, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(senderName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        Row(
                          children: List.generate(5, (i) => Icon(
                            i < item.rating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: const Color(0xFFFFD700),
                            size: 16,
                          )),
                        )
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "To: ${item.senderType == 'Coach' ? item.memberName : item.coachName} • ${item.sessionName}",
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.comments ?? "No additional comments.",
            style: TextStyle(color: Colors.grey.shade300, fontSize: 14, fontStyle: item.comments == null ? FontStyle.italic : FontStyle.normal),
          ),
          const SizedBox(height: 12),
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Text(
                 _timeAgo(item.timestamp),
                 style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
               ),
               if (onEdit != null || onDelete != null)
                 Row(
                   children: [
                     if (onEdit != null) IconButton(icon: const Icon(Icons.edit, color: Colors.grey, size: 18), onPressed: onEdit, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                     if (onEdit != null) const SizedBox(width: 12),
                     if (onDelete != null) IconButton(icon: const Icon(Icons.delete, color: AppTheme.errorColor, size: 18), onPressed: onDelete, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                   ],
                 )
             ],
           )
        ],
      ),
    );
  }

  String _timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays > 0) return "${diff.inDays} days ago";
    if (diff.inHours > 0) return "${diff.inHours} hours ago";
    if (diff.inMinutes > 0) return "${diff.inMinutes} mins ago";
    return "Just now";
  }
}