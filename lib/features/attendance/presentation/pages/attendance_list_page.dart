import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maa3/core/role_helper.dart';
import 'package:maa3/core/app_theme.dart';
import 'package:maa3/widgets/modern_card.dart';
// تأكد من وجود الموديل الخاص بالإضافة، أو قم بإنشائه
import 'package:maa3/features/attendance/data/models/create_attendance_model.dart';
import 'package:maa3/features/attendance/domain/entities/attendance_entity.dart';
import 'package:maa3/features/attendance/presentation/bloc/attendance_cubit.dart';
import 'package:maa3/features/attendance/presentation/bloc/attendance_state.dart';

class AttendanceListPage extends StatefulWidget {
  const AttendanceListPage({super.key});

  @override
  State<AttendanceListPage> createState() => _AttendanceListPageState();
}

class _AttendanceListPageState extends State<AttendanceListPage> {
  bool canManage = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    context.read<AttendanceCubit>().loadAttendances();
  }

  Future<void> _checkPermissions() async {
    // التحقق من صلاحية إدارة الحضور (للمدربين أو الأدمن)
    final canManageAttendance = await RoleHelper.canManageAttendance();
    setState(() {
      canManage = canManageAttendance;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text(
          'Attendance Records',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      floatingActionButton: canManage
          ? FloatingActionButton(
        onPressed: () => _showAddAttendanceDialog(context),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
      body: BlocConsumer<AttendanceCubit, AttendanceState>(
        listener: (context, state) {
          if (state is AttendanceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AttendanceInitial || state is AttendanceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AttendancesLoaded) {
            if (state.attendances.isEmpty) {
              return const Center(child: Text('No attendance records found.'));
            }
            return ListView.builder(
              itemCount: state.attendances.length,
              itemBuilder: (context, index) {
                final attendance = state.attendances[index];
                return AttendanceCard(
                  attendance: attendance,
                  canDelete: canManage,
                  onDelete: canManage
                      ? () => _showDeleteDialog(context, attendance.id)
                      : null,
                );
              },
            );
          }

          return const Center(child: Text('Something went wrong.'));
        },
      ),
    );
  }

  // نافذة إضافة حضور يدوي (مبسطة)
  void _showAddAttendanceDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _sessionIdController = TextEditingController();
    final TextEditingController _memberIdController = TextEditingController();
    String selectedStatus = 'Present'; // القيمة الظاهرة في القائمة

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Mark Attendance'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _sessionIdController,
                    decoration: const InputDecoration(labelText: 'Session ID'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Enter Session ID' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _memberIdController,
                    decoration: const InputDecoration(labelText: 'Member ID'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Enter Member ID' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: ['Present', 'Absent', 'Late', 'Excused']
                        .map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    ))
                        .toList(),
                    onChanged: (value) => selectedStatus = value!,
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
                  // تحويل الحالة النصية إلى رقم (حسب نظام الباك اند لديك)
                  // مثال: 1=حاضر، 0=غائب، 2=متأخر، 3=معذور
                  int statusCode;
                  switch (selectedStatus) {
                    case 'Present':
                      statusCode = 1;
                      break;
                    case 'Absent':
                      statusCode = 0;
                      break;
                    case 'Late':
                      statusCode = 2;
                      break;
                    case 'Excused':
                      statusCode = 3;
                      break;
                    default:
                      statusCode = 1;
                  }

                  final data = CreateAttendanceModel(
                    sessionId: int.parse(_sessionIdController.text),
                    memberId: int.parse(_memberIdController.text),
                    status: statusCode, // الآن نرسل int بدلاً من String
                  );

                  context.read<AttendanceCubit>().createAttendanceAction(data);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
  void _showDeleteDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text('Delete this attendance record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // استدعاء دالة الحذف في الكيوبت
              context.read<AttendanceCubit>().deleteAttendance(id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class AttendanceCard extends StatelessWidget {
  final AttendanceEntity attendance;
  final bool canDelete;
  final VoidCallback? onDelete;

  const AttendanceCard({
    super.key,
    required this.attendance,
    this.canDelete = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                ),
                child: const Icon(Icons.check_circle_outline, color: Colors.white, size: 24),
              ),
              const SizedBox(width: AppTheme.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attendance.sessionName,
                      style: AppTheme.heading3.copyWith(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Session Record',
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              if (canDelete && onDelete != null)
                ActionButton(
                  icon: Icons.delete_rounded,
                  color: AppTheme.errorColor,
                  onPressed: onDelete!,
                  tooltip: 'Delete',
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
                    Icon(Icons.person, size: 18, color: AppTheme.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      attendance.memberName,
                      style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                _buildStatusChip(attendance.status),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bgColor;
    Color textColor;
    String text = status;

    // تحديد اللون بناءً على الحالة
    switch (status.toLowerCase()) {
      case 'present':
        bgColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        break;
      case 'absent':
        bgColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        break;
      case 'late':
        bgColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        break;
      case 'excused':
        bgColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        break;
      default:
        bgColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}