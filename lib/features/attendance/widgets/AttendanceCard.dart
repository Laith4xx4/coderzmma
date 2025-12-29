import 'package:flutter/material.dart';
import 'package:thesavage/core/app_theme.dart';
import 'package:thesavage/features/attendance/domain/entities/attendance_entity.dart';
import 'package:thesavage/widgets/modern_card.dart';

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