import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

/// Summary card showing overall budget status with circular progress
class BudgetSummaryCardWidget extends StatelessWidget {
  final double totalBudget;
  final double spentAmount;
  final double remainingBalance;
  final double spendingPercentage;

  const BudgetSummaryCardWidget({
    Key? key,
    required this.totalBudget,
    required this.spentAmount,
    required this.remainingBalance,
    required this.spendingPercentage,
  }) : super(key: key);

  Color _getProgressColor(BuildContext context) {
    final theme = Theme.of(context);
    if (spendingPercentage >= 90) {
      return theme.colorScheme.error;
    } else if (spendingPercentage >= 70) {
      return AppTheme.warningOrange;
    } else {
      return AppTheme.successGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = _getProgressColor(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surface.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          // Circular progress indicator
          SizedBox(
            height: 30.h,
            width: 30.h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 30.h,
                  width: 30.h,
                  child: CircularProgressIndicator(
                    value: spendingPercentage / 100,
                    strokeWidth: 12,
                    backgroundColor:
                        theme.colorScheme.outline.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${spendingPercentage.toStringAsFixed(0)}%',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: progressColor,
                      ),
                    ),
                    Text(
                      'Gastado',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          // Budget details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBudgetDetail(
                context,
                'Presupuesto Total',
                '\$${totalBudget.toStringAsFixed(2)}',
                theme.colorScheme.primary,
              ),
              Container(
                height: 6.h,
                width: 1,
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
              _buildBudgetDetail(
                context,
                'Gastado',
                '\$${spentAmount.toStringAsFixed(2)}',
                theme.colorScheme.error,
              ),
              Container(
                height: 6.h,
                width: 1,
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
              _buildBudgetDetail(
                context,
                'Restante',
                '\$${remainingBalance.toStringAsFixed(2)}',
                AppTheme.successGreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetDetail(
    BuildContext context,
    String label,
    String amount,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          amount,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
