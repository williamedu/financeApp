import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget for category selection with horizontal scrolling chips
class CategorySelectorWidget extends StatelessWidget {
  final String? selectedCategory;
  final Function(String) onCategorySelected;
  final VoidCallback onAddCategory;

  const CategorySelectorWidget({
    Key? key,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onAddCategory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Map<String, dynamic>> categories = [
      {
        "id": "food",
        "name": "Comida",
        "icon": "restaurant",
        "color": Color(0xFFEF4444),
      },
      {
        "id": "transport",
        "name": "Transporte",
        "icon": "directions_car",
        "color": Color(0xFF3B82F6),
      },
      {
        "id": "entertainment",
        "name": "Entretenimiento",
        "icon": "movie",
        "color": Color(0xFF8B5CF6),
      },
      {
        "id": "shopping",
        "name": "Compras",
        "icon": "shopping_bag",
        "color": Color(0xFFF59E0B),
      },
      {
        "id": "health",
        "name": "Salud",
        "icon": "local_hospital",
        "color": Color(0xFF10B981),
      },
      {
        "id": "education",
        "name": "Educación",
        "icon": "school",
        "color": Color(0xFF06B6D4),
      },
      {
        "id": "bills",
        "name": "Facturas",
        "icon": "receipt",
        "color": Color(0xFFF97316),
      },
      {
        "id": "salary",
        "name": "Salario",
        "icon": "account_balance_wallet",
        "color": Color(0xFF10B981),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoría',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        SizedBox(
          height: 12.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length + 1,
            itemBuilder: (context, index) {
              if (index == categories.length) {
                return _AddCategoryChip(onTap: onAddCategory);
              }

              final category = categories[index];
              final isSelected = selectedCategory == category["id"];

              return Padding(
                padding: EdgeInsets.only(right: 3.w),
                child: _CategoryChip(
                  name: category["name"] as String,
                  icon: category["icon"] as String,
                  color: category["color"] as Color,
                  isSelected: isSelected,
                  onTap: () => onCategorySelected(category["id"] as String),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Individual category chip widget
class _CategoryChip extends StatelessWidget {
  final String name;
  final String icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    Key? key,
    required this.name,
    required this.icon,
    required this.color,
    required this.isSelected,
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
          width: 20.w,
          padding: EdgeInsets.symmetric(vertical: 1.5.h),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.15)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : theme.colorScheme.outline,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: icon,
                    color: color,
                    size: 24,
                  ),
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                name,
                style: theme.textTheme.bodySmall?.copyWith(
                  color:
                      isSelected ? color : theme.colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Add category chip widget
class _AddCategoryChip extends StatelessWidget {
  final VoidCallback onTap;

  const _AddCategoryChip({
    Key? key,
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
          width: 20.w,
          padding: EdgeInsets.symmetric(vertical: 1.5.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline,
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'add',
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Agregar',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
