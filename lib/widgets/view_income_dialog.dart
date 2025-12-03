import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewIncomeDialog extends StatelessWidget {
  final Map<String, Map<String, dynamic>> ingresos;

  const ViewIncomeDialog({super.key, required this.ingresos});

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
    ingresos.forEach((key, value) {
      final valor = value[tipo];
      if (valor is double) {
        total += valor;
      } else if (valor is int) {
        total += valor.toDouble();
      }
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    double totalEstimado = calcularTotal('estimado');
    double totalActual = calcularTotal('actual');
    double diferencia = totalActual - totalEstimado;

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
                    color: const Color(0xFF064E3B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.trending_up_rounded,
                    color: Color(0xFF10B981),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Todos los Ingresos',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF1F5F9),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${ingresos.length} fuentes · Total: ${formatearMoneda(totalActual)}',
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
                color: const Color(0xFF064E3B).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF10B981).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickStat(
                    'Estimado',
                    totalEstimado,
                    const Color(0xFF94A3B8),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: const Color(0xFF475569),
                  ),
                  _buildQuickStat(
                    'Obtenido',
                    totalActual,
                    const Color(0xFF10B981),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: const Color(0xFF475569),
                  ),
                  _buildQuickStat(
                    diferencia >= 0 ? 'Extra' : 'Faltante',
                    diferencia.abs(),
                    diferencia >= 0
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Lista de ingresos con scroll
            Expanded(
              child: ingresos.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: ingresos.length,
                      itemBuilder: (context, index) {
                        final entry = ingresos.entries.elementAt(index);
                        return _buildIncomeItem(
                          entry.key,
                          entry.value['actual'] ?? 0,
                          entry.value['estimado'] ?? 0,
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

  Widget _buildIncomeItem(String nombre, double actual, double estimado) {
    double porcentaje = estimado > 0 ? (actual / estimado) * 100 : 0;
    bool exceeded = actual > estimado;

    IconData icono;
    Color colorIcono;

    switch (nombre.toLowerCase()) {
      case 'salario fijo':
        icono = Icons.account_balance_wallet_outlined;
        colorIcono = const Color(0xFF6366F1);
        break;
      case 'independiente':
        icono = Icons.work_outline_rounded;
        colorIcono = const Color(0xFF8B5CF6);
        break;
      case 'inversiones':
        icono = Icons.trending_up_rounded;
        colorIcono = const Color(0xFF10B981);
        break;
      case 'cashbacks':
        icono = Icons.credit_card_rounded;
        colorIcono = const Color(0xFFF59E0B);
        break;
      case 'extra':
        icono = Icons.card_giftcard_rounded;
        colorIcono = const Color(0xFFEC4899);
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
                        'Estimado: ${formatearMoneda(estimado)}',
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
                        color: exceeded
                            ? const Color(0xFF10B981)
                            : const Color(0xFF6366F1),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: exceeded
                            ? const Color(0xFF064E3B)
                            : const Color(0xFF1E3A8A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${porcentaje.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: exceeded
                              ? const Color(0xFF10B981)
                              : const Color(0xFF6366F1),
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
                  exceeded ? const Color(0xFF10B981) : const Color(0xFF6366F1),
                ),
              ),
            ),

            // Mostrar si superó el estimado
            if (exceeded)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: Color(0xFF10B981),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '¡Superado por ${formatearMoneda(actual - estimado)}!',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF10B981),
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
            Icons.trending_up_outlined,
            size: 64,
            color: const Color(0xFF475569),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay ingresos registrados',
            style: TextStyle(fontSize: 16, color: const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
