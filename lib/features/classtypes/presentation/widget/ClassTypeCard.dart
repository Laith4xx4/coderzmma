import 'package:flutter/material.dart';
import 'package:thesavage/core/app_theme.dart';
import 'package:thesavage/features/classtypes/domain/entities/class_type_entity.dart';
import 'package:thesavage/widgets/modern_card.dart';


class ClassTypeCard extends StatelessWidget {
  final ClassTypeEntity item;
  final bool canDelete;
  final VoidCallback? onDelete;

  const ClassTypeCard({
    super.key,
    required this.item,
    this.canDelete = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusMedium,
                  ),
                ),
                child: const Icon(Icons.category, color: Colors.white, size: 24),
              ),
              const SizedBox(width: AppTheme.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: AppTheme.heading3.copyWith(fontSize: 18),
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

          // معلومات المدة وعدد الجلسات
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMD),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoBadge(
                    context,
                    Icons.timer,
                    '${item.durationMinutes} mins',
                    AppTheme.infoColor
                ),
                Container(
                    width: 1,
                    height: 20,
                    color: AppTheme.textLight.withOpacity(0.2)
                ),
                _buildInfoBadge(
                    context,
                    Icons.layers,
                    '${item.sessionsCount} Sessions',
                    AppTheme.primaryColor
                ),
              ],
            ),
          ),

          if (item.description != null && item.description!.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingMD),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMD),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(
                  AppTheme.borderRadiusMedium,
                ),
                border: Border.all(color: AppTheme.textLight.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.description,
                    size: 18,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: AppTheme.spacingSM),
                  Expanded(
                    child: Text(
                      item.description!,
                      style: AppTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoBadge(BuildContext context, IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}