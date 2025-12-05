import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/budget_alert_card_widget.dart';
import './widgets/budget_header_widget.dart';
import './widgets/budget_summary_card_widget.dart';
import './widgets/category_budget_card_widget.dart';
import './widgets/empty_budget_state_widget.dart';

class BudgetManagementScreen extends StatefulWidget {
  const BudgetManagementScreen({super.key});

  @override
  State<BudgetManagementScreen> createState() => _BudgetManagementScreenState();
}

class _BudgetManagementScreenState extends State<BudgetManagementScreen> {
  int _currentMonthIndex = 0;
  bool _isMonthlyView = true;
  bool _isLoading = false;

  final List<String> _months = [
    'Enero 2025',
    'Febrero 2025',
    'Marzo 2025',
    'Abril 2025',
    'Mayo 2025',
    'Junio 2025',
    'Julio 2025',
    'Agosto 2025',
    'Septiembre 2025',
    'Octubre 2025',
    'Noviembre 2025',
    'Diciembre 2025',
  ];

  // Mock budget data
  final List<Map<String, dynamic>> _categoryBudgets = [
    {
      "categoryName": "Alimentación",
      "categoryIcon": "restaurant",
      "categoryColor": 0xFFF59E0B,
      "allocatedAmount": 500.00,
      "spentAmount": 425.50,
    },
    {
      "categoryName": "Transporte",
      "categoryIcon": "directions_car",
      "categoryColor": 0xFF3B82F6,
      "allocatedAmount": 300.00,
      "spentAmount": 280.00,
    },
    {
      "categoryName": "Entretenimiento",
      "categoryIcon": "movie",
      "categoryColor": 0xFF10B981,
      "allocatedAmount": 200.00,
      "spentAmount": 195.00,
    },
    {
      "categoryName": "Servicios",
      "categoryIcon": "receipt_long",
      "categoryColor": 0xFFEF4444,
      "allocatedAmount": 400.00,
      "spentAmount": 420.00,
    },
    {
      "categoryName": "Salud",
      "categoryIcon": "local_hospital",
      "categoryColor": 0xFF8B5CF6,
      "allocatedAmount": 250.00,
      "spentAmount": 180.00,
    },
    {
      "categoryName": "Educación",
      "categoryIcon": "school",
      "categoryColor": 0xFFEC4899,
      "allocatedAmount": 350.00,
      "spentAmount": 300.00,
    },
  ];

  final List<Map<String, dynamic>> _budgetAlerts = [
    {
      "categoryName": "Servicios",
      "message": "Has excedido tu presupuesto en \$20.00",
      "alertType": "exceeded",
    },
    {
      "categoryName": "Entretenimiento",
      "message": "Has gastado el 97.5% de tu presupuesto",
      "alertType": "warning",
    },
  ];

  double get _totalBudget {
    return (_categoryBudgets as List).fold(
      0.0,
      (sum, budget) => sum + (budget["allocatedAmount"] as double),
    );
  }

  double get _totalSpent {
    return (_categoryBudgets as List).fold(
      0.0,
      (sum, budget) => sum + (budget["spentAmount"] as double),
    );
  }

  double get _remainingBalance => _totalBudget - _totalSpent;

  double get _spendingPercentage {
    if (_totalBudget == 0) return 0;
    return (_totalSpent / _totalBudget * 100).clamp(0, 100);
  }

  void _navigateToPreviousMonth() {
    setState(() {
      if (_currentMonthIndex > 0) {
        _currentMonthIndex--;
      }
    });
  }

  void _navigateToNextMonth() {
    setState(() {
      if (_currentMonthIndex < _months.length - 1) {
        _currentMonthIndex++;
      }
    });
  }

