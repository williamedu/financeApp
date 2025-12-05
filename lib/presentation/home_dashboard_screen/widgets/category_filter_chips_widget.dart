import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class CategoryFilterChipsWidget extends StatefulWidget {
  final Function(String) onCategorySelected;

  const CategoryFilterChipsWidget({Key? key, required this.onCategorySelected})
    : super(key: key);

  @override
  State<CategoryFilterChipsWidget> createState() =>
      _CategoryFilterChipsWidgetState();
}

class _CategoryFilterChipsWidgetState extends State<CategoryFilterChipsWidget> {
  // CAMBIO IMPORTANTE: El valor inicial ahora es 'Transacciones'
  String _selectedCategory = 'Transacciones';

  // CAMBIO IMPORTANTE: Lista actualizada sin 'Todos'
  final List<Map<String, dynamic>> _categories = [
    {'label': 'Transacciones', 'icon': Icons.list_alt},
    {'label': 'Ingresos', 'icon': Icons.arrow_upward},
    {'label': 'Gastos Fijos', 'icon': Icons.home_outlined},
    {'label': 'Variables', 'icon': Icons.shopping_cart_outlined},
  ];

  @override
  Widget build(BuildContext context) {
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
                Icon(
                  category['icon'],
                  color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                  size: 18,
                ),
                SizedBox(width: 2.w),
                Text(
                  category['label'] as String,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF94A3B8),
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
            backgroundColor: const Color(0xFF1E293B),
            selectedColor: const Color(0xFF6366F1),
            checkmarkColor: Colors.white,
            side: BorderSide(
              color: isSelected
                  ? const Color(0xFF6366F1)
                  : const Color(0xFF334155),
              width: 1,
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
