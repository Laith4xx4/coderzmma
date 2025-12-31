import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thesavage/core/role_helper.dart';
import 'package:thesavage/core/app_theme.dart';
import 'package:thesavage/widgets/modern_card.dart';
import 'package:thesavage/features/progress/domain/entities/member_progress_entity.dart';
import 'package:thesavage/features/progress/data/models/create_member_progress_model.dart';
import 'package:thesavage/features/progress/data/models/update_member_progress_model.dart';
import 'package:thesavage/features/progress/presentation/bloc/progress_cubit.dart';
import 'package:thesavage/features/progress/presentation/bloc/progress_state.dart';
import 'package:thesavage/features/memberpro/presentation/bloc/member_cubit.dart';
import 'package:thesavage/features/memberpro/presentation/bloc/member_state.dart';
import 'package:thesavage/features/coaches/presentation/bloc/coach_cubit.dart';
import 'package:thesavage/features/coaches/presentation/bloc/coach_state.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';

class ProgressListPage extends StatefulWidget {
  const ProgressListPage({super.key});

  @override
  State<ProgressListPage> createState() => _ProgressListPageState();
}

class _ProgressListPageState extends State<ProgressListPage> {
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

    _identityUserId = prefs.getString('userGuid'); 
    _currentUserName = prefs.getString('userName');

    setState(() => _isLoading = false);

