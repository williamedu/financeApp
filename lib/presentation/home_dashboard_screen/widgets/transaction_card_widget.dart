import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart'; // Asegura la importación correcta del tema

class TransactionCardWidget extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;
  final VoidCallback onTap;

  const TransactionCardWidget({
    super.key,
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
    required this.onDuplicate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Extracción de datos segura
    final isIncome = (transaction['type'] as String? ?? 'expense') == 'income';
    final amount = (transaction['amount'] as num? ?? 0).toDouble();
    final category = transaction['category'] as String? ?? 'General';
    final description =
        transaction['description'] as String? ?? 'Sin descripción';

    // Manejo de fecha
    DateTime date = DateTime.now();
    if (transaction['date'] is DateTime) {
      date = transaction['date'];
    } else if (transaction['date'] is String) {
      date = DateTime.tryParse(transaction['date']) ?? DateTime.now();
    }

    // --- CORRECCIÓN: MANEJO DE ICONOS Y COLORES ---
    // Ahora leemos el 'codePoint' (int) y el valor del color (int)
    IconData iconData = Icons.category;
    if (transaction['icon'] is int) {
      iconData = IconData(transaction['icon'], fontFamily: 'MaterialIcons');
    }

    Color iconColor = isIncome ? AppTheme.successGreen : AppTheme.expenseRed;
    if (transaction['color'] is int) {
      iconColor = Color(transaction['color']);
    }

    return Slidable(
      key: ValueKey(transaction['id']),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => onEdit(),
            backgroundColor: const Color(0xFF3B82F6), // Azul interactivo
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Editar',
            borderRadius: BorderRadius.circular(12),
          ),
          SlidableAction(
            onPressed: (context) => onDelete(),
            backgroundColor: const Color(0xFFEF4444), // Rojo
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Eliminar',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: Card(
        color: const Color(0xFF1E293B), // Fondo oscuro de tarjeta
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
                    // Usamos el widget Icon nativo con los datos recuperados
                    child: Icon(iconData, color: iconColor, size: 24),
                  ),
                ),
                SizedBox(width: 3.w),

                // Textos
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

                // Monto
                Text(
                  '${isIncome ? '+' : '-'}\$${amount.toStringAsFixed(2)}',
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
