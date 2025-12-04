import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

/// Widget for amount input with currency symbol and large typography
class AmountInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool isIncome;
  final Function(bool) onTypeChanged;

  const AmountInputWidget({
    Key? key,
    required this.controller,
    required this.isIncome,
    required this.onTypeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Transaction type toggle
          Row(
            children: [
              Expanded(
                child: _TypeButton(
                  label: 'Ingreso',
                  isSelected: isIncome,
                  color: AppTheme.incomeGold,
                  onTap: () => onTypeChanged(true),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _TypeButton(
                  label: 'Gasto',
                  isSelected: !isIncome,
                  color: AppTheme.expenseRed,
                  onTap: () => onTypeChanged(false),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Amount label
          Text(
            'Monto',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),

          // Amount input field
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '\$',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: isIncome ? AppTheme.incomeGold : AppTheme.expenseRed,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: theme.textTheme.displaySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.3),
                      fontWeight: FontWeight.w700,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Type selection button widget
class _TypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.5.h),
          decoration: BoxDecoration(
            color:
                isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : theme.colorScheme.outline,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
