import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Header widget for budget management screen with month navigation
class BudgetHeaderWidget extends StatelessWidget {
  final String currentMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onNewBudget;

  const BudgetHeaderWidget({
    Key? key,
    required this.currentMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onNewBudget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Month navigation
          Row(
            children: [
              IconButton(
                icon: CustomIconWidget(
                  iconName: 'chevron_left',
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
                onPressed: onPreviousMonth,
                tooltip: 'Mes anterior',
              ),
              SizedBox(width: 2.w),
              Text(
                currentMonth,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(width: 2.w),
              IconButton(
                icon: CustomIconWidget(
                  iconName: 'chevron_right',
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
                onPressed: onNextMonth,
                tooltip: 'Mes siguiente',
              ),
            ],
          ),
          // New budget button
          ElevatedButton.icon(
            onPressed: onNewBudget,
            icon: CustomIconWidget(
              iconName: 'add',
              color: theme.colorScheme.onPrimary,
              size: 20,
            ),
            label: Text('Nuevo Presupuesto'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            ),
          ),
        ],
      ),
    );
  }
}
