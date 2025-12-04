import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/date_section_header_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/transaction_card_widget.dart';
import './widgets/transaction_filter_chips_widget.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({Key? key}) : super(key: key);

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<String> _activeFilters = [];
  Map<String, dynamic> _currentFilters = {};
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isSearching = false;

  // Mock transaction data
  final List<Map<String, dynamic>> _allTransactions = [
    {
      "id": "1",
      "type": "Gasto",
      "category": "Comida",
      "description": "Almuerzo en restaurante",
      "amount": 45.50,
      "timestamp": DateTime.now().subtract(Duration(hours: 2)),
      "hasReceipt": true,
    },
    {
      "id": "2",
      "type": "Ingreso",
      "category": "Salario",
      "description": "Pago mensual",
      "amount": 3500.00,
      "timestamp": DateTime.now().subtract(Duration(hours: 5)),
      "hasReceipt": false,
    },
    {
      "id": "3",
      "type": "Gasto",
      "category": "Transporte",
      "description": "Gasolina",
      "amount": 60.00,
      "timestamp": DateTime.now().subtract(Duration(days: 1, hours: 3)),
      "hasReceipt": true,
    },
    {
      "id": "4",
      "type": "Gasto",
      "category": "Entretenimiento",
      "description": "Cine con amigos",
      "amount": 25.00,
      "timestamp": DateTime.now().subtract(Duration(days: 1, hours: 8)),
      "hasReceipt": false,
    },
    {
      "id": "5",
      "type": "Gasto",
      "category": "Salud",
      "description": "Farmacia",
      "amount": 35.75,
      "timestamp": DateTime.now().subtract(Duration(days: 2, hours: 4)),
      "hasReceipt": true,
    },
    {
      "id": "6",
      "type": "Gasto",
      "category": "Compras",
      "description": "Ropa nueva",
      "amount": 120.00,
      "timestamp": DateTime.now().subtract(Duration(days: 3, hours: 2)),
      "hasReceipt": true,
    },
    {
      "id": "7",
      "type": "Ingreso",
      "category": "Ingreso",
      "description": "Freelance proyecto",
      "amount": 500.00,
      "timestamp": DateTime.now().subtract(Duration(days: 4, hours: 6)),
      "hasReceipt": false,
    },
    {
      "id": "8",
      "type": "Gasto",
      "category": "Comida",
      "description": "Supermercado",
      "amount": 85.30,
      "timestamp": DateTime.now().subtract(Duration(days: 5, hours: 1)),
      "hasReceipt": true,
    },
  ];

  List<Map<String, dynamic>> _filteredTransactions = [];

  @override
  void initState() {
    super.initState();
    _filteredTransactions = List.from(_allTransactions);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreTransactions();
    }
  }

  Future<void> _loadMoreTransactions() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refreshTransactions() async {
    HapticFeedback.lightImpact();

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _filteredTransactions = List.from(_allTransactions);
      _isLoading = false;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filterTransactions();
    });
  }

  void _filterTransactions() {
    List<Map<String, dynamic>> filtered = List.from(_allTransactions);

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((transaction) {
        final description =
            (transaction['description'] as String).toLowerCase();
        final category = (transaction['category'] as String).toLowerCase();
        final query = _searchQuery.toLowerCase();
        return description.contains(query) || category.contains(query);
      }).toList();
    }

    if (_currentFilters.isNotEmpty) {
      if (_currentFilters.containsKey('categories')) {
        final categories = _currentFilters['categories'] as List<String>;
        if (categories.isNotEmpty) {
          filtered = filtered.where((transaction) {
            return categories.contains(transaction['category']);
          }).toList();
        }
      }

      if (_currentFilters.containsKey('minAmount') &&
          _currentFilters.containsKey('maxAmount')) {
        final minAmount = _currentFilters['minAmount'] as double;
        final maxAmount = _currentFilters['maxAmount'] as double;
        filtered = filtered.where((transaction) {
          final amount = transaction['amount'] as double;
          return amount >= minAmount && amount <= maxAmount;
        }).toList();
      }

      if (_currentFilters.containsKey('startDate') &&
          _currentFilters.containsKey('endDate')) {
        final startDate = _currentFilters['startDate'] as DateTime;
        final endDate = _currentFilters['endDate'] as DateTime;
        filtered = filtered.where((transaction) {
          final timestamp = transaction['timestamp'] as DateTime;
          return timestamp.isAfter(startDate) &&
              timestamp.isBefore(endDate.add(Duration(days: 1)));
        }).toList();
      }
    }

    setState(() {
      _filteredTransactions = filtered;
    });
  }

  void _showFilterBottomSheet() {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => FilterBottomSheetWidget(
          currentFilters: _currentFilters,
          onApplyFilters: (filters) {
            setState(() {
              _currentFilters = filters;
              _updateActiveFilters();
              _filterTransactions();
            });
          },
        ),
      ),
    );
  }

  void _updateActiveFilters() {
    List<String> filters = [];

    if (_currentFilters.containsKey('categories')) {
      final categories = _currentFilters['categories'] as List<String>;
      filters.addAll(categories);
    }

    if (_currentFilters.containsKey('minAmount') &&
        _currentFilters.containsKey('maxAmount')) {
      final minAmount = _currentFilters['minAmount'] as double;
      final maxAmount = _currentFilters['maxAmount'] as double;
      if (minAmount > 0 || maxAmount < 10000) {
        filters.add(
            'Monto: \$${minAmount.toStringAsFixed(0)} - \$${maxAmount.toStringAsFixed(0)}');
      }
    }

    if (_currentFilters.containsKey('startDate') &&
        _currentFilters.containsKey('endDate')) {
      final startDate = _currentFilters['startDate'] as DateTime;
      final endDate = _currentFilters['endDate'] as DateTime;
      filters.add(
          '${startDate.day}/${startDate.month} - ${endDate.day}/${endDate.month}');
    }

    setState(() {
      _activeFilters = filters;
    });
  }

  void _removeFilter(String filter) {
    HapticFeedback.lightImpact();

    setState(() {
      if (_currentFilters.containsKey('categories')) {
        final categories = _currentFilters['categories'] as List<String>;
        categories.remove(filter);
        if (categories.isEmpty) {
          _currentFilters.remove('categories');
        }
      }

      if (filter.startsWith('Monto:')) {
        _currentFilters.remove('minAmount');
        _currentFilters.remove('maxAmount');
      }

      if (filter.contains('/')) {
        _currentFilters.remove('startDate');
        _currentFilters.remove('endDate');
      }

      _updateActiveFilters();
      _filterTransactions();
    });
  }

  void _clearAllFilters() {
    HapticFeedback.lightImpact();

    setState(() {
      _currentFilters.clear();
      _activeFilters.clear();
      _searchQuery = '';
      _searchController.clear();
      _filterTransactions();
    });
  }

  Map<DateTime, List<Map<String, dynamic>>> _groupTransactionsByDate() {
    Map<DateTime, List<Map<String, dynamic>>> grouped = {};

    for (var transaction in _filteredTransactions) {
      final timestamp = transaction['timestamp'] as DateTime;
      final dateOnly = DateTime(timestamp.year, timestamp.month, timestamp.day);

      if (!grouped.containsKey(dateOnly)) {
        grouped[dateOnly] = [];
      }
      grouped[dateOnly]!.add(transaction);
    }

    return grouped;
  }

  void _showDeleteConfirmation(Map<String, dynamic> transaction) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          'Eliminar Transacción',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar esta transacción?',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTransaction(transaction);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFEF4444),
            ),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _deleteTransaction(Map<String, dynamic> transaction) {
    HapticFeedback.mediumImpact();

    setState(() {
      _allTransactions.removeWhere((t) => t['id'] == transaction['id']);
      _filterTransactions();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transacción eliminada'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () {
            setState(() {
              _allTransactions.add(transaction);
              _filterTransactions();
            });
          },
        ),
      ),
    );
  }

  void _duplicateTransaction(Map<String, dynamic> transaction) {
    HapticFeedback.lightImpact();

    final newTransaction = Map<String, dynamic>.from(transaction);
    newTransaction['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    newTransaction['timestamp'] = DateTime.now();

    setState(() {
      _allTransactions.insert(0, newTransaction);
      _filterTransactions();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Transacción duplicada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groupedTransactions = _groupTransactionsByDate();
    final sortedDates = groupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Buscar transacciones...',
                  hintStyle: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: _onSearchChanged,
              )
            : Text('Transacciones'),
        actions: [
          if (_isSearching)
            IconButton(
              icon: CustomIconWidget(
                iconName: 'close',
                color: theme.colorScheme.onSurface,
                size: 24,
              ),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                  _filterTransactions();
                });
              },
            )
          else
            IconButton(
              icon: CustomIconWidget(
                iconName: 'search',
                color: theme.colorScheme.onSurface,
                size: 24,
              ),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          IconButton(
            icon: CustomIconWidget(
              iconName: 'filter_list',
              color: _activeFilters.isNotEmpty
                  ? Color(0xFFF59E0B)
                  : theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_activeFilters.isNotEmpty)
            TransactionFilterChipsWidget(
              activeFilters: _activeFilters,
              onRemoveFilter: _removeFilter,
            ),
          Expanded(
            child: _filteredTransactions.isEmpty
                ? EmptyStateWidget(
                    type: _searchQuery.isNotEmpty
                        ? 'no_search_results'
                        : _activeFilters.isNotEmpty
                            ? 'no_filter_results'
                            : 'no_transactions',
                    onAction: _activeFilters.isNotEmpty
                        ? _clearAllFilters
                        : () => Navigator.pushNamed(
                            context, '/add-transaction-screen'),
                  )
                : RefreshIndicator(
                    onRefresh: _refreshTransactions,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.only(bottom: 80),
                      itemCount: sortedDates.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == sortedDates.length) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final date = sortedDates[index];
                        final transactions = groupedTransactions[date]!;
                        final totalAmount = transactions.fold<double>(
                          0,
                          (sum, t) => sum + (t['amount'] as double),
                        );
                        final isIncome = transactions.any((t) =>
                            (t['type'] as String).toLowerCase() == 'ingreso');

                        return Column(
                          children: [
                            DateSectionHeaderWidget(
                              date: date,
                              totalAmount: totalAmount,
                              isIncome: isIncome,
                            ),
                            ...transactions
                                .map((transaction) => TransactionCardWidget(
                                      transaction: transaction,
                                      onTap: () {
                                        // Navigate to transaction details
                                      },
                                      onEdit: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/add-transaction-screen',
                                          arguments: transaction,
                                        );
                                      },
                                      onDelete: () =>
                                          _showDeleteConfirmation(transaction),
                                      onDuplicate: () =>
                                          _duplicateTransaction(transaction),
                                      onViewReceipt:
                                          (transaction['hasReceipt'] as bool)
                                              ? () {
                                                  // Show receipt viewer
                                                }
                                              : null,
                                    )),
                          ],
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.pushNamed(context, '/add-transaction-screen'),
        child: CustomIconWidget(
          iconName: 'add',
          color: theme.colorScheme.onPrimary,
          size: 24,
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        selectedItem: CustomBottomBarItem.transactions,
        onItemSelected: (item) {},
      ),
    );
  }
}
