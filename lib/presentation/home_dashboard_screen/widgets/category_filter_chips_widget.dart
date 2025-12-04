import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Horizontal scrolling filter chips for transaction categories
class CategoryFilterChipsWidget extends StatefulWidget {
  final Function(String) onCategorySelected;

  const CategoryFilterChipsWidget({
    Key? key,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  State<CategoryFilterChipsWidget> createState() =>
      _CategoryFilterChipsWidgetState();
}

class _CategoryFilterChipsWidgetState extends State<CategoryFilterChipsWidget> {
  String _selectedCategory = 'Todos';

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Todos', 'icon': 'apps'},
    {'label': 'Ingresos', 'icon': 'arrow_downward'},
    {'label': 'Gastos Fijos', 'icon': 'home'},
    {'label': 'Variables', 'icon': 'shopping_cart'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 6.h,
      margin: EdgeInsets.symmetric(vertical: 2.h),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: _categories.length,
        separatorBuilder: (context, index) => SizedBox(width: 2.w),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category['label'];

          return FilterChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: category['icon'] as String,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  size: 18,
                ),
                SizedBox(width: 2.w),
                Text(
                  category['label'] as String,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _selectedCategory = category['label'] as String;
              });
              widget.onCategorySelected(_selectedCategory);
            },
            backgroundColor: theme.colorScheme.surface,
            selectedColor: theme.colorScheme.primary.withValues(alpha: 0.15),
            side: BorderSide(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
              width: isSelected ? 2 : 1,
            ),
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
      ),
    );
  }
}