    if (mounted) {
      context.read<ProgressCubit>().loadProgress();
      context.read<MemberCubit>().loadMembers();
      context.read<CoachCubit>().loadCoaches();
    }
  }

  bool _resolveDomainIds(BuildContext context, {MemberState? memberState, CoachState? coachState}) {
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

  List<MemberProgressEntity> _filterProgressByRole(List<MemberProgressEntity> items) {
    // Admin و Coach يرون كل شيء
    if (_isAdmin || _isCoach) return items;
    
    // Member يرى فقط التقدم الخاص به
    if (_isMember && _memberId != null) {
      return items.where((item) => item.memberId == _memberId).toList();
    }
    
    return items;
  }

  bool _canEdit() => _isAdmin || _isCoach;
  bool _canDelete() => _isAdmin || _isCoach;
  bool _canAdd() => _isAdmin || _isCoach;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Builder(
      builder: (context) {
        final memberState = context.watch<MemberCubit>().state;
        final coachState = context.watch<CoachCubit>().state;

        final resolved = _resolveDomainIds(context, memberState: memberState, coachState: coachState);

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: _buildAppBar(),
          floatingActionButton: _canAdd()
              ? FloatingActionButton(
                  onPressed: resolved ? () => _showAddProgressDialog(context) : null,
                  backgroundColor: AppTheme.primaryColor,
                  elevation: 2,
                  child: const Icon(Icons.add_rounded, color: Colors.black, size: 30),
                )
              : null,
          body: BlocConsumer<ProgressCubit, ProgressState>(
            listener: (context, state) {
              if (state is ProgressOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: Colors.green),
                );
              } else if (state is ProgressError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${state.message}'), backgroundColor: Colors.red),
                );
              }
            },
            builder: (context, state) {
              if (state is ProgressInitial || state is ProgressLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ProgressLoaded) {
                final filteredItems = _filterProgressByRole(state.items);
                filteredItems.sort((a, b) => b.date.compareTo(a.date));

                if (filteredItems.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView(
                  padding: const EdgeInsets.all(AppTheme.spacingMD),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    if (_isMember && filteredItems.isNotEmpty)
                      _buildProgressDashboard(filteredItems),
                    ...filteredItems.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ProgressCard(
                            item: item,
                            onEdit: _canEdit() ? () => _showEditProgressDialog(context, item) : null,
                            onDelete: _canDelete() ? () => _showDeleteDialog(context, item.id) : null,
                            showChartToggle: _isAdmin || _isCoach,
                            allMemberProgress: state.items.where((i) => i.memberId == item.memberId).toList(),
                          ),
                        )),
                    const SizedBox(height: 100), // Space for FAB
                  ],
                );
              }

              return _buildErrorState(state);
            },
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.primaryDark,
      iconTheme: const IconThemeData(color: Colors.white),
      centerTitle: true,
      title: const Text(
        'MEMBER PROGRESS',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
          fontSize: 18,
        ),
      ),
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _currentUserRole.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressDashboard(List<MemberProgressEntity> items) {
    // If we are a member, the items are already filtered by _filterProgressByRole
    // but just to be safe and ensure the graph is sorted correctly:
    final List<MemberProgressEntity> myProgress = List.from(items);
    myProgress.sort((a, b) => a.date.compareTo(b.date)); // Oldest to newest for graph

    if (myProgress.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatsRow(myProgress),
        const SizedBox(height: 16),
        _buildChartCard(myProgress),
      ],
    );
  }

  Widget _buildStatsRow(List<MemberProgressEntity> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    
    final totalSets = items.fold(0, (sum, i) => sum + i.setsCompleted);
    final avgSets = (totalSets / items.length).toStringAsFixed(1);
    final lastPromotion = items.any((i) => i.promotionDate != null) 
      ? items.lastWhere((i) => i.promotionDate != null).promotionDate!.toLocal().toString().split(' ')[0]
      : 'None';

    return Row(
      children: [
        Expanded(child: _buildStatMiniCard('Total Sets', totalSets.toString(), Icons.fitness_center, Colors.orange)),
        const SizedBox(width: 8),
        Expanded(child: _buildStatMiniCard('Avg Sets', avgSets, Icons.trending_up, Colors.blue)),
        const SizedBox(width: 8),
        Expanded(child: _buildStatMiniCard('Last Promo', lastPromotion, Icons.star, Colors.amber)),
      ],
    );
  }

  Widget _buildStatMiniCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildChartCard(List<MemberProgressEntity> items) {
    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(8, 24, 24, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
      ),
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (spot) => AppTheme.primaryColor.withOpacity(0.8),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final date = items[spot.x.toInt()].date;
                  return LineTooltipItem(
                    '${date.day}/${date.month}\n',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    children: [
                      TextSpan(
                        text: '${spot.y.toInt()} Sets',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 10),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
            handleBuiltInTouches: true,
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: items.length > 5 ? (items.length / 5).ceil().toDouble() : 1,
                getTitlesWidget: (value, meta) {
                  final int index = value.toInt();
                  if (index >= 0 && index < items.length) {
                    final date = items[index].date;
                    // Show only some labels if there are many items
                    return SideTitleWidget(
                      meta: meta,
                      child: Text('${date.day}/${date.month}', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 5,

                getTitlesWidget: (value, meta) => SideTitleWidget(
                  meta: meta,
                  child: Text(value.toInt().toString(), style: const TextStyle(color: Colors.grey, fontSize: 10)),
                ),
                reservedSize: 28,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: items.length > 1 ? (items.length - 1).toDouble() : 0,
          minY: 0,
          maxY: items.isNotEmpty ? (items.map((e) => e.setsCompleted).reduce((a, b) => a > b ? a : b) + 5).toDouble() : 20,
          lineBarsData: [
            LineChartBarData(
              spots: items.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.setsCompleted.toDouble())).toList(),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: AppTheme.primaryColor,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor.withOpacity(0.3), AppTheme.primaryColor.withOpacity(0.0)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.trending_up_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            _isMember ? 'No progress records found for you.' : 'No progress records found.',
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ProgressState state) {
    String message = 'Something went wrong.';
    if (state is ProgressError) message = state.message;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Failed to load progress.\nError: $message',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<ProgressCubit>().loadProgress(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showAddProgressDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final membersState = context.read<MemberCubit>().state;

    List<dynamic> members = [];
    if (membersState is MembersLoaded) {
      members = membersState.members;
    }

    if (members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No members available. Please add members first.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final TextEditingController _setsController = TextEditingController();
    int? selectedMemberId = members.first.id;
    DateTime? progressDate = DateTime.now();
    DateTime? promotionDate;

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
                  const Text('Add Progress'),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _currentUserRole,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
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
                      DropdownButtonFormField<int>(
                        value: selectedMemberId,
                        decoration: const InputDecoration(
                          labelText: 'Member *',
                          border: OutlineInputBorder(),
                        ),
                        items: members.map<DropdownMenuItem<int>>((member) {
                          return DropdownMenuItem<int>(
                            value: member.id,
                            child: Text(member.userName ?? 'Member ${member.id}'),
                          );
                        }).toList(),
                        onChanged: (value) => setStateDialog(() => selectedMemberId = value),
                        validator: (value) => value == null ? 'Select a member' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Progress Date *',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        onTap: () async {
                          DateTime? date = await showDatePicker(
                            context: context,
                            initialDate: progressDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setStateDialog(() => progressDate = date);
                          }
                        },
                        controller: TextEditingController(
                          text: progressDate != null
                              ? progressDate!.toLocal().toString().split(' ')[0]
                              : '',
                        ),
                        validator: (value) => progressDate == null ? 'Select date' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _setsController,
                        decoration: const InputDecoration(
                          labelText: 'Sets Completed *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Promotion Date (Optional)',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        onTap: () async {
                          DateTime? date = await showDatePicker(
                            context: context,
                            initialDate: promotionDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setStateDialog(() => promotionDate = date);
                          }
                        },
                        controller: TextEditingController(
                          text: promotionDate != null
                              ? promotionDate!.toLocal().toString().split(' ')[0]
                              : '',
                        ),
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
                    if (_formKey.currentState!.validate() &&
                        selectedMemberId != null &&
                        progressDate != null) {
                      context.read<ProgressCubit>().createProgressAction(
                        CreateMemberProgressModel(
                          memberId: selectedMemberId!,
                          date: progressDate!,
                          setsCompleted: int.parse(_setsController.text),
                          promotionDate: promotionDate,
                        ),
                      );
                      Navigator.pop(dialogContext);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Add Progress', style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditProgressDialog(
    BuildContext context,
    MemberProgressEntity item,
  ) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _setsController = TextEditingController(
      text: item.setsCompleted.toString(),
    );
    DateTime? promotionDate = item.promotionDate;

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
                  const Text('Edit Progress'),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _currentUserRole,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
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
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person, size: 20, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Member',
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  Text(
                                    item.memberName,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _setsController,
                        decoration: const InputDecoration(
                          labelText: 'Sets Completed *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Promotion Date (Optional)',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        onTap: () async {
                          DateTime? date = await showDatePicker(
                            context: context,
                            initialDate: promotionDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setStateDialog(() => promotionDate = date);
                          }
                        },
                        controller: TextEditingController(
                          text: promotionDate != null
                              ? promotionDate!.toLocal().toString().split(' ')[0]
                              : '',
                        ),
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
                    if (_formKey.currentState!.validate()) {
                      context.read<ProgressCubit>().updateProgressAction(
                        item.id,
                        UpdateMemberProgressModel(
                          setsCompleted: int.parse(_setsController.text),
                          promotionDate: promotionDate,
                        ),
                      );
                      Navigator.pop(dialogContext);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: const Text('Update', style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, int progressId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: AppTheme.errorColor),
            const SizedBox(width: 8),
            const Text('Delete Progress'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this progress record? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ProgressCubit>().deleteProgressAction(progressId);
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

class ProgressCard extends StatefulWidget {
  final MemberProgressEntity item;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showChartToggle;
  final List<MemberProgressEntity>? allMemberProgress;

  const ProgressCard({
    super.key,
    required this.item,
    this.onEdit,
    this.onDelete,
    this.showChartToggle = false,
    this.allMemberProgress,
  });

  @override
  State<ProgressCard> createState() => _ProgressCardState();
}

class _ProgressCardState extends State<ProgressCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final date = item.date.toLocal().toString().split(' ')[0];
    final promotionDate = item.promotionDate != null
        ? item.promotionDate!.toLocal().toString().split(' ')[0]
        : 'Not promoted yet';

    final isPromoted = item.promotionDate != null;

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: widget.showChartToggle ? () => setState(() => _isExpanded = !_isExpanded) : null,
            child: Row(
              children: [
                GradientAvatar(
                  icon: isPromoted ? Icons.star : Icons.trending_up,
                  size: 50,
                ),
                const SizedBox(width: AppTheme.spacingMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.memberName,
                        style: AppTheme.heading3.copyWith(fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: AppTheme.bodyMedium.copyWith(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                if (isPromoted)
                  StatusBadge(
                    text: 'Promoted',
                    color: AppTheme.successColor,
                    icon: Icons.star,
                  ),
                if (widget.showChartToggle)
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
              ],
            ),
          ),
          if (_isExpanded && widget.allMemberProgress != null) ...[
            const SizedBox(height: 16),
            const Text('Member Progress History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            SizedBox(
              height: 150,
              child: _buildMiniChart(widget.allMemberProgress!),
            ),
          ],
          const SizedBox(height: 16),
          _buildDetailRow(item, isPromoted, promotionDate),
          if (widget.onEdit != null || widget.onDelete != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.onEdit != null)
                  ActionButton(
                    icon: Icons.edit_rounded,
                    color: AppTheme.infoColor,
                    onPressed: widget.onEdit!,
                    tooltip: 'Edit',
                  ),
                if (widget.onEdit != null && widget.onDelete != null)
                  const SizedBox(width: 8),
                if (widget.onDelete != null)
                  ActionButton(
                    icon: Icons.delete_rounded,
                    color: AppTheme.errorColor,
                    onPressed: widget.onDelete!,
                    tooltip: 'Delete',
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniChart(List<MemberProgressEntity> items) {
    items.sort((a, b) => a.date.compareTo(b.date));
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: items.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.setsCompleted.toDouble())).toList(),
            isCurved: true,
            gradient: LinearGradient(colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.5)]),
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [AppTheme.primaryColor.withOpacity(0.1), Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(MemberProgressEntity item, bool isPromoted, String promotionDate) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatValue(
              icon: Icons.fitness_center,
              label: 'Sets',
              value: '${item.setsCompleted}',
            ),
          ),
          if (isPromoted) ...[
            Container(width: 1, height: 24, color: Colors.grey.withOpacity(0.2)),
            Expanded(
              child: _StatValue(
                icon: Icons.star_border,
                label: 'Promo',
                value: promotionDate,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatValue extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatValue({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
      ],
    );
  }
}
