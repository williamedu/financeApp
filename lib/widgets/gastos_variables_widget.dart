import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'view_variable_expenses_dialog.dart';
import 'add_variable_expense_dialog.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class GastosVariablesWidget extends StatefulWidget {
  final Map<String, Map<String, dynamic>> gastosVariables;

  const GastosVariablesWidget({super.key, required this.gastosVariables});

  @override
  State<GastosVariablesWidget> createState() => _GastosVariablesWidgetState();
}

class _GastosVariablesWidgetState extends State<GastosVariablesWidget> {
  late Map<String, Map<String, dynamic>> gastosVariablesLocales;

  @override
  void initState() {
    super.initState();
    gastosVariablesLocales = Map.from(widget.gastosVariables);
  }

  @override
  void didUpdateWidget(GastosVariablesWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Actualizar datos locales cuando cambien los props
    if (oldWidget.gastosVariables != widget.gastosVariables) {
      setState(() {
        gastosVariablesLocales = Map.from(widget.gastosVariables);
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
    gastosVariablesLocales.forEach((key, value) {
      final valor = value[tipo];
      if (valor is double) {
        total += valor;
      } else if (valor is int) {
        total += valor.toDouble();
      }
    });
    return total;
  }

  // --- NUEVO MÉTODO DE ESTADO VACÍO ---
  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(
              Icons.insights_rounded, // Ícono relacionado a gastos variables
              size: 48,
              color: Color(0xFF475569),
            ),
            SizedBox(height: 12),
            Text(
              'No variable expenses added yet',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
  // ------------------------------------

  void _mostrarDialogoViewDetails() {
    showDialog(
      context: context,
      builder: (context) {
        return ViewVariableExpensesDialog(
          gastosVariables: gastosVariablesLocales,
        );
      },
    );
  }

  void _mostrarDialogoAgregar() {
    showDialog(
      context: context,
      builder: (context) {
        return AddVariableExpenseDialog(
          categoriasExistentes: gastosVariablesLocales.keys.toList(),
          onAdd: (nombre, presupuestado, actual) async {
            // Generar nombre único si ya existe
            String nombreFinal = nombre;
            int contador = 2;
            while (gastosVariablesLocales.containsKey(nombreFinal)) {
              nombreFinal = '$nombre $contador';
              contador++;
            }

            // Guardar en Firebase
            final authService = AuthService();
            final firestoreService = FirestoreService();
            final user = authService.currentUser;

            if (user != null) {
              try {
                // USAMOS EL NUEVO MÉTODO UNIFICADO
                await firestoreService.addCategoriaPresupuesto(
                  uid: user.uid,
                  tipo: 'variable', // Indicamos que es Variable
                  nombre: nombreFinal,
                  presupuestado: presupuestado,
                  // Nota: En la nueva lógica el 'actual' inicia en 0 automáticamente
                );
                // ... resto de tu código de éxito/cerrar

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gasto variable agregado exitosamente'),
                      backgroundColor: Color(0xFF3B82F6),
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalPresupuestado = calcularTotal('presupuestado');
    double totalActual = calcularTotal('actual');
    double porcentajeTotal = totalPresupuestado > 0
        ? (totalActual / totalPresupuestado) * 100
        : 0;
    double diferencia = totalPresupuestado - totalActual;
    bool noGastosVariables =
        gastosVariablesLocales.isEmpty; // <--- LÓGICA DE ESTADO

    return Container(
      constraints: const BoxConstraints(
        minWidth: 350,
        maxWidth: 500,
        minHeight: 630,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Fondo oscuro
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3B82F6), width: 2),
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
                  color: const Color(0xFF1E3A8A), // Fondo azul oscuro
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  color: Color(0xFF3B82F6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Variable Expenses',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF1F5F9), // Texto claro
                ),
              ),
              const Spacer(),
              // Badge de porcentaje (solo si hay gastos)
              if (!noGastosVariables)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${porcentajeTotal.toStringAsFixed(0)}% used',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 24),

          // Lista de gastos variables o Estado Vacío
          SizedBox(
            // <--- ENVOLVEMOS EL CONTENIDO EN UN SIZEDBOX DE ALTURA FIJA
            height: 380, // Altura definida para controlar el layout
            child: noGastosVariables
                ? _buildEmptyState() // Si vacío, muestra el estado vacío centrado
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: gastosVariablesLocales.entries.length,
                    itemBuilder: (context, index) {
                      final entry = gastosVariablesLocales.entries.elementAt(
                        index,
                      );
                      return _buildExpenseItem(
                        entry.key,
                        entry.value['actual'] ?? 0,
                        entry.value['presupuestado'] ?? 0,
                        customIcon: entry.value['icon'],
                        customColor: entry.value['color'],
                      );
                    },
                  ),
          ),

          const SizedBox(height: 20),

          // Total (anclado abajo)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A).withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF3B82F6).withOpacity(0.3),
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
                      'Total Variable Expenses',
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

  Widget _buildExpenseItem(
    String nombre,
    double actual,
    double presupuestado, {
    IconData? customIcon,
    Color? customColor,
  }) {
    double porcentaje = presupuestado > 0 ? (actual / presupuestado) * 100 : 0;
    bool overBudget = actual > presupuestado && presupuestado > 0;

    IconData icono;
    Color colorIcono;

    // 1. PRIORIDAD: Datos guardados
    if (customIcon != null && customColor != null) {
      icono = customIcon;
      colorIcono = customColor;
    }
    // 2. FALLBACK: Switch antiguo
    else {
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
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
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
        ],
      ),
    );
  }
}
