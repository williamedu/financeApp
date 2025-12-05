import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget for displaying empty states
class EmptyStateWidget extends StatelessWidget {
  final String type;
  final VoidCallback? onAction;

  const EmptyStateWidget({super.key, required this.type, this.onAction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String title;
    String message;
    String iconName;
    String? actionText;

    switch (type) {
      case 'no_transactions':
        title = 'No hay transacciones';
        message =
            'Comienza agregando tu primera transacción para llevar un registro de tus finanzas';
        iconName = 'receipt_long';
        actionText = 'Agregar Transacción';
        break;
      case 'no_search_results':
        title = 'Sin resultados';
        message = 'No encontramos transacciones que coincidan con tu búsqueda';
        iconName = 'search_off';
        actionText = null;
        break;
      case 'no_filter_results':
        title = 'Sin resultados';
        message =
            'No hay transacciones que coincidan con los filtros aplicados';
        iconName = 'filter_alt_off';
        actionText = 'Limpiar Filtros';
        break;
      default:
        title = 'Sin datos';
        message = 'No hay información disponible';
        iconName = 'info';
        actionText = null;
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: iconName,
                  size: 64,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              SizedBox(height: 24),
              ElevatedButton(onPressed: onAction, child: Text(actionText)),
            ],
          ],
        ),
      ),
    );
  }
}
