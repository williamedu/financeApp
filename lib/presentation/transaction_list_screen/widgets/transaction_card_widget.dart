import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class TransactionCardWidget extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;
  final VoidCallback? onViewReceipt;
  final String currencySymbol; // <--- ESTO ES LO QUE FALTA

  const TransactionCardWidget({
    super.key,
    required this.transaction,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onDuplicate,
    this.onViewReceipt,
    this.currencySymbol = '\$', // Valor por defecto
  });

  Color _getCategoryColor(String category) {
    if (transaction['color'] is int) return Color(transaction['color']);
    switch (category.toLowerCase()) {
      case 'ingreso':
        return const Color(0xFF10B981);
      case 'comida':
        return const Color(0xFFF59E0B);
      case 'transporte':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIncome = (transaction['type'] as String? ?? 'expense') == 'income';
    final amount = (transaction['amount'] as num? ?? 0).toDouble();
    final category = transaction['category'] as String? ?? 'General';
    final description =
        transaction['description'] as String? ?? 'Sin descripción';

    dynamic iconData = 'category';
    if (transaction['icon'] is int) {
      iconData = IconData(transaction['icon'], fontFamily: 'MaterialIcons');
    }

    final locale = currencySymbol == '€' ? 'es_ES' : 'en_US';
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: '$currencySymbol ',
    );
    final amountStr = formatter.format(amount);

    return Slidable(
      key: ValueKey(transaction['id']),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => onEdit(),
            backgroundColor: const Color(0xFF3B82F6),
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Editar',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => onDelete(),
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Eliminar',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: Card(
        color: const Color(0xFF1E293B),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(category).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: iconData is IconData
                        ? Icon(
                            iconData,
                            color: _getCategoryColor(category),
                            size: 24,
                          )
                        : CustomIconWidget(
                            iconName: iconData,
                            size: 24,
                            color: _getCategoryColor(category),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        description,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Aquí aplicamos tu petición: LETRA MÁS PEQUEÑA (Moderada)
                Text(
                  '${isIncome ? '+' : ''}$amountStr',
                  style: TextStyle(
                    color: isIncome
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                    fontSize: 14, // Tamaño moderado
                    fontWeight: FontWeight.bold,
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
