import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Navigation item configuration for the bottom navigation bar
enum CustomBottomBarItem {
  home,
  transactions,
  budget,
  profile,
}

/// Custom bottom navigation bar widget for the personal finance application
/// Implements Material 3 design with platform-specific adaptations
class CustomBottomBar extends StatelessWidget {
  /// Currently selected navigation item
  final CustomBottomBarItem selectedItem;

  /// Callback when a navigation item is tapped
  final ValueChanged<CustomBottomBarItem> onItemSelected;

  /// Whether to show labels for navigation items
  final bool showLabels;

  /// Custom elevation for the bottom bar
  final double? elevation;

  const CustomBottomBar({
    Key? key,
    required this.selectedItem,
    required this.onItemSelected,
    this.showLabels = true,
    this.elevation,
  }) : super(key: key);

  /// Get the route path for a navigation item
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

  /// Get the icon for a navigation item
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

  /// Get the label for a navigation item
  String _getLabel(CustomBottomBarItem item) {
    switch (item) {
      case CustomBottomBarItem.home:
        return 'Inicio';
      case CustomBottomBarItem.transactions:
        return 'Transacciones';
      case CustomBottomBarItem.budget:
        return 'Presupuesto';
      case CustomBottomBarItem.profile:
        return 'Perfil';
    }
  }

  /// Handle navigation item tap with haptic feedback
  void _handleItemTap(BuildContext context, CustomBottomBarItem item) {
    // Provide haptic feedback for better user experience
    HapticFeedback.lightImpact();

    // If same item is tapped, scroll to top (iOS behavior)
    if (item == selectedItem) {
      // This would require access to scroll controller in the actual screen
      // For now, just trigger the callback
      onItemSelected(item);
      return;
    }

    // Navigate to the selected screen
    final routePath = _getRoutePath(item);
    Navigator.pushReplacementNamed(context, routePath);

    // Notify parent of selection change
    onItemSelected(item);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            offset: Offset(0, -2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 64,
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: CustomBottomBarItem.values.map((item) {
              final isSelected = item == selectedItem;
              final icon = _getIcon(item, isSelected);
              final label = _getLabel(item);

              return Expanded(
                child: _NavigationItem(
                  icon: icon,
                  label: label,
                  isSelected: isSelected,
                  showLabel: showLabels,
                  onTap: () => _handleItemTap(context, item),
                  selectedColor: colorScheme.primary,
                  unselectedColor: colorScheme.onSurfaceVariant,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

/// Individual navigation item widget
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
    final theme = Theme.of(context);
    final color = isSelected ? selectedColor : unselectedColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: selectedColor.withValues(alpha: 0.1),
        highlightColor: selectedColor.withValues(alpha: 0.05),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with scale animation
              AnimatedScale(
                scale: isSelected ? 1.1 : 1.0,
                duration: Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: Icon(
                  icon,
                  size: 24,
                  color: color,
                ),
              ),

              // Label with fade animation
              if (showLabel) ...[
                SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  style: theme.textTheme.labelSmall!.copyWith(
                    color: color,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 11,
                    height: 1.0,
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
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
