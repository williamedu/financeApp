import 'package:flutter/material.dart';

class OnboardingWizard extends StatefulWidget {
  final String userId;
  final String userEmail;
  final String userName;
  final Function(
    Map<String, Map<String, dynamic>> ingresos,
    Map<String, Map<String, dynamic>> gastosFijos,
    Map<String, Map<String, dynamic>> gastosVariables,
  )
  onComplete;

  const OnboardingWizard({
    super.key,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.onComplete,
  });

  @override
  State<OnboardingWizard> createState() => _OnboardingWizardState();
}

class _OnboardingWizardState extends State<OnboardingWizard> {
  int _currentStep = 0;

  // Datos recolectados (ahora incluyen icono y color)
  Map<String, Map<String, dynamic>> ingresos = {};
  Map<String, Map<String, dynamic>> gastosFijos = {};
  Map<String, Map<String, dynamic>> gastosVariables = {};

  // Controladores para los checkboxes
  final Map<String, TextEditingController> _incomeControllers = {};
  final Map<String, TextEditingController> _fixedExpenseControllers = {};
  final Map<String, TextEditingController> _variableExpenseControllers = {};

  // Controladores para formularios personalizados
  final _customIncomeNameController = TextEditingController();
  final _customIncomeAmountController = TextEditingController();
  final _customFixedNameController = TextEditingController();
  final _customFixedAmountController = TextEditingController();
  final _customVariableNameController = TextEditingController();
  final _customVariableAmountController = TextEditingController();

  // Iconos seleccionados
  IconData _selectedIncomeIcon = Icons.attach_money_rounded;
  Color _selectedIncomeColor = const Color(0xFF10B981);
  IconData _selectedFixedIcon = Icons.attach_money_rounded;
  Color _selectedFixedColor = const Color(0xFFF59E0B);
  IconData _selectedVariableIcon = Icons.attach_money_rounded;
  Color _selectedVariableColor = const Color(0xFF3B82F6);

