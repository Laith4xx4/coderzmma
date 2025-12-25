import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maa3/core/role_helper.dart';
import 'package:maa3/core/app_theme.dart';
import 'package:maa3/widgets/modern_card.dart';
import 'package:maa3/features/progress/domain/entities/member_progress_entity.dart';
import 'package:maa3/features/progress/data/models/create_member_progress_model.dart';
import 'package:maa3/features/progress/data/models/update_member_progress_model.dart';
import 'package:maa3/features/progress/presentation/bloc/progress_cubit.dart';
import 'package:maa3/features/progress/presentation/bloc/progress_state.dart';
import 'package:maa3/features/memberpro/presentation/bloc/member_cubit.dart';
import 'package:maa3/features/memberpro/presentation/bloc/member_state.dart';

class ProgressListPage extends StatefulWidget {
  const ProgressListPage({super.key});

  @override
  State<ProgressListPage> createState() => _ProgressListPageState();
}

class _ProgressListPageState extends State<ProgressListPage> {
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

  Future<void> _loadUserRoleAndData() async {
    final prefs = await SharedPreferences.getInstance();

    _currentUserRole = await RoleHelper.getCurrentUserRole();
    _isAdmin = await RoleHelper.isAdmin();
    _isCoach = await RoleHelper.isCoach();
    _isMember = await RoleHelper.isMember();

    // جلب الـ ID
    _currentUserId = prefs.getInt('userId');
    if (_currentUserId == null) {
      String? idString = prefs.getString('userId');
      if (idString != null) {
        _currentUserId = int.tryParse(idString);
      }
    }

    setState(() => _isLoading = false);

    if (mounted) {
      context.read<ProgressCubit>().loadProgress();
      context.read<MemberCubit>().loadMembers();
    }
  }

  List<MemberProgressEntity> _filterProgressByRole(List<MemberProgressEntity> items) {
    // Admin و Coach يرون كل شيء
    if (_isAdmin || _isCoach) return items;
    
    // Member يرى فقط التقدم الخاص به
    if (_isMember) {
      return items.where((item) => item.memberId == _currentUserId).toList();
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
        appBar: AppBar(
          backgroundColor: AppTheme.primaryColor,
          title: const Text(
            'Member Progress',
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
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            const Text(
              'Member Progress',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _currentUserRole,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        elevation: 0,
      ),
      floatingActionButton: _canAdd()
          ? FloatingActionButton(
              onPressed: () => _showAddProgressDialog(context),
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: BlocConsumer<ProgressCubit, ProgressState>(
        listener: (context, state) {
          if (state is ProgressOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ProgressError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProgressInitial || state is ProgressLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProgressLoaded) {
            final filteredItems = _filterProgressByRole(state.items);
            
            if (filteredItems.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.trending_up_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isMember 
                          ? 'No progress records found for you.'
                          : 'No progress records found.',
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProgressCubit>().loadProgress();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return ProgressCard(
                    item: item,
                    onEdit: _canEdit() ? () => _showEditProgressDialog(context, item) : null,
                    onDelete: _canDelete() ? () => _showDeleteDialog(context, item.id) : null,
                  );
                },
              ),
            );
          }

          if (state is ProgressError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load progress.\nError: ${state.message}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<ProgressCubit>().loadProgress(),
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
                  child: const Text('Add Progress', style: TextStyle(color: Colors.white)),
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
                  child: const Text('Update', style: TextStyle(color: Colors.white)),
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

class ProgressCard extends StatelessWidget {
  final MemberProgressEntity item;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProgressCard({
    super.key,
    required this.item,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final date = item.date.toLocal().toString().split(' ')[0];
    final promotionDate = item.promotionDate != null
        ? item.promotionDate!.toLocal().toString().split(' ')[0]
        : 'Not promoted yet';

    final isPromoted = item.promotionDate != null;

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GradientAvatar(
                icon: isPromoted ? Icons.star : Icons.trending_up,
                size: 56,
              ),
              const SizedBox(width: AppTheme.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.memberName,
                      style: AppTheme.heading3.copyWith(fontSize: 18),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: AppTheme.textLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          date,
                          style: AppTheme.bodyMedium.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isPromoted)
                StatusBadge(
                  text: 'Promoted',
                  color: AppTheme.successColor,
                  icon: Icons.star,
                )
              else
                StatusBadge(
                  text: 'In Progress',
                  color: AppTheme.warningColor,
                  icon: Icons.trending_up,
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
                    icon: Icons.fitness_center,
                    label: 'Sets Completed',
                    value: '${item.setsCompleted}',
                  ),
                ),
                if (isPromoted) ...[
                  Container(
                    width: 1,
                    height: 40,
                    color: AppTheme.textLight.withOpacity(0.2),
                  ),
                  Expanded(
                    child: StatItem(
                      icon: Icons.star,
                      label: 'Promoted On',
                      value: promotionDate,
                      iconColor: AppTheme.successColor,
                    ),
                  ),
                ],
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
