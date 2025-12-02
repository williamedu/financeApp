import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewTransactionsDialog extends StatelessWidget {
  final List<Map<String, dynamic>> transacciones;

  const ViewTransactionsDialog({super.key, required this.transacciones});

  String formatearMoneda(double valor) {
    final formatoDominicano = NumberFormat.currency(
      locale: 'es_DO',
      symbol: '',
      decimalDigits: 2,
    );
    return 'RD\$ ${formatoDominicano.format(valor).trim()}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E293B), // Fondo oscuro
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 900,
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
                    color: const Color(0xFF581C87),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: Color(0xFF8B5CF6),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Todas las Transacciones',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF1F5F9),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${transacciones.length} transacciones en total',
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

            // Lista de transacciones con scroll
            Expanded(
              child: transacciones.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: transacciones.length,
                      itemBuilder: (context, index) {
                        final transaccion = transacciones[index];
                        return _buildTransactionItem(
                          transaccion['categoria'] ?? '',
                          transaccion['concepto'] ?? '',
                          transaccion['fecha'] ?? '',
                          transaccion['monto'] ?? 0.0,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    String categoria,
    String concepto,
    String fecha,
    double monto,
  ) {
    bool isIncome =
        monto > 0 &&
        (categoria.toLowerCase().contains('dividend') ||
            categoria.toLowerCase().contains('cashback') ||
            categoria.toLowerCase().contains('salary'));

    IconData icono;
    Color colorIcono;

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

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF334155),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF475569), width: 1),
        ),
        child: Row(
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
                    categoria,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF1F5F9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    concepto,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF94A3B8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fecha,
                    style: const TextStyle(
                      fontSize: 12,
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
                fontSize: 17,
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
            'No hay transacciones aún',
            style: TextStyle(fontSize: 16, color: const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
