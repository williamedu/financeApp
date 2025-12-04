import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget for displaying filter options in bottom sheet
class FilterBottomSheetWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;
  final Map<String, dynamic> currentFilters;

  const FilterBottomSheetWidget({
    Key? key,
    required this.onApplyFilters,
    required this.currentFilters,
  }) : super(key: key);

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late Map<String, dynamic> _filters;
  late RangeValues _amountRange;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.currentFilters);
    _amountRange = RangeValues(
      (_filters['minAmount'] as double?) ?? 0.0,
      (_filters['maxAmount'] as double?) ?? 10000.0,
    );
    _startDate = (_filters['startDate'] as DateTime?) ??
        DateTime.now().subtract(Duration(days: 30));
    _endDate = (_filters['endDate'] as DateTime?) ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filtros',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: _clearFilters,
                    child: Text(
                      'Limpiar',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1),
            // Filter content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateRangeSection(theme),
                    SizedBox(height: 24),
                    _buildAmountRangeSection(theme),
                    SizedBox(height: 24),
                    _buildCategorySection(theme),
                  ],
                ),
              ),
            ),
            // Apply button
            Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('Aplicar Filtros'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rango de Fechas',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _selectDate(context, true),
                icon: CustomIconWidget(
                  iconName: 'calendar_today',
                  size: 18,
                  color: theme.colorScheme.onSurface,
                ),
                label: Text(
                  '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '-',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _selectDate(context, false),
                icon: CustomIconWidget(
                  iconName: 'calendar_today',
                  size: 18,
                  color: theme.colorScheme.onSurface,
                ),
                label: Text(
                  '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmountRangeSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rango de Monto',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$${_amountRange.start.toStringAsFixed(0)}',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              '\$${_amountRange.end.toStringAsFixed(0)}',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        RangeSlider(
          values: _amountRange,
          min: 0,
          max: 10000,
          divisions: 100,
          onChanged: (values) {
            setState(() {
              _amountRange = values;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCategorySection(ThemeData theme) {
    final categories = [
      {'name': 'Ingreso', 'icon': 'trending_up'},
      {'name': 'Comida', 'icon': 'restaurant'},
      {'name': 'Transporte', 'icon': 'directions_car'},
      {'name': 'Entretenimiento', 'icon': 'movie'},
      {'name': 'Salud', 'icon': 'local_hospital'},
      {'name': 'Compras', 'icon': 'shopping_bag'},
    ];

    final selectedCategories = (_filters['categories'] as List<String>?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categorías',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((category) {
            final isSelected = selectedCategories.contains(category['name']);
            return FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: category['icon'] as String,
                    size: 18,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                  ),
                  SizedBox(width: 8),
                  Text(category['name'] as String),
                ],
              ),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedCategories.add(category['name'] as String);
                  } else {
                    selectedCategories.remove(category['name']);
                  }
                  _filters['categories'] = selectedCategories;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _filters = {};
      _amountRange = RangeValues(0.0, 10000.0);
      _startDate = DateTime.now().subtract(Duration(days: 30));
      _endDate = DateTime.now();
    });
  }

  void _applyFilters() {
    _filters['minAmount'] = _amountRange.start;
    _filters['maxAmount'] = _amountRange.end;
    _filters['startDate'] = _startDate;
    _filters['endDate'] = _endDate;
    widget.onApplyFilters(_filters);
    Navigator.pop(context);
  }
}
