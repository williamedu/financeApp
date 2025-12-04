import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Individual transaction card with swipe actions
class TransactionCardWidget extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;
  final VoidCallback onTap;

  const TransactionCardWidget({
    Key? key,
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
    required this.onDuplicate,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIncome = (transaction['type'] as String) == 'income';
    final amount = transaction['amount'] as double;
    final category = transaction['category'] as String;
    final description = transaction['description'] as String;
    final date = transaction['date'] as DateTime;
    final iconName = transaction['icon'] as String;

    return Slidable(
      key: ValueKey(transaction['id']),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => onEdit(),
            backgroundColor: AppTheme.interactiveBlue,
            foregroundColor: theme.colorScheme.onPrimary,
            icon: Icons.edit,
            label: 'Editar',
            borderRadius: BorderRadius.circular(12),
          ),
          SlidableAction(
            onPressed: (context) => onDuplicate(),
            backgroundColor: AppTheme.incomeGold,
            foregroundColor: theme.colorScheme.onPrimary,
            icon: Icons.copy,
            label: 'Duplicar',
            borderRadius: BorderRadius.circular(12),
          ),
          SlidableAction(
            onPressed: (context) => onDelete(),
            backgroundColor: AppTheme.expenseRed,
            foregroundColor: theme.colorScheme.onPrimary,
            icon: Icons.delete,
            label: 'Eliminar',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
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
                    color:
                        (isIncome ? AppTheme.successGreen : AppTheme.expenseRed)
                            .withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: iconName,
                      color: isIncome
                          ? AppTheme.successGreen
                          : AppTheme.expenseRed,
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
                        description,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          Text(
                            category,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onSurfaceVariant,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            '${date.day}/${date.month}/${date.year}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  '${isIncome ? '+' : '-'}\$${amount.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color:
                        isIncome ? AppTheme.successGreen : AppTheme.expenseRed,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
