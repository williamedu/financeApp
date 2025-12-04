import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget for displaying individual transaction card with swipe actions
class TransactionCardWidget extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;
  final VoidCallback? onViewReceipt;

  const TransactionCardWidget({
    Key? key,
    required this.transaction,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onDuplicate,
    this.onViewReceipt,
  }) : super(key: key);

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'ingreso':
      case 'salario':
        return Color(0xFF10B981);
      case 'comida':
      case 'alimentación':
        return Color(0xFFF59E0B);
      case 'transporte':
        return Color(0xFF3B82F6);
      case 'entretenimiento':
        return Color(0xFF8B5CF6);
      case 'salud':
        return Color(0xFFEF4444);
      case 'compras':
        return Color(0xFFEC4899);
      default:
        return Color(0xFF64748B);
    }
  }

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'ingreso':
      case 'salario':
        return 'trending_up';
      case 'comida':
      case 'alimentación':
        return 'restaurant';
      case 'transporte':
        return 'directions_car';
      case 'entretenimiento':
        return 'movie';
      case 'salud':
        return 'local_hospital';
      case 'compras':
        return 'shopping_bag';
      default:
        return 'account_balance_wallet';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIncome = (transaction['type'] as String).toLowerCase() == 'ingreso';
    final amount = transaction['amount'] as double;
    final category = transaction['category'] as String;
    final description = transaction['description'] as String;
    final timestamp = transaction['timestamp'] as DateTime;
    final hasReceipt = transaction['hasReceipt'] as bool? ?? false;

    return Slidable(
      key: ValueKey(transaction['id']),
      startActionPane: ActionPane(
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => onEdit(),
            backgroundColor: Color(0xFF3B82F6),
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Editar',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => onDelete(),
            backgroundColor: Color(0xFFEF4444),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Eliminar',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: InkWell(
          onTap: onTap,
          onLongPress: () => _showContextMenu(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Category icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(category).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: _getCategoryIcon(category),
                      size: 24,
                      color: _getCategoryColor(category),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                // Transaction details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              description,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (hasReceipt) ...[
                            SizedBox(width: 8),
                            CustomIconWidget(
                              iconName: 'attach_file',
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            category,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '•',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            _formatTimestamp(timestamp),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                // Amount
                Text(
                  '${isIncome ? '+' : '-'}\$${amount.toStringAsFixed(2)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: isIncome ? Color(0xFF10B981) : Color(0xFFEF4444),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'Hace ${difference.inMinutes}m';
      }
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays}d';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _showContextMenu(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'edit',
                color: theme.colorScheme.onSurface,
                size: 24,
              ),
              title: Text(
                'Editar',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'content_copy',
                color: theme.colorScheme.onSurface,
                size: 24,
              ),
              title: Text(
                'Duplicar',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onDuplicate();
              },
            ),
            if (onViewReceipt != null)
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'attach_file',
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
                title: Text(
                  'Ver Recibo',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onViewReceipt!();
                },
              ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete',
                color: Color(0xFFEF4444),
                size: 24,
              ),
              title: Text(
                'Eliminar',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Color(0xFFEF4444),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
