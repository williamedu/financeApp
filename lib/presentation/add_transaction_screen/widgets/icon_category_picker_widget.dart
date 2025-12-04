import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

/// Advanced icon/category picker modal bottom sheet with categorized grid
class IconCategoryPickerWidget extends StatefulWidget {
  final Function(String categoryId, IconData icon, Color color) onSelected;

  const IconCategoryPickerWidget({
    Key? key,
    required this.onSelected,
  }) : super(key: key);

  @override
  State<IconCategoryPickerWidget> createState() =>
      _IconCategoryPickerWidgetState();
}

class _IconCategoryPickerWidgetState extends State<IconCategoryPickerWidget> {
  String? _selectedCategory;
  IconData? _selectedIcon;
  Color _selectedColor = AppTheme.incomeGold;

  final Map<String, List<Map<String, dynamic>>> _categorizedIcons = {
    'Dinero': [
      {'icon': Icons.account_balance_wallet, 'name': 'Cartera'},
      {'icon': Icons.account_balance, 'name': 'Banco'},
      {'icon': Icons.attach_money, 'name': 'Dinero'},
      {'icon': Icons.credit_card, 'name': 'Tarjeta'},
      {'icon': Icons.savings, 'name': 'Ahorros'},
      {'icon': Icons.currency_exchange, 'name': 'Cambio'},
    ],
    'Trabajo': [
      {'icon': Icons.work, 'name': 'Trabajo'},
      {'icon': Icons.business, 'name': 'Negocio'},
      {'icon': Icons.business_center, 'name': 'Oficina'},
      {'icon': Icons.laptop, 'name': 'Laptop'},
      {'icon': Icons.engineering, 'name': 'Ingeniería'},
      {'icon': Icons.architecture, 'name': 'Arquitectura'},
    ],
    'Hogar': [
      {'icon': Icons.home, 'name': 'Casa'},
      {'icon': Icons.house, 'name': 'Hogar'},
      {'icon': Icons.lightbulb, 'name': 'Luz'},
      {'icon': Icons.water_drop, 'name': 'Agua'},
      {'icon': Icons.heat_pump, 'name': 'Gas'},
      {'icon': Icons.wifi, 'name': 'Internet'},
    ],
    'Transporte': [
      {'icon': Icons.directions_car, 'name': 'Auto'},
      {'icon': Icons.directions_bus, 'name': 'Bus'},
      {'icon': Icons.directions_subway, 'name': 'Metro'},
      {'icon': Icons.local_gas_station, 'name': 'Gasolina'},
      {'icon': Icons.flight, 'name': 'Vuelo'},
      {'icon': Icons.two_wheeler, 'name': 'Moto'},
    ],
    'Comida': [
      {'icon': Icons.restaurant, 'name': 'Restaurante'},
      {'icon': Icons.fastfood, 'name': 'Comida Rápida'},
      {'icon': Icons.local_cafe, 'name': 'Café'},
      {'icon': Icons.local_pizza, 'name': 'Pizza'},
      {'icon': Icons.shopping_cart, 'name': 'Supermercado'},
      {'icon': Icons.cake, 'name': 'Postre'},
    ],
    'Entretenimiento': [
      {'icon': Icons.movie, 'name': 'Cine'},
      {'icon': Icons.sports_esports, 'name': 'Videojuegos'},
      {'icon': Icons.music_note, 'name': 'Música'},
      {'icon': Icons.sports_soccer, 'name': 'Deportes'},
      {'icon': Icons.theater_comedy, 'name': 'Teatro'},
      {'icon': Icons.beach_access, 'name': 'Playa'},
    ],
    'Salud': [
      {'icon': Icons.local_hospital, 'name': 'Hospital'},
      {'icon': Icons.medication, 'name': 'Medicina'},
      {'icon': Icons.fitness_center, 'name': 'Gimnasio'},
      {'icon': Icons.healing, 'name': 'Salud'},
      {'icon': Icons.psychology, 'name': 'Mental'},
      {'icon': Icons.spa, 'name': 'Spa'},
    ],
    'Educación': [
      {'icon': Icons.school, 'name': 'Escuela'},
      {'icon': Icons.menu_book, 'name': 'Libros'},
      {'icon': Icons.computer, 'name': 'Cursos'},
      {'icon': Icons.science, 'name': 'Ciencia'},
      {'icon': Icons.language, 'name': 'Idiomas'},
      {'icon': Icons.calculate, 'name': 'Matemáticas'},
    ],
  };

  final List<Color> _availableColors = [
    AppTheme.incomeGold,
    AppTheme.expenseRed,
    AppTheme.successGreen,
    AppTheme.interactiveBlue,
    AppTheme.warningOrange,
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF06B6D4),
    Color(0xFF14B8A6),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF10B981),
  ];

  void _handleSelection() {
    if (_selectedCategory != null && _selectedIcon != null) {
      widget.onSelected(_selectedCategory!, _selectedIcon!, _selectedColor);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: AppTheme.primaryBackgroundDark,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.borderSubtle, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Seleccionar Categoría/Icono',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Color selector
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerDark,
              border: Border(
                bottom: BorderSide(color: AppTheme.borderSubtle, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Color',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _availableColors.map((color) {
                      final isSelected = color == _selectedColor;
                      return Padding(
                        padding: EdgeInsets.only(right: 2.w),
                        child: InkWell(
                          onTap: () => setState(() => _selectedColor = color),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 12.w,
                            height: 12.w,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Categorized icon grid
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              itemCount: _categorizedIcons.keys.length,
              itemBuilder: (context, sectionIndex) {
                final section =
                    _categorizedIcons.keys.elementAt(sectionIndex);
                final icons = _categorizedIcons[section]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      child: Text(
                        section,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: _selectedColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 2.w,
                          mainAxisSpacing: 1.h,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: icons.length,
                        itemBuilder: (context, index) {
                          final iconData = icons[index];
                          final isSelected =
                              _selectedIcon == iconData['icon'] &&
                                  _selectedCategory == iconData['name'];

                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedIcon = iconData['icon'];
                                _selectedCategory = iconData['name'];
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _selectedColor.withAlpha(51)
                                    : AppTheme.surfaceContainerDark,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? _selectedColor
                                      : AppTheme.borderSubtle,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    iconData['icon'],
                                    color: isSelected
                                        ? _selectedColor
                                        : AppTheme.textSecondary,
                                    size: 28,
                                  ),
                                  SizedBox(height: 0.5.h),
                                  Text(
                                    iconData['name'],
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: isSelected
                                          ? theme.colorScheme.onSurface
                                          : AppTheme.textSecondary,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 2.h),
                  ],
                );
              },
            ),
          ),

          // Confirm button
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerDark,
              border: Border(
                top: BorderSide(color: AppTheme.borderSubtle, width: 1),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedIcon != null ? _handleSelection : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Confirmar Selección',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}