  void _showNewBudgetDialog() {
    showDialog(
      context: context,
      builder: (context) => _NewBudgetDialog(
        onSave: (categoryName, amount) {
          setState(() {
            _categoryBudgets.add({
              "categoryName": categoryName,
              "categoryIcon": "category",
              "categoryColor": 0xFF3B82F6,
              "allocatedAmount": amount,
              "spentAmount": 0.0,
            });
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Presupuesto creado exitosamente'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        },
      ),
    );
  }

  void _showEditBudgetDialog(int index) {
    final budget = _categoryBudgets[index];
    showDialog(
      context: context,
      builder: (context) => _EditBudgetDialog(
        categoryName: budget["categoryName"] as String,
        currentAmount: budget["allocatedAmount"] as double,
        onSave: (amount) {
          setState(() {
            _categoryBudgets[index]["allocatedAmount"] = amount;
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Presupuesto actualizado'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(int index) {
    final budget = _categoryBudgets[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Presupuesto'),
        content: Text(
          '¿Estás seguro de que deseas eliminar el presupuesto de ${budget["categoryName"]}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _categoryBudgets.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Presupuesto eliminado'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showCategoryDetails(Map<String, dynamic> budget) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CategoryDetailsSheet(budget: budget),
    );
  }

  Future<void> _refreshBudgets() async {
    setState(() => _isLoading = true);
    await Future.delayed(Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Presupuesto',
        variant: CustomAppBarVariant.standard,
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: _isMonthlyView ? 'calendar_month' : 'calendar_today',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: () {
              setState(() => _isMonthlyView = !_isMonthlyView);
            },
            tooltip: _isMonthlyView ? 'Vista anual' : 'Vista mensual',
          ),
        ],
      ),
      body: _categoryBudgets.isEmpty
          ? EmptyBudgetStateWidget(onCreateBudget: _showNewBudgetDialog)
          : RefreshIndicator(
              onRefresh: _refreshBudgets,
              child: CustomScrollView(
                slivers: [
                  // Header with month navigation
                  SliverToBoxAdapter(
                    child: BudgetHeaderWidget(
                      currentMonth: _months[_currentMonthIndex],
                      onPreviousMonth: _navigateToPreviousMonth,
                      onNextMonth: _navigateToNextMonth,
                      onNewBudget: _showNewBudgetDialog,
                    ),
                  ),
                  // Budget summary card
                  SliverToBoxAdapter(
                    child: BudgetSummaryCardWidget(
                      totalBudget: _totalBudget,
                      spentAmount: _totalSpent,
                      remainingBalance: _remainingBalance,
                      spendingPercentage: _spendingPercentage,
                    ),
                  ),
                  // Budget alerts section
                  if (_budgetAlerts.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(4.w, 3.h, 4.w, 1.h),
                        child: Text(
                          'Alertas',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final alert = _budgetAlerts[index];
                        return BudgetAlertCardWidget(
                          categoryName: alert["categoryName"] as String,
                          message: alert["message"] as String,
                          alertType: alert["alertType"] as String,
                          onTap: () {
                            final budgetIndex = _categoryBudgets.indexWhere(
                              (b) =>
                                  (b)["categoryName"] == alert["categoryName"],
                            );
                            if (budgetIndex != -1) {
                              _showCategoryDetails(
                                _categoryBudgets[budgetIndex],
                              );
                            }
                          },
                        );
                      }, childCount: _budgetAlerts.length),
                    ),
                  ],
                  // Category budgets section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(4.w, 3.h, 4.w, 1.h),
                      child: Text(
                        'Presupuestos por Categoría',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final budget = _categoryBudgets[index];
                      return CategoryBudgetCardWidget(
                        categoryName: budget["categoryName"] as String,
                        categoryIcon: budget["categoryIcon"] as String,
                        categoryColor: Color(budget["categoryColor"] as int),
                        allocatedAmount: budget["allocatedAmount"] as double,
                        spentAmount: budget["spentAmount"] as double,
                        onTap: () => _showCategoryDetails(budget),
                        onEdit: () => _showEditBudgetDialog(index),
                        onDelete: () => _showDeleteConfirmation(index),
                      );
                    }, childCount: _categoryBudgets.length),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 10.h)),
                ],
              ),
            ),
      bottomNavigationBar: CustomBottomBar(
        selectedItem: CustomBottomBarItem.budget,
        onItemSelected: (item) {},
      ),
      floatingActionButton: _categoryBudgets.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _showNewBudgetDialog,
              icon: CustomIconWidget(
                iconName: 'add',
                color: theme.colorScheme.onPrimary,
                size: 24,
              ),
              label: Text('Nuevo'),
            ),
    );
  }
}

