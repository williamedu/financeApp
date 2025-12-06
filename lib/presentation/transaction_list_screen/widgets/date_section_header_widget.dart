import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSectionHeaderWidget extends StatelessWidget {
  final DateTime date;
  final double totalAmount;
  final bool isIncome;
  final String currencySymbol; // <--- ESTO FALTABA

  const DateSectionHeaderWidget({
    super.key,
    required this.date,
    required this.totalAmount,
    required this.isIncome,
    this.currencySymbol = '\$', // Valor por defecto
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Hoy';
    if (dateOnly == yesterday) return 'Ayer';
    return DateFormat('d \'de\' MMMM', 'es_ES').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = currencySymbol == '€' ? 'es_ES' : 'en_US';
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: '$currencySymbol ',
    );
    final totalStr = formatter.format(totalAmount);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // FECHA NORMAL
          Text(
            _formatDate(date),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),

          // TOTAL DEL DÍA GRANDE (Tu petición)
          Text(
            totalStr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18, // <--- GRANDE
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
