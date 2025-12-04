import 'package:flutter/material.dart';
import '../widgets/header_widget.dart';
import '../widgets/ingresos_widget.dart';
import '../widgets/gastos_fijos_widget.dart';
import '../widgets/gastos_variables_widget.dart';
import 'package:intl/intl.dart';
import '../widgets/transacciones_widget.dart';
import '../widgets/financial_summary_widget.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Variables para manejar el mes actual
  int mesActual = DateTime.now().month;
  int anioActual = DateTime.now().year;

  // Lista de nombres de meses
  final List<String> nombresMeses = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  // Servicios
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  // Función para cambiar mes
  void cambiarMes(int nuevoMes) {
    setState(() {
      mesActual = nuevoMes;
    });
  }

  // Función para calcular total de ingresos
  double calcularTotalIngresos(
    Map<String, Map<String, dynamic>> ingresos,
    String tipo,
  ) {
    double total = 0;
    ingresos.forEach((key, value) {
      final valor = value[tipo];
      if (valor is double) {
        total += valor;
      } else if (valor is int) {
        total += valor.toDouble();
      }
    });
    return total;
  }

  // Función para calcular total de gastos fijos
  double calcularTotalGastosFijos(
    Map<String, Map<String, dynamic>> gastosFijos,
    String tipo,
  ) {
    double total = 0;
    gastosFijos.forEach((key, value) {
      final valor = value[tipo];
      if (valor is double) {
        total += valor;
      } else if (valor is int) {
        total += valor.toDouble();
      }
    });
    return total;
  }

  // Función para calcular total de gastos variables
  double calcularTotalGastosVariables(
    Map<String, Map<String, dynamic>> gastosVariables,
    String tipo,
  ) {
    double total = 0;
    gastosVariables.forEach((key, value) {
      final valor = value[tipo];
      if (valor is double) {
        total += valor;
      } else if (valor is int) {
        total += valor.toDouble();
      }
    });
    return total;
  }

  // Función para calcular total de ahorros
  double calcularTotalAhorros(
    Map<String, Map<String, dynamic>> ahorros,
    String tipo,
  ) {
    double total = 0;
    ahorros.forEach((key, value) {
      final valor = value[tipo];
      if (valor is double) {
        total += valor;
      } else if (valor is int) {
        total += valor.toDouble();
      }
    });
    return total;
  }

  // Función para calcular total de deudas
  double calcularTotalDeudas(
    Map<String, Map<String, dynamic>> deudas,
    String tipo,
  ) {
    double total = 0;
    deudas.forEach((key, value) {
      final valor = value[tipo];
      if (valor is double) {
        total += valor;
      } else if (valor is int) {
        total += valor.toDouble();
      }
    });
    return total;
  }

  // Formatear moneda
  String formatearMoneda(double valor) {
    final formatoDominicano = NumberFormat.currency(
      locale: 'es_DO',
      symbol: 'RD\$',
      decimalDigits: 2,
    );
    return formatoDominicano.format(valor);
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(
          child: Text(
            'Error: Usuario no autenticado',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return StreamBuilder<Map<String, dynamic>>(
      stream: _firestoreService.streamUserData(user.uid),
      builder: (context, snapshot) {
        // Mostrar loading mientras carga
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0F172A),
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              ),
            ),
          );
        }

        // Mostrar error si algo salió mal
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: const Color(0xFF0F172A),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Color(0xFFEF4444),
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error cargando datos: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // Extraer datos del snapshot
        final data = snapshot.data ?? {};
        final ingresos =
            data['ingresos'] as Map<String, Map<String, dynamic>>? ?? {};
        final gastosFijos =
            data['gastosFijos'] as Map<String, Map<String, dynamic>>? ?? {};
        final gastosVariables =
            data['gastosVariables'] as Map<String, Map<String, dynamic>>? ?? {};
        final ahorros = <String, Map<String, dynamic>>{}; // Por ahora vacío
        final deudas = <String, Map<String, dynamic>>{}; // Por ahora vacío
        final transacciones =
            (data['transacciones'] as List?)
                ?.map((item) => item as Map<String, dynamic>)
                .toList() ??
            [];
        double totalPresupuestado = calcularTotalIngresos(ingresos, 'estimado');
        double totalActual = calcularTotalIngresos(ingresos, 'actual');
        double totalAhorrosActual = calcularTotalAhorros(ahorros, 'actual');
        double totalDeudasActual = calcularTotalDeudas(deudas, 'actual');
        double totalGastosFijosActual = calcularTotalGastosFijos(
          gastosFijos,
          'actual',
        );
        double totalGastosVariablesActual = calcularTotalGastosVariables(
          gastosVariables,
          'actual',
        );

        // Cálculos para Financial Summary
        double gastadoHastaAhora =
            totalGastosFijosActual + totalGastosVariablesActual;
        double disponibleGastar =
            totalActual -
            totalAhorrosActual -
            totalDeudasActual -
            gastadoHastaAhora;

        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 0, 0, 0), // Fondo oscuro
          body: Column(
            children: [
              // HEADER
              HeaderWidget(
                mesActual: mesActual,
                anioActual: anioActual,
                onMesChanged: cambiarMes,
                nombresMeses: nombresMeses,
              ),

              // CONTENIDO PRINCIPAL
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // FILA 1: 4 COLUMNAS (Income, Transactions, Fixed, Variable)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // COLUMNA 1: Income
                          Expanded(
                            flex: 1,
                            child: IngresosWidget(
                              ingresos: ingresos,
                              totalAhorrosActual: totalAhorrosActual,
                              totalDeudasActual: totalDeudasActual,
                              gastadoHastaAhora: gastadoHastaAhora,
                              mesActual: mesActual,
                              anioActual: anioActual,
                              onIngresosUpdated: (nuevosIngresos) {
                                // No necesitamos setState aquí porque el StreamBuilder
                                // detectará automáticamente los cambios en Firebase
                              },
                            ),
                          ),

                          const SizedBox(width: 20),

                          // COLUMNA 2: Transactions
                          Expanded(
                            flex: 1,
                            child: TransaccionesWidget(
                              transacciones: transacciones,
                              // AGREGAR ESTAS DOS LÍNEAS:
                              gastosFijos: gastosFijos,
                              gastosVariables: gastosVariables,
                            ),
                          ),

                          const SizedBox(width: 20),

                          // COLUMNA 3: Fixed Expenses
                          Expanded(
                            flex: 1,
                            child: GastosFijosWidget(gastosFijos: gastosFijos),
                          ),

                          const SizedBox(width: 20),

                          // COLUMNA 4: Variable Expenses
                          Expanded(
                            flex: 1,
                            child: GastosVariablesWidget(
                              gastosVariables: gastosVariables,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // FILA 2: FINANCIAL SUMMARY (ancho completo)
                      FinancialSummaryWidget(
                        availableToSpend: disponibleGastar,
                        spentSoFar: gastadoHastaAhora,
                        savings: totalAhorrosActual,
                        debts: totalDeudasActual,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
