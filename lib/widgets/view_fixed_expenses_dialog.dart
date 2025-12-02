import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewFixedExpensesDialog extends StatelessWidget {
  final Map<String, Map<String, double>> gastosFijos;

  const ViewFixedExpensesDialog({super.key, required this.gastosFijos});

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
    gastosFijos.forEach((key, value) {
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
                    color: const Color(0xFF78350F),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: Color(0xFFF59E0B),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Todos los Gastos Fijos',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF1F5F9),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${gastosFijos.length} categorías · Total: ${formatearMoneda(totalActual)}',
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
                color: const Color(0xFF78350F).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withOpacity(0.3),
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
                    const Color(0xFFF59E0B),
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

            // Lista de gastos fijos con scroll
            Expanded(
              child: gastosFijos.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: gastosFijos.length,
                      itemBuilder: (context, index) {
                        final entry = gastosFijos.entries.elementAt(index);
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
      case 'renta':
      case 'rent':
        icono = Icons.home_outlined;
        colorIcono = const Color(0xFF6366F1);
        break;
      case 'internet':
        icono = Icons.wifi_rounded;
        colorIcono = const Color(0xFF8B5CF6);
        break;
      case 'teléfono':
      case 'phone bill':
        icono = Icons.phone_iphone_rounded;
        colorIcono = const Color(0xFF10B981);
        break;
      case 'deporte de mami':
      case 'gym membership':
        icono = Icons.fitness_center_rounded;
        colorIcono = const Color(0xFFEC4899);
        break;
      case 'suscripciones':
      case 'subscriptions (netflix/spotify)':
        icono = Icons.subscriptions_outlined;
        colorIcono = const Color(0xFFF59E0B);
        break;
      case 'carro mensual':
      case 'car payment':
        icono = Icons.directions_car_outlined;
        colorIcono = const Color(0xFF3B82F6);
        break;
      case 'electricidad':
        icono = Icons.bolt_rounded;
        colorIcono = const Color(0xFFFBBF24);
        break;
      case 'actividad':
        icono = Icons.local_activity_rounded;
        colorIcono = const Color(0xFFEC4899);
        break;
      case 'colmado':
        icono = Icons.store_rounded;
        colorIcono = const Color(0xFF14B8A6);
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
            'No hay gastos fijos registrados',
            style: TextStyle(fontSize: 16, color: const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
