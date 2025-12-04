import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Widget for date selection with calendar picker
class DatePickerWidget extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const DatePickerWidget({
    Key? key,
    required this.selectedDate,
    required this.onDateSelected,
  }) : super(key: key);

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: AppTheme.incomeGold,
              onPrimary: AppTheme.primaryBackgroundDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      onDateSelected(picked);
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    return '${date.day} de ${months[date.month - 1]}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _selectDate(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 2.h,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'calendar_today',
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      _formatDate(selectedDate),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  CustomIconWidget(
                    iconName: 'arrow_drop_down',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
