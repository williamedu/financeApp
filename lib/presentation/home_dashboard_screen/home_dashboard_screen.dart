import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/custom_bottom_bar.dart';

import './widgets/category_filter_chips_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/financial_summary_card_widget.dart';
import './widgets/transaction_card_widget.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key}); // <--- Forma moderna y limpia

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  CustomBottomBarItem _selectedBottomBarItem = CustomBottomBarItem.home;

  // CORRECCIÓN: Iniciar en 'Transacciones' para coincidir con los botones
  String _selectedCategory = 'Transacciones';

  late Stream<Map<String, dynamic>> _userDataStream;
  bool _streamInitialized = false;

  @override
  void initState() {
    super.initState();
    final user = _authService.currentUser;
    if (user != null) {
      _userDataStream = _firestoreService.streamUserData(user.uid);
      _streamInitialized = true;
    }
  }

  double calcularTotal(Map<String, Map<String, dynamic>> dataMap, String tipo) {
    double total = 0;
    dataMap.forEach((key, value) {
      final valor = value[tipo];
      if (valor is num) total += valor.toDouble();
    });
    return total;
  }

  void _handleCategorySelected(String category) {
    setState(() => _selectedCategory = category);
    HapticFeedback.selectionClick();
  }

  void _handleAddTransaction() {
    Navigator.pushNamed(context, '/add-transaction-screen');
  }

  // Lógica de Filtrado
  List<Map<String, dynamic>> _filtrarTransacciones(
    List<Map<String, dynamic>> todas,
    String filtro,
  ) {
    if (filtro == 'Transacciones') {
      return todas;
    }

    return todas.where((t) {
      final type = (t['type'] as String? ?? '').toLowerCase();
      final isFixed = t['isFixed'] == true;

      if (filtro == 'Ingresos') {
        return type == 'income';
      } else if (filtro == 'Gastos Fijos') {
        return type == 'expense' && (isFixed == true);
      } else if (filtro == 'Variables') {
        return type == 'expense' && (isFixed != true);
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (!_streamInitialized || user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: _userDataStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final data = snapshot.data ?? {};

          final ingresos =
              data['ingresos'] as Map<String, Map<String, dynamic>>? ?? {};
          final gastosFijos =
              data['gastosFijos'] as Map<String, Map<String, dynamic>>? ?? {};
          final gastosVariables =
              data['gastosVariables'] as Map<String, Map<String, dynamic>>? ??
              {};

          // --- PROCESAMIENTO BLINDADO DE TRANSACCIONES ---
          final List<dynamic> rawTransacciones =
              data['transacciones'] as List<dynamic>? ?? [];

          final List<Map<String, dynamic>>
          todasLasTransacciones = rawTransacciones.map((item) {
            final map = item as Map<String, dynamic>;

            // Aquí evitamos el "Red Box" usando .toString() y valores por defecto
            return {
              'id': map['id'],
              'amount': (map['amount'] ?? map['monto'] ?? 0).toDouble(),
              'description':
                  (map['description'] ?? map['concepto'] ?? 'Sin descripción')
                      .toString(),
              'category': (map['category'] ?? map['categoria'] ?? 'General')
                  .toString(),
              'date': map['date'] ?? map['fecha'] ?? DateTime.now(),
              'type': (map['type'] ?? 'expense').toString(),
              'icon': map['icon'],
              'color': map['color'],
              'isFixed': map['isFixed'] == true,
            };
          }).toList();

          // Ordenar por fecha seguro
          todasLasTransacciones.sort((a, b) {
            dynamic dateA = a['date'];
            dynamic dateB = b['date'];

            DateTime dtA = DateTime.now();
            DateTime dtB = DateTime.now();

            // Manejo de Timestamp (Firebase) vs String (ISO8601) vs DateTime
            if (dateA is Timestamp)
              dtA = dateA.toDate();
            else if (dateA is String)
              dtA = DateTime.tryParse(dateA) ?? DateTime.now();
            else if (dateA is DateTime)
              dtA = dateA;

            if (dateB is Timestamp)
              dtB = dateB.toDate();
            else if (dateB is String)
              dtB = DateTime.tryParse(dateB) ?? DateTime.now();
            else if (dateB is DateTime)
              dtB = dateB;

            return dtB.compareTo(dtA);
          });

          // Cálculos
          double totalIngresos = calcularTotal(ingresos, 'actual');
          double totalFijos = calcularTotal(gastosFijos, 'actual');
          double totalVariables = calcularTotal(gastosVariables, 'actual');

          double gastado = totalFijos + totalVariables;
          double disponible = totalIngresos - gastado;

          final transaccionesFiltradas = _filtrarTransacciones(
            todasLasTransacciones,
            _selectedCategory,
          );

          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 500));
              setState(() {});
            },
            color: const Color(0xFF6366F1),
            backgroundColor: const Color(0xFF1E293B),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 8.h,
                  floating: false,
                  pinned: true,
                  backgroundColor: const Color(0xFF0F172A),
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: EdgeInsets.only(left: 4.w, bottom: 2.h),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hola, ${user.displayName?.split(' ')[0] ?? 'Usuario'}!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: EdgeInsets.only(right: 4.w),
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/user-profile-screen',
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(
                            0xFF6366F1,
                          ).withOpacity(0.2),
                          child: const Icon(
                            Icons.person,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      FinancialSummaryCardWidget(
                        totalIngresos: totalIngresos,
                        gastadoHastaAhora: gastado,
                        disponibleGastar: disponible,
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 2.h,
                        ),
                        child: OutlinedButton.icon(
                          onPressed: _handleAddTransaction,
                          icon: const Icon(Icons.add, color: Color(0xFFEF4444)),
                          label: const Text('Nueva Transacción'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFEF4444),
                            side: const BorderSide(
                              color: Color(0xFFEF4444),
                              width: 1.5,
                            ),
                            padding: EdgeInsets.symmetric(vertical: 1.8.h),
                            minimumSize: Size(double.infinity, 6.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      CategoryFilterChipsWidget(
                        onCategorySelected: _handleCategorySelected,
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.h,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedCategory,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${transaccionesFiltradas.length} items',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                transaccionesFiltradas.isEmpty
                    ? SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyStateWidget(
                          onAddTransaction: _handleAddTransaction,
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final transaction = transaccionesFiltradas[index];
                          return TransactionCardWidget(
                            transaction: transaction,
                            onEdit: () => Navigator.pushNamed(
                              context,
                              '/add-transaction-screen',
                              arguments: transaction,
                            ),
                            onDelete: () {},
                            onDuplicate: () {},
                            onTap: () {},
                          );
                        }, childCount: transaccionesFiltradas.length),
                      ),
                SliverToBoxAdapter(child: SizedBox(height: 10.h)),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomBar(
        selectedItem: _selectedBottomBarItem,
        onItemSelected: (item) {
          setState(() => _selectedBottomBarItem = item);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleAddTransaction,
        backgroundColor: const Color(0xFF6366F1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
