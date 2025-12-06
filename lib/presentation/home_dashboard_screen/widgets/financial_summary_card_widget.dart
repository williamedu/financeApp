import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

class FinancialSummaryCardWidget extends StatelessWidget {
  final double totalIngresos;
  final double gastadoHastaAhora;
  final double disponibleGastar;
  final String currencySymbol;

  const FinancialSummaryCardWidget({
    super.key, // Esto ya se encarga de todo
    required this.totalIngresos,
    required this.gastadoHastaAhora,
    required this.disponibleGastar,
    this.currencySymbol = '\$',
  }); // <--- AQUÍ TERMINA, sin los dos puntos ni el super(...)

  @override
  Widget build(BuildContext context) {
    final colorIngresos = Colors.greenAccent[400];
    final colorGastado = Colors.redAccent[200];
    final colorDisponible = Colors.white;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.symmetric(vertical: 2.5.h, horizontal: 4.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFF334155), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCompactMetric(
            context,
            label: 'Ingresos',
            amount: totalIngresos,
            color: colorIngresos!,
            icon: Icons.arrow_upward_rounded,
          ),

          Container(height: 4.h, width: 1, color: Colors.grey.withOpacity(0.3)),

          _buildCompactMetric(
            context,
            label: 'Gastado',
            amount: gastadoHastaAhora,
            color: colorGastado!,
            icon: Icons.arrow_downward_rounded,
          ),

          Container(height: 4.h, width: 1, color: Colors.grey.withOpacity(0.3)),

          _buildCompactMetric(
            context,
            label: 'Disponible',
            amount: disponibleGastar,
            color: colorDisponible,
            icon: Icons.account_balance_wallet_outlined,
            isMain: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactMetric(
    BuildContext context, {
    required String label,
    required double amount,
    required Color color,
    required IconData icon,
    bool isMain = false,
  }) {
    // CORRECCIÓN: Agregamos un espacio al símbolo '$currencySymbol '
    final locale = currencySymbol == '€' ? 'es_ES' : 'en_US';
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: '$currencySymbol ', // <--- EL ESPACIO MÁGICO AQUÍ
    );
    final amountString = formatter.format(amount);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 12.sp, color: color.withOpacity(0.8)),
              SizedBox(width: 1.w),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Text(
            amountString,
            style: TextStyle(
              color: color,
              fontSize: isMain ? 11.sp : 10.sp,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
