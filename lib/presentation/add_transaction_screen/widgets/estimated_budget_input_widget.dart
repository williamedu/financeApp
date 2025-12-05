import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

/// Estimated Budget input field (shown only for Fixed/Variable Expense)
class EstimatedBudgetInputWidget extends StatelessWidget {
  final TextEditingController controller;

  const EstimatedBudgetInputWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.account_balance_wallet,
              color: AppTheme.incomeGold,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              'Presupuesto Estimado',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 1.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: AppTheme.warningOrange.withAlpha(51),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Requerido',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppTheme.warningOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.5.h),
        TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          style: theme.textTheme.headlineMedium?.copyWith(
            color: AppTheme.incomeGold,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 4.w, top: 2.h),
              child: Text(
                '\$',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppTheme.incomeGold,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            hintText: '0.00',
            hintStyle: theme.textTheme.headlineMedium?.copyWith(
              color: AppTheme.textSecondary.withAlpha(128),
              fontWeight: FontWeight.w700,
            ),
            filled: true,
            fillColor: AppTheme.surfaceContainerDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.borderSubtle, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.borderSubtle, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.incomeGold, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 4.w,
              vertical: 2.h,
            ),
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Este campo es obligatorio para gastos fijos y variables',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