  @override
  void dispose() {
    _incomeControllers.forEach((key, controller) => controller.dispose());
    _fixedExpenseControllers.forEach((key, controller) => controller.dispose());
    _variableExpenseControllers.forEach(
      (key, controller) => controller.dispose(),
    );
    _customIncomeNameController.dispose();
    _customIncomeAmountController.dispose();
    _customFixedNameController.dispose();
    _customFixedAmountController.dispose();
    _customVariableNameController.dispose();
    _customVariableAmountController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      // Finalizar wizard - SOLO llamar callback, NO cerrar el diálogo
      widget.onComplete(ingresos, gastosFijos, gastosVariables);
      // ELIMINAR esta línea: Navigator.pop(context);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 700,
        constraints: const BoxConstraints(maxHeight: 840, minHeight: 700),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF6366F1), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.3),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: _buildCurrentStep(),
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Configuración Inicial',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: _currentStep >= 0
                        ? Colors.white
                        : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: _currentStep >= 1
                        ? Colors.white
                        : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: _currentStep >= 2
                        ? Colors.white
                        : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: _currentStep >= 3
                        ? Colors.white
                        : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildWelcomeCard();
      case 1:
        return _buildIncomesCard();
      case 2:
        return _buildFixedExpensesCard();
      case 3:
        return _buildVariableExpensesCard();
      default:
        return const SizedBox();
    }
  }

  // CARD 0: Bienvenida
  Widget _buildWelcomeCard() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.waving_hand_rounded,
            color: Colors.white,
            size: 50,
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          '¡Bienvenido a FinanceFlow!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF1F5F9),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Vamos a configurar tu presupuesto en 3 simples pasos',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Color(0xFF94A3B8), height: 1.5),
        ),
        const SizedBox(height: 48),
        _buildFeatureRow(
          Icons.trending_up_rounded,
          'Ingresos',
          'Define tus fuentes de ingreso mensuales',
          const Color(0xFF10B981),
        ),
        const SizedBox(height: 20),
        _buildFeatureRow(
          Icons.lock_outline_rounded,
          'Gastos Fijos',
          'Gastos que se repiten cada mes',
          const Color(0xFFF59E0B),
        ),
        const SizedBox(height: 20),
        _buildFeatureRow(
          Icons.insights_rounded,
          'Gastos Variables',
          'Gastos que pueden variar mes a mes',
          const Color(0xFF3B82F6),
        ),
      ],
    );
  }

  Widget _buildFeatureRow(
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF334155),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF1F5F9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // CARD 1: Ingresos (CON 2 COLUMNAS)
  Widget _buildIncomesCard() {
    final categorias = [
      {
        'nombre': 'Salario Fijo',
        'icon': Icons.account_balance_wallet_outlined,
        'color': const Color(0xFF6366F1),
      },
      {
        'nombre': 'Independiente',
        'icon': Icons.work_outline_rounded,
        'color': const Color(0xFF8B5CF6),
      },
      {
        'nombre': 'Inversiones',
        'icon': Icons.trending_up_rounded,
        'color': const Color(0xFF10B981),
      },
      {
        'nombre': 'Cashbacks',
        'icon': Icons.credit_card_rounded,
        'color': const Color(0xFFF59E0B),
      },
      {
        'nombre': 'Alquiler',
        'icon': Icons.home_work_outlined,
        'color': const Color(0xFF14B8A6),
      },
      {
        'nombre': 'Dividendos',
        'icon': Icons.account_balance_rounded,
        'color': const Color(0xFF3B82F6),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF064E3B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.trending_up_rounded,
                color: Color(0xFF10B981),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ingresos Mensuales',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF1F5F9),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Selecciona tus fuentes de ingreso',
                    style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // GRID DE 2 COLUMNAS CON WRAP
        // GRID DE 2 COLUMNAS CON WRAP
        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth =
                (constraints.maxWidth - 16) /
                2; // 16 es el spacing entre columnas
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: categorias.map((categoria) {
                final nombre = categoria['nombre'] as String;
                final icon = categoria['icon'] as IconData;
                final color = categoria['color'] as Color;
                return SizedBox(
                  width: itemWidth,
                  child: _buildCheckboxItem(
                    nombre,
                    icon,
                    color,
                    'income',
                  ), // Cambia según el tipo
                );
              }).toList(),
            );
          },
        ),

        const SizedBox(height: 24),

        // FORMULARIO PARA AGREGAR PERSONALIZADO
        _buildCustomIncomeForm(),

        const SizedBox(height: 24),

        // LISTA DE INGRESOS AGREGADOS
        if (ingresos.isNotEmpty) ...[
          const Text(
            'INGRESOS AGREGADOS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          ...ingresos.entries.map((entry) {
            return _buildIncomeItem(
              entry.key,
              entry.value['estimado'] as double,
              entry.value['icon'] as IconData,
              entry.value['color'] as Color,
            );
          }),
        ],
      ],
    );
  }

  // CARD 2: Gastos Fijos (CON 2 COLUMNAS + FORM PERSONALIZADO)
  Widget _buildFixedExpensesCard() {
    final categorias = [
      {
        'nombre': 'Renta',
        'icon': Icons.home_outlined,
        'color': const Color(0xFF6366F1),
      },
      {
        'nombre': 'Internet',
        'icon': Icons.wifi_rounded,
        'color': const Color(0xFF8B5CF6),
      },
      {
        'nombre': 'Teléfono',
        'icon': Icons.phone_iphone_rounded,
        'color': const Color(0xFF10B981),
      },
      {
        'nombre': 'Gym',
        'icon': Icons.fitness_center_rounded,
        'color': const Color(0xFFEC4899),
      },
      {
        'nombre': 'Suscripciones',
        'icon': Icons.subscriptions_outlined,
        'color': const Color(0xFFF59E0B),
      },
      {
        'nombre': 'Carro',
        'icon': Icons.directions_car_outlined,
        'color': const Color(0xFF3B82F6),
      },
      {
        'nombre': 'Electricidad',
        'icon': Icons.bolt_rounded,
        'color': const Color(0xFFFBBF24),
      },
      {
        'nombre': 'Agua',
        'icon': Icons.water_drop_outlined,
        'color': const Color(0xFF06B6D4),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF78350F),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                color: Color(0xFFF59E0B),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gastos Fijos Mensuales',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF1F5F9),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Gastos que se repiten cada mes',
                    style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // GRID DE 2 COLUMNAS
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 6.5,
          ),
          itemCount: categorias.length,
          itemBuilder: (context, index) {
            final categoria = categorias[index];
            final nombre = categoria['nombre'] as String;
            final icon = categoria['icon'] as IconData;
            final color = categoria['color'] as Color;
            return _buildCheckboxItem(
              nombre,
              icon,
              color,
              'fixed',
            ); // Cambia según el tipo
          },
        ),

        const SizedBox(height: 24),

        // FORMULARIO PARA AGREGAR PERSONALIZADO
        _buildCustomFixedExpenseForm(),

        const SizedBox(height: 24),

        // LISTA DE GASTOS FIJOS AGREGADOS
        if (gastosFijos.isNotEmpty) ...[
          const Text(
            'GASTOS FIJOS AGREGADOS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          ...gastosFijos.entries.map((entry) {
            return _buildExpenseItem(
              entry.key,
              entry.value['presupuestado'] as double,
              entry.value['icon'] as IconData,
              entry.value['color'] as Color,
            );
          }),
        ],
      ],
    );
  }

  // CARD 3: Gastos Variables (CON 2 COLUMNAS + FORM PERSONALIZADO)
  Widget _buildVariableExpensesCard() {
    final categorias = [
      {
        'nombre': 'Compras',
        'icon': Icons.shopping_cart_outlined,
        'color': const Color(0xFF8B5CF6),
      },
      {
        'nombre': 'Fast Food',
        'icon': Icons.restaurant_outlined,
        'color': const Color(0xFFEF4444),
      },
      {
        'nombre': 'Shopping',
        'icon': Icons.shopping_bag_outlined,
        'color': const Color(0xFFEC4899),
      },
      {
        'nombre': 'Taxis',
        'icon': Icons.local_taxi_outlined,
        'color': const Color(0xFFFBBF24),
      },
      {
        'nombre': 'Entretenimiento',
        'icon': Icons.movie_outlined,
        'color': const Color(0xFF3B82F6),
      },
      {
        'nombre': 'Salud',
        'icon': Icons.favorite_outline_rounded,
        'color': const Color(0xFF10B981),
      },
      {
        'nombre': 'Regalos',
        'icon': Icons.card_giftcard_rounded,
        'color': const Color(0xFFE11D48),
      },
      {
        'nombre': 'Viajes',
        'icon': Icons.flight_outlined,
        'color': const Color(0xFF0EA5E9),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.insights_rounded,
                color: Color(0xFF3B82F6),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gastos Variables',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF1F5F9),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Gastos que pueden variar mes a mes',
                    style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // GRID DE 2 COLUMNAS
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 6.5,
          ),
          itemCount: categorias.length,
          itemBuilder: (context, index) {
            final categoria = categorias[index];
            final nombre = categoria['nombre'] as String;
            final icon = categoria['icon'] as IconData;
            final color = categoria['color'] as Color;
            return _buildCheckboxItem(
              nombre,
              icon,
              color,
              'variable',
            ); // Cambia según el tipo
          },
        ),

        const SizedBox(height: 24),

        // FORMULARIO PARA AGREGAR PERSONALIZADO
        _buildCustomVariableExpenseForm(),

        const SizedBox(height: 24),

        // LISTA DE GASTOS VARIABLES AGREGADOS
        if (gastosVariables.isNotEmpty) ...[
          const Text(
            'GASTOS VARIABLES AGREGADOS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          ...gastosVariables.entries.map((entry) {
            return _buildExpenseItem(
              entry.key,
              entry.value['presupuestado'] as double,
              entry.value['icon'] as IconData,
              entry.value['color'] as Color,
            );
          }),
        ],
      ],
    );
  }

  Widget _buildCheckboxItem(
    String nombre,
    IconData icon,
    Color color,
    String tipo,
  ) {
    final isSelected = tipo == 'income'
        ? ingresos.containsKey(nombre)
        : tipo == 'fixed'
        ? gastosFijos.containsKey(nombre)
        : gastosVariables.containsKey(nombre);

    return InkWell(
      onTap: () {
        if (isSelected) {
          // Deseleccionar y eliminar
          setState(() {
            if (tipo == 'income') {
              ingresos.remove(nombre);
            } else if (tipo == 'fixed') {
              gastosFijos.remove(nombre);
            } else {
              gastosVariables.remove(nombre);
            }
          });
        } else {
          // Mostrar diálogo para ingresar monto
          _showAmountDialog(nombre, icon, color, tipo);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : const Color(0xFF334155),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : const Color(0xFF475569),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                nombre,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? color : const Color(0xFFF1F5F9),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: color, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineAmountInput(
    String nombre,
    IconData icon,
    Color color,
    String tipo,
  ) {
    final controller = tipo == 'income'
        ? _incomeControllers[nombre]!
        : tipo == 'fixed'
        ? _fixedExpenseControllers[nombre]!
        : _variableExpenseControllers[nombre]!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Color(0xFFF1F5F9), fontSize: 14),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: const Color(0xFF334155),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: color),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: color.withOpacity(0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: color, width: 2),
              ),
              labelText: tipo == 'income' ? '¿Cuánto ganas?' : 'Presupuesto',
              labelStyle: TextStyle(color: color, fontSize: 12),
              prefixText: 'RD\$ ',
              prefixStyle: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            onChanged: (value) {
              final monto = double.tryParse(value) ?? 0;
              if (monto > 0) {
                setState(() {
                  if (tipo == 'income') {
                    ingresos[nombre] = {
                      'estimado': monto,
                      'actual': monto,
                      'icon': icon,
                      'color': color,
                    };
                  } else if (tipo == 'fixed') {
                    gastosFijos[nombre] = {
                      'presupuestado': monto,
                      'actual': monto,
                      'icon': icon,
                      'color': color,
                    };
                  } else {
                    gastosVariables[nombre] = {
                      'presupuestado': monto,
                      'actual': 0,
                      'icon': icon,
                      'color': color,
                    };
                  }
                });
              }
            },
          ),
        ],
      ),
    );
  }

  // MOSTRAR DIALOGO DE ICONO CUANDO SE SELECCIONA UNA CATEGORIA
  void _showAmountDialog(
    String nombre,
    IconData icon,
    Color color,
    String tipo,
  ) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                nombre,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF1F5F9),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Color(0xFFF1F5F9)),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF334155),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: color),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: color.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: color, width: 2),
                ),
                labelText: tipo == 'income'
                    ? 'Monto mensual'
                    : 'Presupuesto mensual',
                labelStyle: TextStyle(color: color),
                prefixText: 'RD\$ ',
                prefixStyle: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                if (tipo == 'income') {
                  ingresos.remove(nombre);
                  _incomeControllers[nombre]?.dispose();
                  _incomeControllers.remove(nombre);
                } else if (tipo == 'fixed') {
                  gastosFijos.remove(nombre);
                  _fixedExpenseControllers[nombre]?.dispose();
                  _fixedExpenseControllers.remove(nombre);
                } else {
                  gastosVariables.remove(nombre);
                  _variableExpenseControllers[nombre]?.dispose();
                  _variableExpenseControllers.remove(nombre);
                }
              });
              Navigator.pop(context);
            },
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF94A3B8)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final monto = double.tryParse(controller.text) ?? 0;
              if (monto > 0) {
                setState(() {
                  if (tipo == 'income') {
                    ingresos[nombre] = {
                      'estimado': monto,
                      'actual': monto,
                      'icon': icon,
                      'color': color,
                    };
                  } else if (tipo == 'fixed') {
                    gastosFijos[nombre] = {
                      'presupuestado': monto,
                      'actual': monto,
                      'icon': icon,
                      'color': color,
                    };
                  } else {
                    gastosVariables[nombre] = {
                      'presupuestado': monto,
                      'actual': 0,
                      'icon': icon,
                      'color': color,
                    };
                  }
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // FORMULARIO PERSONALIZADO DE INGRESOS (CON SELECTOR DE ICONO)
  Widget _buildCustomIncomeForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF334155),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Agregar Ingreso Personalizado',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF1F5F9),
            ),
          ),
          const SizedBox(height: 16),

          // Selector de icono
          Row(
            children: [
              const Text(
                'Icono:',
                style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () => _showIconPicker('income'),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _selectedIncomeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _selectedIncomeColor),
                  ),
                  child: Icon(
                    _selectedIncomeIcon,
                    color: _selectedIncomeColor,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Toca para cambiar',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _customIncomeNameController,
            style: const TextStyle(color: Color(0xFFF1F5F9)),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF1E293B),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF6366F1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF475569)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF6366F1),
                  width: 2,
                ),
              ),
              labelText: 'Nombre del ingreso',
              labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
              hintText: 'Ej: Freelance, Alquiler, etc.',
              hintStyle: const TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _customIncomeAmountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Color(0xFFF1F5F9)),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF1E293B),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF6366F1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF475569)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF6366F1),
                  width: 2,
                ),
              ),
              labelText: 'Monto mensual (RD\$)',
              labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
              prefixText: 'RD\$ ',
              prefixStyle: const TextStyle(
                color: Color(0xFF6366F1),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (_customIncomeNameController.text.isNotEmpty &&
                    _customIncomeAmountController.text.isNotEmpty) {
                  final monto =
                      double.tryParse(_customIncomeAmountController.text) ?? 0;
                  if (monto > 0) {
                    setState(() {
                      ingresos[_customIncomeNameController.text] = {
                        'estimado': monto,
                        'actual': monto,
                        'icon': _selectedIncomeIcon,
                        'color': _selectedIncomeColor,
                      };
                    });
                    _customIncomeNameController.clear();
                    _customIncomeAmountController.clear();
                    // Reset icono a default
                    _selectedIncomeIcon = Icons.attach_money_rounded;
                    _selectedIncomeColor = const Color(0xFF10B981);
                  }
                }
              },
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Agregar Ingreso'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // FORMULARIO PERSONALIZADO DE GASTOS FIJOS (CON SELECTOR DE ICONO)
  Widget _buildCustomFixedExpenseForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF334155),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Agregar Gasto Fijo Personalizado',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF1F5F9),
            ),
          ),
          const SizedBox(height: 16),

          // Selector de icono
          Row(
            children: [
              const Text(
                'Icono:',
                style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () => _showIconPicker('fixed'),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _selectedFixedColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _selectedFixedColor),
                  ),
                  child: Icon(
                    _selectedFixedIcon,
                    color: _selectedFixedColor,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Toca para cambiar',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _customFixedNameController,
            style: const TextStyle(color: Color(0xFFF1F5F9)),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF1E293B),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFF59E0B)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF475569)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFFF59E0B),
                  width: 2,
                ),
              ),
              labelText: 'Nombre del gasto',
              labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
              hintText: 'Ej: Seguro, Parking, etc.',
              hintStyle: const TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _customFixedAmountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Color(0xFFF1F5F9)),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF1E293B),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFF59E0B)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF475569)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFFF59E0B),
                  width: 2,
                ),
              ),
              labelText: 'Presupuesto mensual (RD\$)',
              labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
              prefixText: 'RD\$ ',
              prefixStyle: const TextStyle(
                color: Color(0xFFF59E0B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (_customFixedNameController.text.isNotEmpty &&
                    _customFixedAmountController.text.isNotEmpty) {
                  final monto =
                      double.tryParse(_customFixedAmountController.text) ?? 0;
                  if (monto > 0) {
                    setState(() {
                      gastosFijos[_customFixedNameController.text] = {
                        'presupuestado': monto,
                        'actual': monto,
                        'icon': _selectedFixedIcon,
                        'color': _selectedFixedColor,
                      };
                    });
                    _customFixedNameController.clear();
                    _customFixedAmountController.clear();
                    _selectedFixedIcon = Icons.attach_money_rounded;
                    _selectedFixedColor = const Color(0xFFF59E0B);
                  }
                }
              },
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Agregar Gasto Fijo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // FORMULARIO PERSONALIZADO DE GASTOS VARIABLES (CON SELECTOR DE ICONO)
  Widget _buildCustomVariableExpenseForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF334155),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Agregar Gasto Variable Personalizado',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF1F5F9),
            ),
          ),
          const SizedBox(height: 16),

          // Selector de icono
          Row(
            children: [
              const Text(
                'Icono:',
                style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () => _showIconPicker('variable'),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _selectedVariableColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _selectedVariableColor),
                  ),
                  child: Icon(
                    _selectedVariableIcon,
                    color: _selectedVariableColor,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Toca para cambiar',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _customVariableNameController,
            style: const TextStyle(color: Color(0xFFF1F5F9)),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF1E293B),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF3B82F6)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF475569)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF3B82F6),
                  width: 2,
                ),
              ),
              labelText: 'Nombre del gasto',
              labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
              hintText: 'Ej: Cine, Mascotas, etc.',
              hintStyle: const TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _customVariableAmountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Color(0xFFF1F5F9)),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF1E293B),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF3B82F6)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF475569)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF3B82F6),
                  width: 2,
                ),
              ),
              labelText: 'Presupuesto mensual (RD\$)',
              labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
              prefixText: 'RD\$ ',
              prefixStyle: const TextStyle(
                color: Color(0xFF3B82F6),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (_customVariableNameController.text.isNotEmpty &&
                    _customVariableAmountController.text.isNotEmpty) {
                  final monto =
                      double.tryParse(_customVariableAmountController.text) ??
                      0;
                  if (monto > 0) {
                    setState(() {
                      gastosVariables[_customVariableNameController.text] = {
                        'presupuestado': monto,
                        'actual': 0,
                        'icon': _selectedVariableIcon,
                        'color': _selectedVariableColor,
                      };
                    });
                    _customVariableNameController.clear();
                    _customVariableAmountController.clear();
                    _selectedVariableIcon = Icons.attach_money_rounded;
                    _selectedVariableColor = const Color(0xFF3B82F6);
                  }
                }
              },
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Agregar Gasto Variable'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // SELECTOR DE ICONOS (ORGANIZADO POR CATEGORÍAS)
  void _showIconPicker(String tipo) {
    final categorias = {
      'Dinero': [
        {'icon': Icons.attach_money_rounded, 'color': const Color(0xFF10B981)},
        {'icon': Icons.paid_rounded, 'color': const Color(0xFF059669)},
        {
          'icon': Icons.account_balance_wallet_outlined,
          'color': const Color(0xFF6366F1),
        },
        {'icon': Icons.savings_rounded, 'color': const Color(0xFF3B82F6)},
        {
          'icon': Icons.account_balance_rounded,
          'color': const Color(0xFF8B5CF6),
        },
      ],
      'Trabajo': [
        {'icon': Icons.work_outline_rounded, 'color': const Color(0xFF8B5CF6)},
        {
          'icon': Icons.business_center_rounded,
          'color': const Color(0xFF6366F1),
        },
        {'icon': Icons.badge_outlined, 'color': const Color(0xFF14B8A6)},
        {'icon': Icons.card_travel_rounded, 'color': const Color(0xFF06B6D4)},
      ],
      'Inversiones': [
        {'icon': Icons.trending_up_rounded, 'color': const Color(0xFF10B981)},
        {'icon': Icons.show_chart_rounded, 'color': const Color(0xFF059669)},
        {
          'icon': Icons.candlestick_chart_rounded,
          'color': const Color(0xFF3B82F6),
        },
      ],
      'Casa': [
        {'icon': Icons.home_outlined, 'color': const Color(0xFF6366F1)},
        {'icon': Icons.home_work_outlined, 'color': const Color(0xFF14B8A6)},
        {'icon': Icons.house_rounded, 'color': const Color(0xFF8B5CF6)},
        {'icon': Icons.apartment_rounded, 'color': const Color(0xFF06B6D4)},
      ],
      'Tecnología': [
        {'icon': Icons.wifi_rounded, 'color': const Color(0xFF8B5CF6)},
        {'icon': Icons.phone_iphone_rounded, 'color': const Color(0xFF10B981)},
        {'icon': Icons.computer_rounded, 'color': const Color(0xFF6366F1)},
        {'icon': Icons.devices_rounded, 'color': const Color(0xFF3B82F6)},
      ],
      'Transporte': [
        {
          'icon': Icons.directions_car_outlined,
          'color': const Color(0xFF3B82F6),
        },
        {'icon': Icons.local_taxi_outlined, 'color': const Color(0xFFFBBF24)},
        {
          'icon': Icons.directions_bus_rounded,
          'color': const Color(0xFFF59E0B),
        },
        {'icon': Icons.two_wheeler_rounded, 'color': const Color(0xFFEF4444)},
        {
          'icon': Icons.local_gas_station_rounded,
          'color': const Color(0xFFF97316),
        },
      ],
      'Salud': [
        {
          'icon': Icons.fitness_center_rounded,
          'color': const Color(0xFFEC4899),
        },
        {
          'icon': Icons.favorite_outline_rounded,
          'color': const Color(0xFF10B981),
        },
        {
          'icon': Icons.medical_services_outlined,
          'color': const Color(0xFFEF4444),
        },
        {
          'icon': Icons.local_hospital_rounded,
          'color': const Color(0xFF3B82F6),
        },
      ],
      'Comida': [
        {'icon': Icons.restaurant_outlined, 'color': const Color(0xFFEF4444)},
        {'icon': Icons.fastfood_outlined, 'color': const Color(0xFFF97316)},
        {'icon': Icons.local_pizza_rounded, 'color': const Color(0xFFF59E0B)},
        {'icon': Icons.coffee_rounded, 'color': const Color(0xFF78716C)},
        {
          'icon': Icons.shopping_cart_outlined,
          'color': const Color(0xFF8B5CF6),
        },
      ],
      'Entretenimiento': [
        {'icon': Icons.movie_outlined, 'color': const Color(0xFF3B82F6)},
        {
          'icon': Icons.sports_esports_rounded,
          'color': const Color(0xFF8B5CF6),
        },
        {'icon': Icons.music_note_rounded, 'color': const Color(0xFFEC4899)},
        {
          'icon': Icons.theater_comedy_rounded,
          'color': const Color(0xFFF59E0B),
        },
      ],
      'Servicios': [
        {'icon': Icons.bolt_rounded, 'color': const Color(0xFFFBBF24)},
        {'icon': Icons.water_drop_outlined, 'color': const Color(0xFF06B6D4)},
        {
          'icon': Icons.subscriptions_outlined,
          'color': const Color(0xFFF59E0B),
        },
        {'icon': Icons.build_outlined, 'color': const Color(0xFF78716C)},
      ],
      'Otros': [
        {'icon': Icons.card_giftcard_rounded, 'color': const Color(0xFFE11D48)},
        {'icon': Icons.shopping_bag_outlined, 'color': const Color(0xFFEC4899)},
        {'icon': Icons.flight_outlined, 'color': const Color(0xFF0EA5E9)},
        {'icon': Icons.pets_rounded, 'color': const Color(0xFF10B981)},
        {'icon': Icons.dry_cleaning_outlined, 'color': const Color(0xFFA855F7)},
        {'icon': Icons.celebration_outlined, 'color': const Color(0xFFF472B6)},
      ],
    };

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 600,
          constraints: const BoxConstraints(maxHeight: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Selecciona un Icono',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF1F5F9),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: const Color(0xFF94A3B8),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: categorias.length,
                  itemBuilder: (context, index) {
                    final categoria = categorias.entries.elementAt(index);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            categoria.key,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: categoria.value.map((item) {
                            final icon = item['icon'] as IconData;
                            final color = item['color'] as Color;
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  if (tipo == 'income') {
                                    _selectedIncomeIcon = icon;
                                    _selectedIncomeColor = color;
                                  } else if (tipo == 'fixed') {
                                    _selectedFixedIcon = icon;
                                    _selectedFixedColor = color;
                                  } else {
                                    _selectedVariableIcon = icon;
                                    _selectedVariableColor = color;
                                  }
                                });
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: color.withOpacity(0.3),
                                  ),
                                ),
                                child: Icon(icon, color: color, size: 28),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ITEM DE INGRESO AGREGADO
  Widget _buildIncomeItem(
    String nombre,
    double monto,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF334155),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF1F5F9),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'RD\$ ${monto.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    setState(() {
                      ingresos.remove(nombre);
                    });
                  },
                  child: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ITEM DE GASTO AGREGADO
  Widget _buildExpenseItem(
    String nombre,
    double monto,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF334155),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF1F5F9),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'RD\$ ${monto.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    setState(() {
                      if (gastosFijos.containsKey(nombre)) {
                        gastosFijos.remove(nombre);
                      } else {
                        gastosVariables.remove(nombre);
                      }
                    });
                  },
                  child: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF334155), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            TextButton.icon(
              onPressed: _previousStep,
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Atrás'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF94A3B8),
              ),
            )
          else
            const SizedBox(),
          ElevatedButton(
            onPressed: _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _currentStep == 3 ? 'Finalizar' : 'Continuar',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
