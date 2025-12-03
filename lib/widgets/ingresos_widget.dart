import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'view_income_dialog.dart';
import 'add_income_dialog.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class IngresosWidget extends StatelessWidget {
  final Map<String, Map<String, dynamic>> ingresos;

  final double totalAhorrosActual;
  final double totalDeudasActual;
  final double gastadoHastaAhora;
  final int mesActual;
  final int anioActual;
  final Function(Map<String, Map<String, dynamic>>) onIngresosUpdated;

  const IngresosWidget({
    super.key,
    required this.ingresos,
    required this.totalAhorrosActual,
    required this.totalDeudasActual,
    required this.gastadoHastaAhora,
    required this.mesActual,
    required this.anioActual,
    required this.onIngresosUpdated,
  });

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
      total += value[tipo] ?? 0;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    double totalEstimado = calcularTotal('estimado');
    double totalActual = calcularTotal('actual');
    double porcentaje = totalEstimado > 0
        ? (totalActual / totalEstimado) * 100
        : 0;

    return Container(
      constraints: const BoxConstraints(
        minWidth: 350,
        maxWidth: 500,
        minHeight: 630,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Fondo oscuro
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF10B981), // Verde para Income
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header con ícono
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF064E3B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Income',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF1F5F9),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF064E3B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${porcentaje.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Actual vs Estimated
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Actual vs Estimated',
                style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '${formatearMoneda(totalActual)} / ${formatearMoneda(totalEstimado)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF1F5F9),
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Barra de progreso
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: porcentaje / 100,
              minHeight: 8,
              backgroundColor: const Color(0xFF334155),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF6366F1),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // SOURCES
          const Text(
            'SOURCES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 16),

          // Lista de fuentes de ingreso
          ...ingresos.entries.take(4).map((entry) {
            return _buildIncomeSource(
              entry.key,
              entry.value['actual'] ?? 0,
              entry.value['estimado'] ?? 0,
            );
          }),

          const SizedBox(height: 20),

          // Total Income (grande) - AHORA AL FINAL
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF064E3B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Income',
                  style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 4),
                Text(
                  formatearMoneda(totalActual),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Botones View Details y Add
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => ViewIncomeDialog(ingresos: ingresos),
                  );
                },
                label: const Text('View Details'),
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF6366F1),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AddIncomeDialog(
                      incomesExistentes: ingresos.keys.toList(),
                      onAdd: (nombre, estimado, actual) async {
                        String nombreFinal = nombre;
                        int contador = 2;
                        while (ingresos.containsKey(nombreFinal)) {
                          nombreFinal = '$nombre $contador';
                          contador++;
                        }

                        final authService = AuthService();
                        final firestoreService = FirestoreService();
                        final user = authService.currentUser;

                        if (user != null) {
                          try {
                            await firestoreService.addIngreso(
                              uid: user.uid,
                              nombre: nombreFinal,
                              estimado: estimado,
                              actual: actual,
                            );

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Ingreso agregado exitosamente',
                                  ),
                                  backgroundColor: Color(0xFF10B981),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error al guardar: $e'),
                                  backgroundColor: const Color(0xFFEF4444),
                                ),
                              );
                            }
                          }
                        }
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF6366F1),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeSource(String nombre, double actual, double estimado) {
    IconData icono;
    Color colorIcono;

    // Asignar ícono según la fuente
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
      default:
        icono = Icons.attach_money_rounded;
        colorIcono = const Color(0xFF94A3B8);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Ícono
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorIcono.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icono, size: 18, color: colorIcono),
          ),
          const SizedBox(width: 12),

          // Nombre y descripción
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF1F5F9),
                  ),
                ),
                Text(
                  estimado > 0
                      ? 'Est: ${formatearMoneda(estimado)}'
                      : 'Monthly direct deposit',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          // Monto
          Text(
            formatearMoneda(actual),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }
}
