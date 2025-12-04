import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/view_transactions_dialog.dart';
import '../widgets/add_transaction_dialog.dart';

import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class TransaccionesWidget extends StatefulWidget {
  final List<Map<String, dynamic>> transacciones;
  // AGREGAR ESTAS DOS:
  final Map<String, Map<String, dynamic>> gastosFijos;
  final Map<String, Map<String, dynamic>> gastosVariables;

  const TransaccionesWidget({
    super.key,
    required this.transacciones,
    // Recuerda requerirlas en el constructor
    required this.gastosFijos,
    required this.gastosVariables,
  });

  @override
  State<TransaccionesWidget> createState() => _TransaccionesWidgetState();
}

class _TransaccionesWidgetState extends State<TransaccionesWidget> {
  String formatearMoneda(double valor) {
    final formatoDominicano = NumberFormat.currency(
      locale: 'es_DO',
      symbol: '',
      decimalDigits: 2,
    );
    return 'RD\$ ${formatoDominicano.format(valor).trim()}';
  }

  void _mostrarTodasLasTransacciones() {
    showDialog(
      context: context,
      builder: (context) =>
          ViewTransactionsDialog(transacciones: widget.transacciones),
    );
  }

  void _mostrarDialogoAgregar() {
    // 1. Obtener categorías únicas combinando TODO para el buscador
    final Set<String> todasLasCategorias = {};
    todasLasCategorias.addAll(
      widget.transacciones.map((t) => t['categoria'] as String),
    );
    todasLasCategorias.addAll(widget.gastosFijos.keys);
    todasLasCategorias.addAll(widget.gastosVariables.keys);

    showDialog(
      context: context,
      builder: (context) => AddTransactionDialog(
        categoriasExistentes: todasLasCategorias.toList()..sort(),
        onAdd:
            (
              categoria,
              monto,
              concepto,
              fecha, {
              bool? crearPresupuesto,
              String? tipoPresupuesto,
              double? montoPresupuesto,
              IconData? icon,
              Color? color,
            }) async {
              final authService = AuthService();
              final firestoreService = FirestoreService();
              final user = authService.currentUser;

              if (user != null) {
                try {
                  // A. Guardar la Transacción
                  await firestoreService.addTransaccion(
                    uid: user.uid,
                    categoria: categoria,
                    monto: monto,
                    concepto: concepto,
                    fecha: fecha,
                    iconCode: icon?.codePoint,
                    colorValue: color?.value,
                  );

                  // B. ACTUALIZAR CATEGORÍA EXISTENTE (Lógica Nueva)
                  // Si NO estamos creando un presupuesto nuevo explícitamente,
                  // intentamos actualizar uno existente que coincida con el nombre.
                  if (crearPresupuesto != true) {
                    await firestoreService.updateCategoriaActual(
                      uid: user.uid,
                      categoria: categoria,
                      monto: monto,
                    );
                  }

                  // C. Crear Nuevo Presupuesto (Si el usuario activó el switch)
                  if (crearPresupuesto == true && montoPresupuesto != null) {
                    if (tipoPresupuesto == 'fijo') {
                      await firestoreService.addGastoFijo(
                        uid: user.uid,
                        nombre: categoria,
                        presupuestado: montoPresupuesto,
                        actual: monto,
                        iconCode: icon?.codePoint,
                        colorValue: color?.value,
                      );
                    } else {
                      await firestoreService.addGastoVariable(
                        uid: user.uid,
                        nombre: categoria,
                        presupuestado: montoPresupuesto,
                        actual: monto,
                        iconCode: icon?.codePoint,
                        colorValue: color?.value,
                      );
                    }
                  }

                  if (context.mounted) Navigator.of(context).pop();

                  await Future.delayed(const Duration(milliseconds: 100));

                  if (mounted) {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(
                        content: Text('Transacción registrada exitosamente'),
                        backgroundColor: Color(0xFF8B5CF6),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(this.context).showSnackBar(
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
    final transaccionesMostradas = widget.transacciones.take(5).toList();

    return Container(
      constraints: const BoxConstraints(
        minWidth: 350,
        maxWidth: 500,
        minHeight: 400,
        maxHeight: 631, // Agregar altura máxima
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Fondo oscuro
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8B5CF6), width: 2),
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
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF581C87), // Fondo morado oscuro
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Color(0xFF8B5CF6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Recent Transactions',
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
                  color: const Color(0xFF334155),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.transacciones.length} items',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Lista de transacciones
          if (transaccionesMostradas.isEmpty)
            _buildEmptyState()
          else
            ...transaccionesMostradas.map((transaccion) {
              return _buildTransactionItem(
                transaccion['categoria'] ?? '',
                transaccion['concepto'] ?? '',
                transaccion['fecha'] ?? '',
                transaccion['monto'] ?? 0.0,
                // NUEVOS PARÁMETROS:
                iconCode: transaccion['icon'],
                colorValue: transaccion['color'],
              );
            }),

          const SizedBox(height: 16),

          // Botones: View All centrado, Add a la derecha
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // View All centrado
              TextButton.icon(
                onPressed: _mostrarTodasLasTransacciones,
                label: const Text('View All'),
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

  Widget _buildTransactionItem(
    String categoria,
    String concepto,
    String fecha,
    double monto, {
    int? iconCode, // <--- Nuevo
    int? colorValue, // <--- Nuevo
  }) {
    bool isIncome =
        monto > 0 &&
        (categoria.toLowerCase().contains('dividend') ||
            categoria.toLowerCase().contains('cashback') ||
            categoria.toLowerCase().contains('salary'));

    IconData icono;
    Color colorIcono;

    // 1. INTENTAR USAR DATOS GUARDADOS
    if (iconCode != null && colorValue != null) {
      icono = IconData(iconCode, fontFamily: 'MaterialIcons');
      colorIcono = Color(colorValue);
    }
    // 2. SI NO HAY, USAR EL MÉTODO ANTIGUO (FALLBACK)
    else {
      switch (categoria.toLowerCase()) {
        case 'combustible':
          icono = Icons.local_gas_station_rounded;
          colorIcono = const Color(0xFFF59E0B);
          break;
        case 'compras':
        case 'groceries':
          icono = Icons.shopping_cart_outlined;
          colorIcono = const Color(0xFF8B5CF6);
          break;
        case 'fast food':
          icono = Icons.restaurant_outlined;
          colorIcono = const Color(0xFFEF4444);
          break;
        case 'retiro efectivo':
        case 'cash withdrawal':
          icono = Icons.account_balance_wallet_outlined;
          colorIcono = const Color(0xFF9CA3AF);
          break;
        case 'agua w magno':
          icono = Icons.water_drop_outlined;
          colorIcono = const Color(0xFF06B6D4);
          break;
        case 'renta':
        case 'rent':
          icono = Icons.home_outlined;
          colorIcono = const Color(0xFF6366F1);
          break;
        case 'suscripciones':
          icono = Icons.subscriptions_outlined;
          colorIcono = const Color(0xFFF59E0B);
          break;
        default:
          icono = Icons.receipt_rounded;
          colorIcono = const Color(0xFF94A3B8);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 0), // Ajuste visual menor
      child: Container(
        margin: const EdgeInsets.only(bottom: 8), // Margen para separación
        padding: const EdgeInsets.all(8), // Padding interno un poco mayor
        decoration: BoxDecoration(
          color: const Color(0xFF334155),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF475569), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorIcono.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icono, size: 20, color: colorIcono),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoria,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF1F5F9),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    concepto,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fecha,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              isIncome
                  ? '+${formatearMoneda(monto.abs())}'
                  : '-${formatearMoneda(monto.abs())}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isIncome
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: const Color(0xFF475569),
            ),
            const SizedBox(height: 12),
            Text(
              'No transactions yet',
              style: TextStyle(fontSize: 14, color: const Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}
