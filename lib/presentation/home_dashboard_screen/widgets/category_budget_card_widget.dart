import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

class CategoryBudgetCardWidget extends StatelessWidget {
  final String name;
  final double budget;
  final double spent;
  final int? iconCode;
  final int? colorValue;
  final bool isIncome;
  final String currencySymbol;

  const CategoryBudgetCardWidget({
    super.key,
    required this.name,
    required this.budget,
    required this.spent,
    this.iconCode,
    this.colorValue,
    this.isIncome = false,
    this.currencySymbol = '\$',
  });

  @override
  Widget build(BuildContext context) {
    final color = colorValue != null ? Color(colorValue!) : Colors.blue;
    final icon = iconCode != null
        ? IconData(iconCode!, fontFamily: 'MaterialIcons')
        : Icons.category;

    double progress = 0.0;
    if (budget > 0) {
      progress = (spent / budget).clamp(0.0, 1.0);
    }

    final isOverBudget = !isIncome && (spent > budget);
    final progressColor = isOverBudget ? Colors.redAccent : color;

    final String labelMonto = isIncome ? 'Recibido' : 'Gastado';
    final String labelTotal = isIncome ? 'Estimado' : 'de';

    // CORRECCIÓN: Agregamos el espacio al símbolo
    final locale = currencySymbol == '€' ? 'es_ES' : 'en_US';
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: '$currencySymbol ', // <--- EL ESPACIO AQUÍ
      decimalDigits: 0,
    );

    final spentStr = formatter.format(spent);
    final budgetStr = formatter.format(budget);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                        children: [
                          TextSpan(text: '$labelMonto '),
                          TextSpan(
                            text: '$spentStr ',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (!isIncome || spent < budget) ...[
                            TextSpan(text: '$labelTotal '),
                            TextSpan(text: budgetStr),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isOverBudget
                      ? Colors.red.withOpacity(0.2)
                      : color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: isOverBudget ? Colors.redAccent : color,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFF334155),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
          ),

          if (isOverBudget) ...[
            SizedBox(height: 1.h),
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.redAccent,
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  'Excedido por ${formatter.format(spent - budget)}',
                  style: TextStyle(color: Colors.redAccent, fontSize: 10.sp),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
