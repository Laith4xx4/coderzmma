import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  @override
  void initState() {
    super.initState();
    context.read<ProgressCubit>().loadProgress();
    context.read<MemberCubit>().loadMembers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text(
          'Member Progress',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProgressDialog(context),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
            if (state.items.isEmpty) {
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
                    const Text(
                      'No progress records found.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
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
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return ProgressCard(
                    item: item,
                    onEdit: () => _showEditProgressDialog(context, item),
                    onDelete: () => _showDeleteDialog(context, item.id),
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

    final TextEditingController _setsController = TextEditingController();
    int? selectedMemberId;
    DateTime? progressDate;
    DateTime? promotionDate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Progress'),
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
                    validator: (value) =>
                        value == null ? 'Select a member' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Progress Date *',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      DateTime? date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        progressDate = date;
                      }
                    },
                    controller: TextEditingController(
                      text: progressDate != null
                          ? progressDate!.toLocal().toString().split(' ')[0]
                          : '',
                    ),
                    validator: (value) =>
                        progressDate == null ? 'Select date' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _setsController,
                    decoration: const InputDecoration(
                      labelText: 'Sets Completed *',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Promotion Date (Optional)',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      DateTime? date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        promotionDate = date;
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
              onPressed: () => Navigator.pop(context),
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
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Progress'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _setsController,
                    decoration: const InputDecoration(
                      labelText: 'Sets Completed *',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Promotion Date (Optional)',
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
                        promotionDate = date;
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
              onPressed: () => Navigator.pop(context),
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

  void _showDeleteDialog(BuildContext context, int progressId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Progress'),
        content: const Text(
          'Are you sure you want to delete this progress record?',
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
