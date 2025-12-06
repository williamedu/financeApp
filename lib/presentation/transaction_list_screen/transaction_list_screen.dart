import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import './widgets/date_section_header_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/transaction_card_widget.dart';
import './widgets/transaction_filter_chips_widget.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  List<String> _activeFilters = [];
  Map<String, dynamic> _currentFilters = {};
  String _searchQuery = '';
  bool _isSearching = false;

  // Paginación local
  int _daysToShow = 7;
  final int _daysIncrement = 7;

  // Mapa para agrupar transacciones por fecha
  Map<DateTime, List<Map<String, dynamic>>> _groupTransactionsByDate(
    List<Map<String, dynamic>> transactions,
  ) {
    Map<DateTime, List<Map<String, dynamic>>> grouped = {};
    for (var transaction in transactions) {
      // La fecha ya viene convertida como DateTime desde el StreamBuilder
      final timestamp = transaction['date'] as DateTime;

      final dateOnly = DateTime(timestamp.year, timestamp.month, timestamp.day);
      if (!grouped.containsKey(dateOnly)) grouped[dateOnly] = [];
      grouped[dateOnly]!.add(transaction);
    }
    return grouped;
  }

  void _onSearchChanged(String query) => setState(() => _searchQuery = query);

  // Mostrar el filtro
  void _showFilterBottomSheet(
    List<Map<String, dynamic>> availableCategories,
    List<Map<String, dynamic>> allTransactions,
  ) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => FilterBottomSheetWidget(
          currentFilters: _currentFilters,
          availableCategories: availableCategories,
          allTransactions: allTransactions,
          onApplyFilters: (filters) {
            setState(() {
              _currentFilters = filters;
              _updateActiveFilters();
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
    if (_currentFilters['type'] != null && _currentFilters['type'] != 'Todos') {
      filters.add(_currentFilters['type']);
    }
    if (_currentFilters['datePreset'] != null) {
      filters.add(_currentFilters['datePreset']);
    }
    setState(() => _activeFilters = filters);
  }

  void _removeFilter(String filter) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_currentFilters.containsKey('categories')) {
        final categories = _currentFilters['categories'] as List<String>;
        categories.remove(filter);
        if (categories.isEmpty) _currentFilters.remove('categories');
      }
      if (_currentFilters['type'] == filter) _currentFilters.remove('type');
      if (_currentFilters['datePreset'] == filter)
        _currentFilters.remove('datePreset');

      _updateActiveFilters();
    });
  }

  void _clearAllFilters() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentFilters.clear();
      _activeFilters.clear();
      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _loadMoreDays() {
    HapticFeedback.selectionClick();
    setState(() => _daysToShow += _daysIncrement);
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    if (user == null)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return StreamBuilder<Map<String, dynamic>>(
      stream: _firestoreService.streamUserData(user.uid),
      builder: (context, snapshot) {
        // 1. Estados de carga
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0F172A),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            ),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: const Color(0xFF0F172A),
            body: Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        final data = snapshot.data ?? {};
        final currencySymbol = data['currency'] as String? ?? '\$';

        // 2. Extraer Categorías para el filtro
        List<Map<String, dynamic>> allCategoriesList = [];
        void addCats(Map<String, dynamic>? map) {
          if (map != null) {
            map.forEach((key, value) {
              if (!allCategoriesList.any((c) => c['name'] == key)) {
                allCategoriesList.add({
                  'name': key,
                  'icon': value['icon'],
                  'color': value['color'],
                });
              }
            });
          }
        }

        addCats(data['ingresos']);
        addCats(data['gastosFijos']);
        addCats(data['gastosVariables']);

        // 3. Procesar Transacciones (Limpieza y Conversión)
        final List<dynamic> rawTransacciones =
            data['transacciones'] as List<dynamic>? ?? [];

        // Lista limpia con tipos de datos seguros
        final List<Map<String, dynamic>> allTransactionsClean = rawTransacciones
            .map((item) {
              final map = item as Map<String, dynamic>;

              // Conversión de Fecha Segura
              dynamic rawDate = map['date'] ?? map['fecha'];
              DateTime parsedDate;
              if (rawDate is Timestamp)
                parsedDate = rawDate.toDate();
              else if (rawDate is String)
                parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
              else if (rawDate is DateTime)
                parsedDate = rawDate;
              else
                parsedDate = DateTime.now();

              return {
                'id': map['id'],
                'amount': (map['amount'] ?? map['monto'] ?? 0).toDouble(),
                'description':
                    (map['description'] ?? map['concepto'] ?? 'Sin descripción')
                        .toString(),
                'category': (map['category'] ?? map['categoria'] ?? 'General')
                    .toString(),
                'date': parsedDate,
                'type': (map['type'] ?? 'expense').toString(),
                'icon': map['icon'],
                'color': map['color'],
              };
            })
            .toList();

        // 4. Filtrado
        List<Map<String, dynamic>> filteredList = allTransactionsClean.where((
          t,
        ) {
          // Búsqueda
          if (_searchQuery.isNotEmpty) {
            final desc = t['description'].toString().toLowerCase();
            final cat = t['category'].toString().toLowerCase();
            final q = _searchQuery.toLowerCase();
            if (!desc.contains(q) && !cat.contains(q)) return false;
          }

          // Filtros
          if (_currentFilters.isNotEmpty) {
            // Tipo
            if (_currentFilters['type'] != null &&
                _currentFilters['type'] != 'Todos') {
              final type = t['type'] == 'income' ? 'Ingreso' : 'Gasto';
              if (type != _currentFilters['type']) return false;
            }
            // Categorías
            if (_currentFilters['categories'] != null) {
              final cats = _currentFilters['categories'] as List<String>;
              if (cats.isNotEmpty && !cats.contains(t['category']))
                return false;
            }
            // Monto
            final amount = t['amount'] as double;
            if (_currentFilters['minAmount'] != null &&
                amount < _currentFilters['minAmount'])
              return false;
            if (_currentFilters['maxAmount'] != null &&
                amount > _currentFilters['maxAmount'])
              return false;

            // Fechas
            if (_currentFilters['datePreset'] != null) {
              final date = t['date'] as DateTime;
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final itemDate = DateTime(date.year, date.month, date.day);

              switch (_currentFilters['datePreset']) {
                case 'Hoy':
                  if (itemDate != today) return false;
                  break;
                case 'Ayer':
                  if (itemDate != today.subtract(const Duration(days: 1)))
                    return false;
                  break;
                case 'Últimos 7 días':
                  if (date.isBefore(now.subtract(const Duration(days: 7))))
                    return false;
                  break;
                case 'Últimos 15 días':
                  if (date.isBefore(now.subtract(const Duration(days: 15))))
                    return false;
                  break;
                case 'Últimos 30 días':
                  if (date.isBefore(now.subtract(const Duration(days: 30))))
                    return false;
                  break;
                case 'Este Mes':
                  if (date.month != now.month || date.year != now.year)
                    return false;
                  break;
                case 'Mes Pasado':
                  final lastMonth = DateTime(now.year, now.month - 1, 1);
                  if (date.month != lastMonth.month ||
                      date.year != lastMonth.year)
                    return false;
                  break;
                case 'Este Año':
                  if (date.year != now.year) return false;
                  break;
              }
            }
          }
          return true;
        }).toList();

        // 5. Ordenamiento
        if (_currentFilters['sort'] != null) {
          if (_currentFilters['sort'] == 'Más antiguo') {
            filteredList.sort((a, b) => a['date'].compareTo(b['date']));
          } else if (_currentFilters['sort'] == 'Mayor monto') {
            filteredList.sort((a, b) => b['amount'].compareTo(a['amount']));
          } else if (_currentFilters['sort'] == 'Menor monto') {
            filteredList.sort((a, b) => a['amount'].compareTo(b['amount']));
          } else {
            filteredList.sort((a, b) => b['date'].compareTo(a['date']));
          }
        } else {
          filteredList.sort((a, b) => b['date'].compareTo(a['date']));
        }

        // 6. Agrupación y Paginación
        final groupedTransactions = _groupTransactionsByDate(filteredList);
        final allSortedDates = groupedTransactions.keys.toList()
          ..sort((a, b) => b.compareTo(a));

        final visibleDates = allSortedDates.take(_daysToShow).toList();
        final hasMoreDates = allSortedDates.length > _daysToShow;

        return Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0F172A),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pushReplacementNamed(
                context,
                '/home-dashboard-screen',
              ),
            ),
            title: _isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Buscar...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                    ),
                    onChanged: _onSearchChanged,
                  )
                : const Text(
                    'Transacciones',
                    style: TextStyle(color: Colors.white),
                  ),
            actions: [
              if (_isSearching)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => setState(() {
                    _isSearching = false;
                    _searchQuery = '';
                    _searchController.clear();
                  }),
                )
              else
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () => setState(() => _isSearching = true),
                ),
              IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color: _activeFilters.isNotEmpty
                      ? const Color(0xFFF59E0B)
                      : Colors.white,
                ),
                // PASAMOS LAS DOS LISTAS NECESARIAS
                onPressed: () => _showFilterBottomSheet(
                  allCategoriesList,
                  allTransactionsClean,
                ),
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
                child: filteredList.isEmpty
                    ? EmptyStateWidget(
                        type: _searchQuery.isNotEmpty
                            ? 'no_search_results'
                            : 'no_transactions',
                        onAction: _activeFilters.isNotEmpty
                            ? _clearAllFilters
                            : null,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: visibleDates.length + (hasMoreDates ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == visibleDates.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 24,
                                horizontal: 32,
                              ),
                              child: OutlinedButton(
                                onPressed: _loadMoreDays,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF6366F1),
                                  side: const BorderSide(
                                    color: Color(0xFF6366F1),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text(
                                  'Cargar más días',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          }

                          final date = visibleDates[index];
                          final transactions = groupedTransactions[date]!;
                          final dailyTotal = transactions.fold<double>(0, (
                            sum,
                            t,
                          ) {
                            if (t['type'] == 'expense')
                              return sum + (t['amount'] as double);
                            return sum;
                          });

                          return Column(
                            children: [
                              DateSectionHeaderWidget(
                                date: date,
                                totalAmount: dailyTotal,
                                isIncome: false,
                                currencySymbol:
                                    currencySymbol, // Pasamos moneda
                              ),
                              ...transactions.map(
                                (transaction) => TransactionCardWidget(
                                  transaction: transaction,
                                  currencySymbol:
                                      currencySymbol, // Pasamos moneda
                                  onTap: () {},
                                  onEdit: () => Navigator.pushNamed(
                                    context,
                                    '/add-transaction-screen',
                                    arguments: transaction,
                                  ),
                                  onDelete: () {},
                                  onDuplicate: () {},
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/add-transaction-screen'),
            backgroundColor: const Color(0xFF6366F1),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          bottomNavigationBar: CustomBottomBar(
            selectedItem: CustomBottomBarItem.transactions,
            onItemSelected: (item) {
              if (item == CustomBottomBarItem.home)
                Navigator.pushReplacementNamed(
                  context,
                  '/home-dashboard-screen',
                );
            },
          ),
        );
      },
    );
  }
}
