import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Alert card for budget notifications
class BudgetAlertCardWidget extends StatelessWidget {
  final String categoryName;
  final String message;
  final String alertType;
  final VoidCallback onTap;

  const BudgetAlertCardWidget({
    Key? key,
    required this.categoryName,
    required this.message,
    required this.alertType,
    required this.onTap,
  }) : super(key: key);

  Color _getAlertColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (alertType) {
      case 'exceeded':
        return theme.colorScheme.error;
      case 'warning':
        return AppTheme.warningOrange;
      default:
        return theme.colorScheme.secondary;
    }
  }

  IconData _getAlertIcon() {
    switch (alertType) {
      case 'exceeded':
        return Icons.error;
      case 'warning':
        return Icons.warning;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final alertColor = _getAlertColor(context);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      color: alertColor.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Row(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: alertColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: _getAlertIcon().toString().split('.').last,
                    color: alertColor,
                    size: 24,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: alertColor,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      message,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              CustomIconWidget(
                iconName: 'chevron_right',
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
