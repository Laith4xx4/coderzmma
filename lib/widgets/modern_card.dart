import 'package:flutter/material.dart';
import 'package:thesavage/core/app_theme.dart';

class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? borderRadius;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: AppTheme.spacingMD),
      decoration: AppTheme.cardDecoration(
        color: backgroundColor,
        borderRadius: borderRadius ?? AppTheme.borderRadiusLarge,
        shadows: AppTheme.elevatedShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(
            borderRadius ?? AppTheme.borderRadiusLarge,
          ),
          onTap: onTap,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppTheme.spacingMD),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Stat Item Widget for displaying statistics
class StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  const StatItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 20,
          color: iconColor ?? AppTheme.primaryColor,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Action Button Widget
class ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final String? tooltip;

  const ActionButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 20),
        onPressed: onPressed,
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

/// Status Badge Widget
class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.text,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Avatar Widget with gradient
class GradientAvatar extends StatelessWidget {
  final IconData icon;
  final double size;
  final String? text;

  const GradientAvatar({
    super.key,
    required this.icon,
    this.size = 56,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: AppTheme.cardShadow,
      ),
      child: text != null
          ? Center(
              child: Text(
                text!,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: size * 0.4,
                ),
              ),
            )
          : Icon(
              icon,
              color: Colors.white,
              size: size * 0.5,
            ),
    );
  }
}