// New Budget Dialog
class _NewBudgetDialog extends StatefulWidget {
  final Function(String categoryName, double amount) onSave;

  const _NewBudgetDialog({required this.onSave});

  @override
  State<_NewBudgetDialog> createState() => _NewBudgetDialogState();
}

class _NewBudgetDialogState extends State<_NewBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _categoryController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text('Nuevo Presupuesto'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: 'Categoría',
                prefixIcon: CustomIconWidget(
                  iconName: 'category',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa una categoría';
                }
                return null;
              },
            ),
            SizedBox(height: 2.h),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Monto',
                prefixIcon: CustomIconWidget(
                  iconName: 'attach_money',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa un monto';
                }
                if (double.tryParse(value) == null) {
                  return 'Ingresa un monto válido';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave(
                _categoryController.text,
                double.parse(_amountController.text),
              );
            }
          },
          child: Text('Guardar'),
        ),
      ],
    );
  }
}

// Edit Budget Dialog
class _EditBudgetDialog extends StatefulWidget {
  final String categoryName;
  final double currentAmount;
  final Function(double amount) onSave;

  const _EditBudgetDialog({
    required this.categoryName,
    required this.currentAmount,
    required this.onSave,
  });

  @override
  State<_EditBudgetDialog> createState() => _EditBudgetDialogState();
}

class _EditBudgetDialogState extends State<_EditBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.currentAmount.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text('Editar Presupuesto'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.categoryName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 2.h),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Nuevo Monto',
                prefixIcon: CustomIconWidget(
                  iconName: 'attach_money',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa un monto';
                }
                if (double.tryParse(value) == null) {
                  return 'Ingresa un monto válido';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave(double.parse(_amountController.text));
            }
          },
          child: Text('Guardar'),
        ),
      ],
    );
  }
}

// Category Details Bottom Sheet
class _CategoryDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> budget;

  const _CategoryDetailsSheet({required this.budget});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allocatedAmount = budget["allocatedAmount"] as double;
    final spentAmount = budget["spentAmount"] as double;
    final remainingAmount = allocatedAmount - spentAmount;
    final spendingPercentage = allocatedAmount > 0
        ? (spentAmount / allocatedAmount * 100).clamp(0, 100)
        : 0.0;

    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.symmetric(vertical: 1.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Container(
                  width: 15.w,
                  height: 15.w,
                  decoration: BoxDecoration(
                    color: Color(
                      budget["categoryColor"] as int,
                    ).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: budget["categoryIcon"] as String,
                      color: Color(budget["categoryColor"] as int),
                      size: 32,
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        budget["categoryName"] as String,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '${spendingPercentage.toStringAsFixed(0)}% del presupuesto',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          // Budget details
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                _buildDetailRow(
                  context,
                  'Presupuesto Asignado',
                  '\$${allocatedAmount.toStringAsFixed(2)}',
                  theme.colorScheme.primary,
                ),
                SizedBox(height: 2.h),
                _buildDetailRow(
                  context,
                  'Gastado',
                  '\$${spentAmount.toStringAsFixed(2)}',
                  theme.colorScheme.error,
                ),
                SizedBox(height: 2.h),
                _buildDetailRow(
                  context,
                  'Restante',
                  '\$${remainingAmount.toStringAsFixed(2)}',
                  remainingAmount >= 0
                      ? AppTheme.successGreen
                      : theme.colorScheme.error,
                ),
              ],
            ),
          ),
          Divider(),
          // Transactions list placeholder
          Expanded(
            child: Center(
              child: Text(
                'Historial de transacciones próximamente',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
