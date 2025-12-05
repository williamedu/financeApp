import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

/// Multi-option entry type selector (Transaction, Fixed Expense, Variable Expense)
class EntryTypeSelectorWidget extends StatelessWidget {
  final String selectedType;
  final Function(String) onTypeChanged;

  const EntryTypeSelectorWidget({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Entrada',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.5.h),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderSubtle, width: 1),
          ),
          child: Column(
            children: [
              _buildOption(
                context: context,
                title: 'Transacción',
                subtitle: 'Ingreso o gasto regular',
                value: 'transaction',
                icon: Icons.sync_alt,
                color: AppTheme.interactiveBlue,
              ),
              Divider(height: 1, color: AppTheme.borderSubtle),
              _buildOption(
                context: context,
                title: 'Gasto Fijo',
                subtitle: 'Factura mensual recurrente',
                value: 'fixed_expense',
                icon: Icons.calendar_today,
                color: AppTheme.expenseRed,
              ),
              Divider(height: 1, color: AppTheme.borderSubtle),
              _buildOption(
                context: context,
                title: 'Gasto Variable',
                subtitle: 'Categoría de presupuesto',
                value: 'variable_expense',
                icon: Icons.trending_down,
                color: AppTheme.warningOrange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isSelected = selectedType == value;

    return InkWell(
      onTap: () => onTypeChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(26) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: isSelected ? color.withAlpha(51) : color.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: EdgeInsets.all(0.5.w),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(Icons.check, color: Colors.white, size: 16),
              )
            else
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.borderSubtle, width: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
