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

  // Estado de carga
  bool _isLoading = true;

  // Datos que se cargarán desde Firebase
  Map<String, Map<String, dynamic>> ingresos = {};
  Map<String, Map<String, dynamic>> gastosFijos = {};
  Map<String, Map<String, dynamic>> gastosVariables = {};
  Map<String, Map<String, dynamic>> ahorros = {};
  Map<String, Map<String, dynamic>> deudas = {};

  // TRANSACCIONES (por ahora hardcodeadas, las implementaremos después)
  final List<Map<String, dynamic>> transacciones = [
    {
      'categoria': 'Combustible',
      'monto': 2500.00,
      'fecha': '01/11/2024',
      'concepto': 'Tanque de gasolina',
    },
    {
      'categoria': 'Compras',
      'monto': 1984.00,
      'fecha': '02/11/2024',
      'concepto': 'Supermercado compras',
    },
    {
      'categoria': 'Fast Food',
      'monto': 285.00,
      'fecha': '03/11/2024',
      'concepto': 'Almuerzo restaurante',
    },
    {
      'categoria': 'Retiro efectivo',
      'monto': 500.00,
      'fecha': '04/11/2024',
      'concepto': 'Efectivo ATM',
    },
    {
      'categoria': 'Agua W magno',
      'monto': 2000.00,
      'fecha': '05/11/2024',
      'concepto': 'Pago agua mensual',
    },
    {
      'categoria': 'Compras',
      'monto': 897.00,
      'fecha': '06/11/2024',
      'concepto': 'Cositas utiles del hogar',
    },
    {
      'categoria': 'Renta',
      'monto': 11250.00,
      'fecha': '07/11/2024',
      'concepto': 'Pago renta del mes',
    },
    {
      'categoria': 'Suscripciones',
      'monto': 250.00,
      'fecha': '08/11/2024',
      'concepto': 'HBO max',
    },
  ];

  @override
  void initState() {
    super.initState();
    _cargarDatosFirebase();
  }

  Future<void> _cargarDatosFirebase() async {
    final user = _authService.currentUser;
    if (user != null) {
      try {
        final datos = await _firestoreService.loadUserData(user.uid);
        setState(() {
          ingresos =
              datos['ingresos'] as Map<String, Map<String, dynamic>>? ?? {};
          gastosFijos =
              datos['gastosFijos'] as Map<String, Map<String, dynamic>>? ?? {};
          gastosVariables =
              datos['gastosVariables'] as Map<String, Map<String, dynamic>>? ??
              {};
          ahorros = {}; // Por ahora vacío, lo implementaremos después
          deudas = {}; // Por ahora vacío, lo implementaremos después
          _isLoading = false;
        });
        debugPrint('✅ Datos cargados desde Firebase');
        debugPrint('Ingresos: $ingresos');
        debugPrint('Gastos Fijos: $gastosFijos');
        debugPrint('Gastos Variables: $gastosVariables');
      } catch (e) {
        debugPrint('❌ Error cargando datos: $e');
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      debugPrint('❌ No hay usuario logueado');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Función para cambiar mes
  void cambiarMes(int nuevoMes) {
    setState(() {
      mesActual = nuevoMes;
    });
  }

  // Función para calcular total de ingresos
  double calcularTotalIngresos(String tipo) {
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
  double calcularTotalGastosFijos(String tipo) {
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
  double calcularTotalGastosVariables(String tipo) {
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
  double calcularTotalAhorros(String tipo) {
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
  double calcularTotalDeudas(String tipo) {
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
    // Mostrar loading mientras carga los datos
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
          ),
        ),
      );
    }

    double totalPresupuestado = calcularTotalIngresos('estimado');
    double totalActual = calcularTotalIngresos('actual');
    double totalAhorrosActual = calcularTotalAhorros('actual');
    double totalDeudasActual = calcularTotalDeudas('actual');
    double totalGastosFijosActual = calcularTotalGastosFijos('actual');
    double totalGastosVariablesActual = calcularTotalGastosVariables('actual');

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
                        child: _buildSeccionIngresos(
                          totalPresupuestado,
                          totalActual,
                          disponibleGastar,
                          gastadoHastaAhora,
                          totalAhorrosActual,
                          totalDeudasActual,
                        ),
                      ),

                      const SizedBox(width: 20),

                      // COLUMNA 2: Transactions
                      Expanded(flex: 1, child: _buildSeccionTransacciones()),

                      const SizedBox(width: 20),

                      // COLUMNA 3: Fixed Expenses
                      Expanded(flex: 1, child: _buildSeccionGastosFijos()),

                      const SizedBox(width: 20),

                      // COLUMNA 4: Variable Expenses
                      Expanded(flex: 1, child: _buildSeccionGastosVariables()),
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
  }

  // WIDGET: Sección de Ingresos
  Widget _buildSeccionIngresos(
    double totalPresupuestado,
    double totalActual,
    double disponibleGastar,
    double gastadoHastaAhora,
    double totalAhorrosActual,
    double totalDeudasActual,
  ) {
    return IngresosWidget(
      ingresos: ingresos,
      totalAhorrosActual: totalAhorrosActual,
      totalDeudasActual: totalDeudasActual,
      gastadoHastaAhora: gastadoHastaAhora,
      mesActual: mesActual,
      anioActual: anioActual,
      onIngresosUpdated: actualizarIngresos,
    );
  }

  Widget _buildSeccionTransacciones() {
    return TransaccionesWidget(transacciones: transacciones);
  }

  Widget _buildSeccionGastosFijos() {
    return GastosFijosWidget(gastosFijos: gastosFijos);
  }

  Widget _buildSeccionGastosVariables() {
    return GastosVariablesWidget(gastosVariables: gastosVariables);
  }

  // Función para actualizar ingresos
  void actualizarIngresos(Map<String, Map<String, dynamic>> nuevosIngresos) {
    setState(() {
      ingresos.clear();
      ingresos.addAll(nuevosIngresos);
    });
  }
}
