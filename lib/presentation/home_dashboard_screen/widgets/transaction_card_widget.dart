import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

class TransactionCardWidget extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;
  final VoidCallback onTap;
  final String currencySymbol; // Recibe la moneda

  const TransactionCardWidget({
    super.key,
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
    required this.onDuplicate,
    required this.onTap,
    this.currencySymbol = '\$', // Valor por defecto
  });

  @override
  Widget build(BuildContext context) {
    // 1. Extracción segura de datos
    final isIncome = (transaction['type'] as String? ?? 'expense') == 'income';
    final amount = (transaction['amount'] as num? ?? 0).toDouble();
    final category = transaction['category'] as String? ?? 'General';
    final description =
        transaction['description'] as String? ?? 'Sin descripción';

    // 2. Manejo de Fecha
    DateTime date = DateTime.now();
    if (transaction['date'] is DateTime) {
      date = transaction['date'];
    } else if (transaction['date'] is String) {
      date = DateTime.tryParse(transaction['date']) ?? DateTime.now();
    }

    // 3. Manejo de Icono y Color (Evita el error rojo)
    IconData iconData = Icons.category;
    if (transaction['icon'] is int) {
      iconData = IconData(transaction['icon'], fontFamily: 'MaterialIcons');
    }

    Color iconColor = isIncome
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);
    if (transaction['color'] is int) {
      iconColor = Color(transaction['color']);
    }

    // 4. Formato de Moneda
    final locale = currencySymbol == '€' ? 'es_ES' : 'en_US';
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: '$currencySymbol ',
    );
    final montoStr = formatter.format(amount);

    return Slidable(
      key: ValueKey(transaction['id']),
      endActionPane: ActionPane(
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
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                // Círculo del Icono
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(iconData, color: iconColor, size: 24),
                  ),
                ),
                SizedBox(width: 3.w),

                // Textos (Descripción y Categoría)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          Text(
                            category,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 10.sp,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[600],
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            '${date.day}/${date.month}/${date.year}',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 2.w),

                // Monto Formateado
                Text(
                  '${isIncome ? '+' : ''}$montoStr',
                  style: TextStyle(
                    color: isIncome
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                    fontSize: 12.sp,
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
