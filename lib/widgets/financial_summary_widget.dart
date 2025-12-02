import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FinancialSummaryWidget extends StatelessWidget {
  final double availableToSpend;
  final double spentSoFar;
  final double savings;
  final double debts;

  const FinancialSummaryWidget({
    super.key,
    required this.availableToSpend,
    required this.spentSoFar,
    required this.savings,
    required this.debts,
  });

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
    return Container(
      constraints: const BoxConstraints(minWidth: 350, maxWidth: 1400),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.pie_chart_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'FINANCIAL SUMMARY',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MMMM yyyy').format(DateTime.now()),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Grid de 4 tarjetas
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Available to Spend',
                  availableToSpend,
                  Icons.account_balance_wallet_rounded,
                  const Color(0xFF10B981),
                  const Color(0xFF064E3B),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildSummaryCard(
                  'Spent So Far',
                  spentSoFar,
                  Icons.shopping_cart_rounded,
                  const Color(0xFFEF4444),
                  const Color(0xFF7F1D1D),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildSummaryCard(
                  'Savings',
                  savings,
                  Icons.savings_rounded,
                  const Color(0xFF3B82F6),
                  const Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildSummaryCard(
                  'Debts',
                  debts,
                  Icons.credit_card_rounded,
                  const Color(0xFFF59E0B),
                  const Color(0xFF78350F),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    double value,
    IconData icon,
    Color iconColor,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Fondo oscuro
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícono y label
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8), // Texto gris claro
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Monto
          Text(
            formatearMoneda(value),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: iconColor,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
