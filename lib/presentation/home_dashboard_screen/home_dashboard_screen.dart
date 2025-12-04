import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/category_filter_chips_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/financial_summary_card_widget.dart';
import './widgets/transaction_card_widget.dart';

/// Home Dashboard Screen - Primary financial overview screen
class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({Key? key}) : super(key: key);

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  CustomBottomBarItem _selectedBottomBarItem = CustomBottomBarItem.home;
  String _selectedCategory = 'Todos';
  bool _isLoading = false;

  // Mock user data
  final String _userName = 'María González';
  final double _availableAmount = 2450.75;

  // Mock transactions data
  final List<Map<String, dynamic>> _allTransactions = [
    {
      'id': 1,
      'type': 'income',
      'amount': 3500.00,
      'category': 'Salario',
      'description': 'Pago mensual',
      'date': DateTime(2025, 12, 1),
      'icon': 'account_balance_wallet',
    },
    {
      'id': 2,
      'type': 'expense',
      'amount': 850.00,
      'category': 'Alquiler',
      'description': 'Renta departamento',
      'date': DateTime(2025, 12, 2),
      'icon': 'home',
    },
    {
      'id': 3,
      'type': 'expense',
      'amount': 120.50,
      'category': 'Supermercado',
      'description': 'Compras semanales',
      'date': DateTime(2025, 12, 3),
      'icon': 'shopping_cart',
    },
    {
      'id': 4,
      'type': 'income',
      'amount': 500.00,
      'category': 'Freelance',
      'description': 'Proyecto diseño web',
      'date': DateTime(2025, 12, 3),
      'icon': 'work',
    },
    {
      'id': 5,
      'type': 'expense',
      'amount': 45.25,
      'category': 'Transporte',
      'description': 'Gasolina',
      'date': DateTime(2025, 12, 4),
      'icon': 'local_gas_station',
    },
    {
      'id': 6,
      'type': 'expense',
      'amount': 80.00,
      'category': 'Entretenimiento',
      'description': 'Cine y cena',
      'date': DateTime(2025, 12, 4),
      'icon': 'movie',
    },
  ];

  List<Map<String, dynamic>> get _filteredTransactions {
    if (_selectedCategory == 'Todos') {
      return _allTransactions;
    } else if (_selectedCategory == 'Ingresos') {
      return _allTransactions
          .where((t) => (t['type'] as String) == 'income')
          .toList();
    } else if (_selectedCategory == 'Gastos Fijos') {
      return _allTransactions
          .where((t) =>
              (t['type'] as String) == 'expense' &&
              ((t['category'] as String) == 'Alquiler' ||
                  (t['category'] as String) == 'Servicios'))
          .toList();
    } else {
      return _allTransactions
          .where((t) =>
              (t['type'] as String) == 'expense' &&
              (t['category'] as String) != 'Alquiler' &&
              (t['category'] as String) != 'Servicios')
          .toList();
    }
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);

    // Simulate network request
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);
  }

  void _handleCategorySelected(String category) {
    setState(() => _selectedCategory = category);
  }

  void _handleAddTransaction() {
    Navigator.pushNamed(context, '/add-transaction-screen');
  }

  void _handleEditTransaction(Map<String, dynamic> transaction) {
    // Navigate to edit screen with transaction data
    Navigator.pushNamed(
      context,
      '/add-transaction-screen',
      arguments: transaction,
    );
  }

  void _handleDeleteTransaction(Map<String, dynamic> transaction) {
    HapticFeedback.mediumImpact();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar transacción'),
        content: const Text(
            '¿Estás seguro de que deseas eliminar esta transacción?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _allTransactions
                    .removeWhere((t) => t['id'] == transaction['id']);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transacción eliminada')),
              );
            },
            child: Text(
              'Eliminar',
              style: TextStyle(color: AppTheme.expenseRed),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDuplicateTransaction(Map<String, dynamic> transaction) {
    HapticFeedback.lightImpact();

    final newTransaction = Map<String, dynamic>.from(transaction);
    newTransaction['id'] = _allTransactions.length + 1;
    newTransaction['date'] = DateTime.now();

    setState(() {
      _allTransactions.insert(0, newTransaction);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transacción duplicada')),
    );
  }

  void _handleTransactionTap(Map<String, dynamic> transaction) {
    // Navigate to transaction details
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTransactionDetailsSheet(transaction),
    );
  }

  Widget _buildTransactionDetailsSheet(Map<String, dynamic> transaction) {
    final theme = Theme.of(context);
    final isIncome = (transaction['type'] as String) == 'income';

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.all(6.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 12.w,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Detalles de transacción',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          _buildDetailRow(
            'Tipo',
            isIncome ? 'Ingreso' : 'Gasto',
            theme,
            isIncome ? AppTheme.successGreen : AppTheme.expenseRed,
          ),
          _buildDetailRow(
            'Monto',
            '\$${(transaction['amount'] as double).toStringAsFixed(2).replaceAll('.', ',')}',
            theme,
            null,
          ),
          _buildDetailRow(
            'Categoría',
            transaction['category'] as String,
            theme,
            null,
          ),
          _buildDetailRow(
            'Descripción',
            transaction['description'] as String,
            theme,
            null,
          ),
          _buildDetailRow(
            'Fecha',
            '${(transaction['date'] as DateTime).day}/${(transaction['date'] as DateTime).month}/${(transaction['date'] as DateTime).year}',
            theme,
            null,
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleEditTransaction(transaction);
                  },
                  icon: CustomIconWidget(
                    iconName: 'edit',
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  label: const Text('Editar'),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleDeleteTransaction(transaction);
                  },
                  icon: CustomIconWidget(
                    iconName: 'delete',
                    color: theme.colorScheme.onPrimary,
                    size: 20,
                  ),
                  label: const Text('Eliminar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.expenseRed,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      String label, String value, ThemeData theme, Color? valueColor) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: valueColor ?? theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: theme.colorScheme.primary,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 8.h,
              floating: false,
              pinned: true,
              backgroundColor: theme.scaffoldBackgroundColor,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hola, $_userName!',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                titlePadding: EdgeInsets.only(left: 4.w, bottom: 2.h),
              ),
              actions: [
                Padding(
                  padding: EdgeInsets.only(right: 4.w),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        theme.colorScheme.primary.withValues(alpha: 0.2),
                    child: CustomIconWidget(
                      iconName: 'person',
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  FinancialSummaryCardWidget(
                    userName: _userName,
                    availableAmount: _availableAmount,
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    child: OutlinedButton.icon(
                      onPressed: _handleAddTransaction,
                      icon: CustomIconWidget(
                        iconName: 'add',
                        color: AppTheme.expenseRed,
                        size: 24,
                      ),
                      label: const Text('Nueva Transacción'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.expenseRed,
                        side: BorderSide(color: AppTheme.expenseRed, width: 2),
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        minimumSize: Size(double.infinity, 6.h),
                      ),
                    ),
                  ),
                  CategoryFilterChipsWidget(
                    onCategorySelected: _handleCategorySelected,
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Transacciones recientes',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(
                              context, '/transaction-list-screen'),
                          child: const Text('Ver todas'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _filteredTransactions.isEmpty
                ? SliverFillRemaining(
                    child: EmptyStateWidget(
                      onAddTransaction: _handleAddTransaction,
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final transaction = _filteredTransactions[index];
                        return TransactionCardWidget(
                          transaction: transaction,
                          onEdit: () => _handleEditTransaction(transaction),
                          onDelete: () => _handleDeleteTransaction(transaction),
                          onDuplicate: () =>
                              _handleDuplicateTransaction(transaction),
                          onTap: () => _handleTransactionTap(transaction),
                        );
                      },
                      childCount: _filteredTransactions.length,
                    ),
                  ),
            SliverToBoxAdapter(
              child: SizedBox(height: 10.h),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        selectedItem: _selectedBottomBarItem,
        onItemSelected: (item) {
          setState(() => _selectedBottomBarItem = item);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleAddTransaction,
        child: CustomIconWidget(
          iconName: 'add',
          color: theme.colorScheme.onPrimary,
          size: 28,
        ),
      ),
    );
  }
}
