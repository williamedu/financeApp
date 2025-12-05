import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget for displaying horizontal scrolling filter chips
class TransactionFilterChipsWidget extends StatelessWidget {
  final List<String> activeFilters;
  final Function(String) onRemoveFilter;

  const TransactionFilterChipsWidget({
    super.key,
    required this.activeFilters,
    required this.onRemoveFilter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (activeFilters.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      height: 48,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: activeFilters.length,
        separatorBuilder: (context, index) => SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = activeFilters[index];
          return Chip(
            label: Text(
              filter,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            deleteIcon: CustomIconWidget(
              iconName: 'close',
              size: 18,
              color: theme.colorScheme.onSurface,
            ),
            onDeleted: () => onRemoveFilter(filter),
            backgroundColor: theme.colorScheme.surface,
            side: BorderSide(color: theme.colorScheme.outline, width: 1),
          );
        },
      ),
    );
  }
}
