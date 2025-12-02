import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'view_fixed_expenses_dialog.dart';
import 'add_fixed_expense_dialog.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class GastosFijosWidget extends StatefulWidget {
  final Map<String, Map<String, dynamic>> gastosFijos;

  const GastosFijosWidget({super.key, required this.gastosFijos});

  @override
  State<GastosFijosWidget> createState() => _GastosFijosWidgetState();
}

class _GastosFijosWidgetState extends State<GastosFijosWidget> {
  late Map<String, Map<String, dynamic>> gastosFijosLocales;

  @override
  void initState() {
    super.initState();
    gastosFijosLocales = Map.from(widget.gastosFijos);
  }

  @override
  void didUpdateWidget(GastosFijosWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Actualizar datos locales cuando cambien los props
    if (oldWidget.gastosFijos != widget.gastosFijos) {
      setState(() {
        gastosFijosLocales = Map.from(widget.gastosFijos);
      });
    }
  }

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
    gastosFijosLocales.forEach((key, value) {
      final valor = value[tipo];
      if (valor is double) {
        total += valor;
      } else if (valor is int) {
        total += valor.toDouble();
      }
    });
    return total;
  }

  void _mostrarDialogoViewDetails() {
    showDialog(
      context: context,
      builder: (context) {
        return ViewFixedExpensesDialog(gastosFijos: gastosFijosLocales);
      },
    );
  }

  void _mostrarDialogoAgregar() {
    showDialog(
      context: context,
      builder: (context) => AddFixedExpenseDialog(
        categoriasExistentes: gastosFijosLocales.keys.toList(),
        onAdd: (nombre, presupuestado, actual) async {
          // Generar nombre único si ya existe
          String nombreFinal = nombre;
          int contador = 2;
          while (gastosFijosLocales.containsKey(nombreFinal)) {
            nombreFinal = '$nombre $contador';
            contador++;
          }

          // Guardar en Firebase
          final authService = AuthService();
          final firestoreService = FirestoreService();
          final user = authService.currentUser;

          if (user != null) {
            try {
              await firestoreService.addGastoFijo(
                uid: user.uid,
                nombre: nombreFinal,
                presupuestado: presupuestado,
                actual: actual,
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gasto fijo agregado exitosamente'),
                    backgroundColor: Color(0xFFF59E0B),
                  ),
                );
              }
            } catch (e) {
              if (mounted) {
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
  }

  @override
  Widget build(BuildContext context) {
    double totalPresupuestado = calcularTotal('presupuestado');
    double totalActual = calcularTotal('actual');
    double diferencia = totalPresupuestado - totalActual;
    bool onTrack = totalActual <= totalPresupuestado;

    return Container(
      constraints: const BoxConstraints(
        minWidth: 350,
        maxWidth: 500,
        minHeight: 630,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Fondo oscuro
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF59E0B), width: 2),
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
          // Header con ícono y badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF78350F), // Fondo naranja oscuro
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: Color(0xFFF59E0B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Fixed Expenses',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF1F5F9), // Texto claro
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: onTrack
                      ? const Color(0xFF064E3B)
                      : const Color(0xFF7F1D1D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  onTrack ? 'On Track' : 'Over Budget',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: onTrack
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Lista de gastos fijos (sin Expanded, solo lista limitada)
          ...gastosFijosLocales.entries.take(4).map((entry) {
            return _buildExpenseItem(
              entry.key,
              entry.value['actual'] ?? 0,
              entry.value['presupuestado'] ?? 0,
            );
          }).toList(),

          const SizedBox(height: 20),

          // Total
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF78350F).withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFF59E0B).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Fixed Expenses',
                      style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatearMoneda(totalActual),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF1F5F9),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      diferencia >= 0
                          ? '-${formatearMoneda(diferencia.abs())}'
                          : '+${formatearMoneda(diferencia.abs())}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: diferencia >= 0
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Budget: ${formatearMoneda(totalPresupuestado)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Botones View Details (centrado) y Add (derecha)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // View Details centrado
              TextButton.icon(
                onPressed: _mostrarDialogoViewDetails,
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
              // Add a la derecha
              TextButton.icon(
                onPressed: _mostrarDialogoAgregar,
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
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre y monto
          Row(
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

              // Nombre
              Expanded(
                child: Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF1F5F9),
                  ),
                ),
              ),

              // Monto actual / presupuestado
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatearMoneda(actual),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: overBudget
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF10B981),
                    ),
                  ),
                  Text(
                    '/ ${formatearMoneda(presupuestado)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Barra de progreso y porcentaje
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: porcentaje > 100 ? 1.0 : porcentaje / 100,
                    minHeight: 6,
                    backgroundColor: const Color(0xFF334155),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      overBudget
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF6366F1),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${porcentaje.toStringAsFixed(0)}% used',
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
            ],
          ),

          // Mostrar si está sobre presupuesto
          if (overBudget)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${formatearMoneda(actual - presupuestado)} over',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEF4444),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
