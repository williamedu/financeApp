import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewVariableExpensesDialog extends StatelessWidget {
  final Map<String, Map<String, double>> gastosVariables;

  const ViewVariableExpensesDialog({super.key, required this.gastosVariables});

  String formatearMoneda(double valor) {
    final formatoDominicano = NumberFormat.currency(
      locale: 'es_DO',
      symbol: '',
      decimalDigits: 2,
    );
    return 'RD\$ ${formatoDominicano.format(valor).trim()}';
  }

  double calcularTotal(String tipo) {
    double total = 0;
    gastosVariables.forEach((key, value) {
      total += value[tipo] ?? 0;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    double totalPresupuestado = calcularTotal('presupuestado');
    double totalActual = calcularTotal('actual');
    double diferencia = totalPresupuestado - totalActual;

    return Dialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 1000,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF334155), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.insights_rounded,
                    color: Color(0xFF3B82F6),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Todos los Gastos Variables',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF1F5F9),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${gastosVariables.length} categorías · Total: ${formatearMoneda(totalActual)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  color: const Color(0xFF94A3B8),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Resumen rápido
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF3B82F6).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickStat(
                    'Presupuestado',
                    totalPresupuestado,
                    const Color(0xFF94A3B8),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: const Color(0xFF475569),
                  ),
                  _buildQuickStat(
                    'Gastado',
                    totalActual,
                    const Color(0xFF3B82F6),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: const Color(0xFF475569),
                  ),
                  _buildQuickStat(
                    diferencia >= 0 ? 'Disponible' : 'Excedido',
                    diferencia.abs(),
                    diferencia >= 0
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Lista de gastos variables con scroll
            Expanded(
              child: gastosVariables.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: gastosVariables.length,
                      itemBuilder: (context, index) {
                        final entry = gastosVariables.entries.elementAt(index);
                        return _buildExpenseItem(
                          entry.key,
                          entry.value['actual'] ?? 0,
                          entry.value['presupuestado'] ?? 0,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
        ),
        const SizedBox(height: 4),
        Text(
          formatearMoneda(value),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseItem(String nombre, double actual, double presupuestado) {
    double porcentaje = presupuestado > 0 ? (actual / presupuestado) * 100 : 0;
    bool overBudget = actual > presupuestado && presupuestado > 0;

    IconData icono;
    Color colorIcono;

    // Asignar ícono según categoría
    switch (nombre.toLowerCase()) {
      case 'compras':
      case 'groceries':
        icono = Icons.shopping_cart_outlined;
        colorIcono = const Color(0xFF8B5CF6);
        break;
      case 'fast food':
      case 'dining out / fast food':
        icono = Icons.restaurant_outlined;
        colorIcono = const Color(0xFFEF4444);
        break;
      case 'shopping (clothes/misc)':
      case 'compras ropa':
        icono = Icons.shopping_bag_outlined;
        colorIcono = const Color(0xFFEC4899);
        break;
      case 'taxis':
      case 'taxis / rideshare':
        icono = Icons.local_taxi_outlined;
        colorIcono = const Color(0xFFFBBF24);
        break;
      case 'entretenimiento':
      case 'entertainment':
        icono = Icons.movie_outlined;
        colorIcono = const Color(0xFF3B82F6);
        break;
      case 'health & wellness':
      case 'vitaminas':
        icono = Icons.favorite_outline_rounded;
        colorIcono = const Color(0xFF10B981);
        break;
      case 'transferencias':
        icono = Icons.swap_horiz_rounded;
        colorIcono = const Color(0xFF6366F1);
        break;
      case 'retiro efectivo':
        icono = Icons.account_balance_wallet_outlined;
        colorIcono = const Color(0xFF9CA3AF);
        break;
      case 'meal prep':
        icono = Icons.fastfood_outlined;
        colorIcono = const Color(0xFFF97316);
        break;
      case 'agua w magno':
        icono = Icons.water_drop_outlined;
        colorIcono = const Color(0xFF06B6D4);
        break;
      case 'cuarteo':
      case 'cosas para casa':
        icono = Icons.home_work_outlined;
        colorIcono = const Color(0xFF64748B);
        break;
      case 'regalos':
        icono = Icons.card_giftcard_rounded;
        colorIcono = const Color(0xFFE11D48);
        break;
      case 'laundry':
      case 'peluquería':
        icono = Icons.dry_cleaning_outlined;
        colorIcono = const Color(0xFFA855F7);
        break;
      case 'viajes':
        icono = Icons.flight_outlined;
        colorIcono = const Color(0xFF0EA5E9);
        break;
      case 'excedentes renta':
        icono = Icons.savings_outlined;
        colorIcono = const Color(0xFF84CC16);
        break;
      case 'femi':
        icono = Icons.medical_services_outlined;
        colorIcono = const Color(0xFFEC4899);
        break;
      case 'utility asset':
        icono = Icons.build_outlined;
        colorIcono = const Color(0xFF78716C);
        break;
      case 'salir / accesories':
        icono = Icons.celebration_outlined;
        colorIcono = const Color(0xFFF472B6);
        break;
      default:
        icono = Icons.attach_money_rounded;
        colorIcono = const Color(0xFF94A3B8);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF334155),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF475569), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre, ícono y montos
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorIcono.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icono, size: 24, color: colorIcono),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFF1F5F9),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Presupuesto: ${formatearMoneda(presupuestado)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatearMoneda(actual),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: overBudget
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: overBudget
                            ? const Color(0xFF7F1D1D)
                            : const Color(0xFF064E3B),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${porcentaje.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: overBudget
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Barra de progreso
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: porcentaje > 100 ? 1.0 : porcentaje / 100,
                minHeight: 8,
                backgroundColor: const Color(0xFF1E293B),
                valueColor: AlwaysStoppedAnimation<Color>(
                  overBudget
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF6366F1),
                ),
              ),
            ),

            // Mostrar si está sobre presupuesto
            if (overBudget)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_rounded,
                      size: 14,
                      color: Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Excedido por ${formatearMoneda(actual - presupuestado)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: const Color(0xFF475569),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay gastos variables registrados',
            style: TextStyle(fontSize: 16, color: const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
