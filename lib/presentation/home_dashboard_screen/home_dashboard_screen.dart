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
import './widgets/category_budget_card_widget.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  CustomBottomBarItem _selectedBottomBarItem = CustomBottomBarItem.home;
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

  // Calculadora Genérica
  double calcularTotal(
    Map<String, Map<String, dynamic>> dataMap,
    String campo,
  ) {
    double total = 0;
    dataMap.forEach((key, value) {
      final valor = value[campo];
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

          final data = snapshot.data ?? {};

          // OBTENER LA MONEDA DE FIREBASE
          final currency = data['currency'] as String? ?? '\$';

          // Mapas de Datos
          final ingresos =
              data['ingresos'] as Map<String, Map<String, dynamic>>? ?? {};
          final gastosFijos =
              data['gastosFijos'] as Map<String, Map<String, dynamic>>? ?? {};
          final gastosVariables =
              data['gastosVariables'] as Map<String, Map<String, dynamic>>? ??
              {};

          // Lista de Transacciones
          final List<dynamic> rawTransacciones =
              data['transacciones'] as List<dynamic>? ?? [];
          final List<Map<String, dynamic>> todasLasTransacciones =
              rawTransacciones.map((item) {
                final map = item as Map<String, dynamic>;
                return {
                  'id': map['id'],
                  'amount': (map['amount'] ?? map['monto'] ?? 0).toDouble(),
                  'description':
                      (map['description'] ??
                              map['concepto'] ??
                              'Sin descripción')
                          .toString(),
                  'category': (map['category'] ?? map['categoria'] ?? 'General')
                      .toString(),
                  'date': map['date'] ?? map['fecha'] ?? DateTime.now(),
                  'type': (map['type'] ?? 'expense').toString(),
                  'icon': map['icon'],
                  'color': map['color'],
                };
              }).toList();

          // Ordenar por fecha
          todasLasTransacciones.sort((a, b) {
            dynamic dateA = a['date'];
            dynamic dateB = b['date'];
            DateTime dtA = DateTime.now(), dtB = DateTime.now();

            if (dateA is Timestamp)
              dtA = dateA.toDate();
            else if (dateA is String)
              dtA = DateTime.tryParse(dateA) ?? DateTime.now();

            if (dateB is Timestamp)
              dtB = dateB.toDate();
            else if (dateB is String)
              dtB = DateTime.tryParse(dateB) ?? DateTime.now();

            return dtB.compareTo(dtA);
          });

          // Cálculos Financieros
          double totalIngresos = calcularTotal(ingresos, 'actual');
          double gastadoRealFijos = calcularTotal(gastosFijos, 'actual');
          double gastadoRealVariables = calcularTotal(
            gastosVariables,
            'actual',
          );
          double gastadoTotal = gastadoRealFijos + gastadoRealVariables;
          double disponible = totalIngresos - gastadoTotal;

          // Filtrado
          List<Map<String, dynamic>> transaccionesFiltradas = [];
          if (_selectedCategory == 'Transacciones') {
            transaccionesFiltradas = todasLasTransacciones;
          } else {
            // ... lógica de filtrado específica si la necesitas ...
            // Por simplicidad, los tabs de Fijos/Variables no usan esta lista, usan los mapas
          }

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
                      // TARJETA DE RESUMEN CON MONEDA
                      FinancialSummaryCardWidget(
                        totalIngresos: totalIngresos,
                        gastadoHastaAhora: gastadoTotal,
                        disponibleGastar: disponible,
                        currencySymbol: currency, // <--- Enviamos moneda
                      ),

                      // Botón Nueva Acción
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 2.h,
                        ),
                        child: OutlinedButton.icon(
                          onPressed: _handleAddTransaction,
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: Color(0xFF6366F1),
                          ),
                          label: const Text('Nueva Entrada'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF6366F1),
                            side: const BorderSide(
                              color: Color(0xFF6366F1),
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

                      // Filtros (Tabs)
                      CategoryFilterChipsWidget(
                        onCategorySelected: _handleCategorySelected,
                      ),

                      // Título
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.h,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedCategory == 'Transacciones'
                                  ? 'Historial Reciente'
                                  : 'Mis Presupuestos',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // LISTA: TRANSACCIONES
                if (_selectedCategory == 'Transacciones')
                  todasLasTransacciones.isEmpty
                      ? SliverFillRemaining(
                          hasScrollBody: false,
                          child: EmptyStateWidget(
                            onAddTransaction: _handleAddTransaction,
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final transaction = todasLasTransacciones[index];
                            return TransactionCardWidget(
                              transaction: transaction,
                              currencySymbol: currency, // <--- Enviamos moneda
                              onEdit: () {},
                              onDelete: () {},
                              onDuplicate: () {},
                              onTap: () {},
                            );
                          }, childCount: todasLasTransacciones.length),
                        )
                // LISTA: GASTOS FIJOS
                else if (_selectedCategory == 'Gastos Fijos')
                  gastosFijos.isEmpty
                      ? const SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                "No hay gastos fijos",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final key = gastosFijos.keys.elementAt(index);
                            final item = gastosFijos[key]!;
                            return CategoryBudgetCardWidget(
                              name: item['nombre'] ?? key,
                              budget: (item['presupuestado'] ?? 0).toDouble(),
                              spent: (item['actual'] ?? 0).toDouble(),
                              iconCode: item['icon'],
                              colorValue: item['color'],
                              currencySymbol: currency, // <--- Enviamos moneda
                            );
                          }, childCount: gastosFijos.length),
                        )
                // LISTA: GASTOS VARIABLES
                else if (_selectedCategory == 'Variables')
                  gastosVariables.isEmpty
                      ? const SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                "No hay gastos variables",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final key = gastosVariables.keys.elementAt(index);
                            final item = gastosVariables[key]!;
                            return CategoryBudgetCardWidget(
                              name: item['nombre'] ?? key,
                              budget: (item['presupuestado'] ?? 0).toDouble(),
                              spent: (item['actual'] ?? 0).toDouble(),
                              iconCode: item['icon'],
                              colorValue: item['color'],
                              currencySymbol: currency, // <--- Enviamos moneda
                            );
                          }, childCount: gastosVariables.length),
                        )
                // LISTA: INGRESOS
                else if (_selectedCategory == 'Ingresos')
                  ingresos.isEmpty
                      ? const SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                "No hay ingresos",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final key = ingresos.keys.elementAt(index);
                            final item = ingresos[key]!;
                            return CategoryBudgetCardWidget(
                              name: item['nombre'] ?? key,
                              budget: (item['estimado'] ?? 0).toDouble(),
                              spent: (item['actual'] ?? 0).toDouble(),
                              iconCode: item['icon'],
                              colorValue: item['color'],
                              isIncome: true,
                              currencySymbol: currency, // <--- Enviamos moneda
                            );
                          }, childCount: ingresos.length),
                        ),

                SliverToBoxAdapter(child: SizedBox(height: 10.h)),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomBar(
        selectedItem: _selectedBottomBarItem,
        onItemSelected: (item) => setState(() => _selectedBottomBarItem = item),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleAddTransaction,
        backgroundColor: const Color(0xFF6366F1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
