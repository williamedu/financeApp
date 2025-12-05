import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CustomBottomBarItem { home, transactions, budget, profile }

class CustomBottomBar extends StatelessWidget {
  final CustomBottomBarItem selectedItem;
  final ValueChanged<CustomBottomBarItem> onItemSelected;
  final bool showLabels;
  final double? elevation;

  const CustomBottomBar({
    Key? key,
    required this.selectedItem,
    required this.onItemSelected,
    this.showLabels = true,
    this.elevation,
  }) : super(key: key);

  String _getRoutePath(CustomBottomBarItem item) {
    switch (item) {
      case CustomBottomBarItem.home:
        return '/home-dashboard-screen';
      case CustomBottomBarItem.transactions:
        return '/transaction-list-screen';
      case CustomBottomBarItem.budget:
        return '/budget-management-screen';
      case CustomBottomBarItem.profile:
        return '/user-profile-screen';
    }
  }

  IconData _getIcon(CustomBottomBarItem item, bool isSelected) {
    switch (item) {
      case CustomBottomBarItem.home:
        return isSelected ? Icons.home : Icons.home_outlined;
      case CustomBottomBarItem.transactions:
        return isSelected ? Icons.receipt_long : Icons.receipt_long_outlined;
      case CustomBottomBarItem.budget:
        return isSelected ? Icons.pie_chart : Icons.pie_chart_outline;
      case CustomBottomBarItem.profile:
        return isSelected ? Icons.person : Icons.person_outline;
    }
  }

  String _getLabel(CustomBottomBarItem item) {
    switch (item) {
      case CustomBottomBarItem.home:
        return 'Inicio';
      case CustomBottomBarItem.transactions:
        return 'Entradas';
      case CustomBottomBarItem.budget:
        return 'Presup.';
      case CustomBottomBarItem.profile:
        return 'Perfil';
    }
  }

  void _handleItemTap(BuildContext context, CustomBottomBarItem item) {
    HapticFeedback.lightImpact();
    if (item == selectedItem) {
      onItemSelected(item);
      return;
    }
    Navigator.pushReplacementNamed(context, _getRoutePath(item));
    onItemSelected(item);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Fondo oscuro fijo para consistencia
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 72, // AUMENTADO de 64 a 72 para evitar overflow
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ), // MENOS padding vertical
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: CustomBottomBarItem.values.map((item) {
              final isSelected = item == selectedItem;
              return Expanded(
                child: _NavigationItem(
                  icon: _getIcon(item, isSelected),
                  label: _getLabel(item),
                  isSelected: isSelected,
                  showLabel: showLabels,
                  onTap: () => _handleItemTap(context, item),
                  selectedColor: const Color(0xFF6366F1),
                  unselectedColor: const Color(0xFF94A3B8),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool showLabel;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color unselectedColor;

  const _NavigationItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.showLabel,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? selectedColor : unselectedColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          // REDUCIDO: Padding vertical ajustado para que quepa todo
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(icon, size: 26, color: color),
              ),
              if (showLabel) ...[
                const SizedBox(height: 4),
                Flexible(
                  // Flexible evita el error de overflow si el texto es grande
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
