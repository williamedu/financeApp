import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';

class FinancialSummaryCardWidget extends StatelessWidget {
  final double totalIngresos;
  final double gastadoHastaAhora;
  final double disponibleGastar;

  const FinancialSummaryCardWidget({
    Key? key,
    required this.totalIngresos,
    required this.gastadoHastaAhora,
    required this.disponibleGastar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Definimos colores específicos para cada métrica
    final colorIngresos = Colors.greenAccent[400]; // Verde brillante
    final colorGastado = Colors.redAccent[200]; // Rojo suave
    final colorDisponible = Colors.white; // Blanco (destacado)

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.symmetric(vertical: 2.5.h, horizontal: 4.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Fondo tarjeta oscuro (Slate 800)
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF334155), // Borde sutil
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. INGRESOS
          _buildCompactMetric(
            context,
            label: 'Ingresos',
            amount: totalIngresos,
            color: colorIngresos!,
            icon: Icons.arrow_upward_rounded,
          ),

          // Divisor vertical
          Container(height: 4.h, width: 1, color: Colors.grey.withOpacity(0.3)),

          // 2. GASTADO
          _buildCompactMetric(
            context,
            label: 'Gastado',
            amount: gastadoHastaAhora,
            color: colorGastado!,
            icon: Icons.arrow_downward_rounded,
          ),

          // Divisor vertical
          Container(height: 4.h, width: 1, color: Colors.grey.withOpacity(0.3)),

          // 3. DISPONIBLE (Más destacado)
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
    // Formato de moneda simple (sin decimales .00 para ahorrar espacio si es entero)
    String amountString = amount.toStringAsFixed(2).replaceAll('.', ',');
    if (amountString.endsWith(",00")) {
      amountString = amountString.substring(0, amountString.length - 3);
    }

    return Expanded(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.center, // Centrado para diseño compacto
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
                  fontSize: 9.sp, // Letra pequeña para el título
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Text(
            '\$$amountString',
            style: TextStyle(
              color: color,
              fontSize: isMain ? 13.sp : 11.sp, // Disponible un poco más grande
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
