import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Financial summary card widget displaying available spending amount
class FinancialSummaryCardWidget extends StatelessWidget {
  final String userName;
  final double availableAmount;
  final String currency;

  const FinancialSummaryCardWidget({
    Key? key,
    required this.userName,
    required this.availableAmount,
    this.currency = '\$',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.incomeGold.withValues(alpha: 0.2),
            AppTheme.interactiveBlue.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderSubtle,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Disponible para gastar',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currency,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 1.w),
              Expanded(
                child: Text(
                  availableAmount.toStringAsFixed(2).replaceAll('.', ','),
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'trending_up',
                  color: AppTheme.successGreen,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Text(
                  '+12% vs mes anterior',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.successGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
