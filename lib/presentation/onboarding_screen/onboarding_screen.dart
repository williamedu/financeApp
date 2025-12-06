import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import '../../theme/app_theme.dart';
import '../../services/firestore_service.dart';
import '../../routes/app_routes.dart';
import '../add_transaction_screen/widgets/icon_category_picker_widget.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;

  late String userId;
  late String userEmail;
  late String userName;
  bool _isInitialized = false;

  // ESTADO DE MONEDA
  String _selectedCurrencyCode = 'DOP';
  String _currencySymbol = 'RD\$';

  final List<Map<String, String>> _currencies = [
    {
      'code': 'DOP',
      'label': 'Peso Dominicano',
      'symbol': 'RD\$',
      'flag': '🇩🇴',
    },
    {
      'code': 'USD',
      'label': 'Dólar Estadounidense',
      'symbol': '\$',
      'flag': '🇺🇸',
    },
    {'code': 'EUR', 'label': 'Euro', 'symbol': '€', 'flag': '🇪🇺'},
  ];

  Map<String, Map<String, dynamic>> ingresos = {};
  Map<String, Map<String, dynamic>> gastosFijos = {};
  Map<String, Map<String, dynamic>> gastosVariables = {};

  final _customIncomeNameController = TextEditingController();
  final _customIncomeAmountController = TextEditingController();
  final _customFixedNameController = TextEditingController();
  final _customFixedAmountController = TextEditingController();
  final _customVariableNameController = TextEditingController();
  final _customVariableAmountController = TextEditingController();

  IconData _selectedIncomeIcon = Icons.attach_money_rounded;
  Color _selectedIncomeColor = const Color(0xFF10B981);
  IconData _selectedFixedIcon = Icons.home_rounded;
  Color _selectedFixedColor = const Color(0xFFF59E0B);
  IconData _selectedVariableIcon = Icons.shopping_cart_rounded;
  Color _selectedVariableColor = const Color(0xFF3B82F6);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      userId = args['userId'];
      userEmail = args['userEmail'];
      userName = args['userName'];
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _customIncomeNameController.dispose();
    _customIncomeAmountController.dispose();
    _customFixedNameController.dispose();
    _customFixedAmountController.dispose();
    _customVariableNameController.dispose();
    _customVariableAmountController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    setState(() => _isLoading = true);
    try {
      await _firestoreService.saveInitialData(
        uid: userId,
        email: userEmail,
        displayName: userName,
        currency: _selectedCurrencyCode, // Enviamos moneda
        ingresos: ingresos,
        gastosFijos: gastosFijos,
        gastosVariables: gastosVariables,
      );

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.homeDashboard,
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      _finishOnboarding();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _showUnifiedIconPicker(String tipo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => IconCategoryPickerWidget(
        onSelected: (catName, icon, color) {
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
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            )
          : SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 2.h,
                      ),
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
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      width: 100.w,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
      ),
      child: Column(
        children: [
          Text(
            'Configuración Inicial',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: List.generate(
              4,
              (index) => Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.symmetric(horizontal: 1.w),
                  decoration: BoxDecoration(
                    color: _currentStep >= index
                        ? Colors.white
                        : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
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

  Widget _buildWelcomeCard() {
    return Column(
      children: [
        SizedBox(height: 3.h),
        Icon(
          Icons.savings_rounded,
          color: const Color(0xFF6366F1),
          size: 70.sp,
        ),
        SizedBox(height: 2.h),
        Text(
          'Toma el Control Total',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 1.h),
        const Text(
          'Bienvenido a FinanceFlow. Antes de comenzar, personaliza tu experiencia eligiendo tu moneda local.',
          style: TextStyle(color: Colors.grey, height: 1.5),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 4.h),

        // SELECTOR DE MONEDA CON BANDERA
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.5)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCurrencyCode,
              dropdownColor: const Color(0xFF1E293B),
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white,
              ),
              items: _currencies.map((currency) {
                return DropdownMenuItem(
                  value: currency['code'],
                  child: Row(
                    children: [
                      Text(
                        currency['flag']!,
                        style: TextStyle(fontSize: 20.sp),
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        currency['code']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        "- ${currency['label']}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedCurrencyCode = val;
                    _currencySymbol = _currencies.firstWhere(
                      (c) => c['code'] == val,
                    )['symbol']!;
                  });
                }
              },
            ),
          ),
        ),

        SizedBox(height: 4.h),
        _buildFeatureRow(
          Icons.account_balance,
          '1. Define tus Ingresos',
          'Salario, inversiones o negocios. La base de tu crecimiento.',
          const Color(0xFF10B981),
        ),
        SizedBox(height: 2.h),
        _buildFeatureRow(
          Icons.lock_outline,
          '2. Compromisos Fijos',
          'Renta, servicios y deudas. Lo esencial para tu tranquilidad.',
          const Color(0xFFF59E0B),
        ),
        SizedBox(height: 2.h),
        _buildFeatureRow(
          Icons.pie_chart,
          '3. Control Variable',
          'Ocio, transporte y gustos. Optimiza tu estilo de vida.',
          const Color(0xFF3B82F6),
        ),
      ],
    );
  }

  Widget _buildFeatureRow(
    IconData icon,
    String title,
    String desc,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  desc,
                  style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomesCard() {
    final categorias = [
      {
        'nombre': 'Salario',
        'icon': Icons.work,
        'color': const Color(0xFF6366F1),
      },
      {
        'nombre': 'Negocio',
        'icon': Icons.store,
        'color': const Color(0xFF8B5CF6),
      },
      {
        'nombre': 'Freelance',
        'icon': Icons.laptop_mac,
        'color': const Color(0xFFF59E0B),
      },
      {
        'nombre': 'Inversiones',
        'icon': Icons.trending_up,
        'color': const Color(0xFF10B981),
      },
    ];
    return _buildStepContent(
      'Fuentes de Ingreso',
      'Identifica cuánto dinero entra a tu bolsillo mensualmente.',
      'income',
      categorias,
      ingresos,
      _customIncomeNameController,
      _customIncomeAmountController,
      _selectedIncomeIcon,
      _selectedIncomeColor,
    );
  }

  Widget _buildFixedExpensesCard() {
    final categorias = [
      {
        'nombre': 'Alquiler',
        'icon': Icons.home,
        'color': const Color(0xFFEF4444),
      },
      {
        'nombre': 'Internet',
        'icon': Icons.wifi,
        'color': const Color(0xFF3B82F6),
      },
      {
        'nombre': 'Luz',
        'icon': Icons.lightbulb,
        'color': const Color(0xFFFBBF24),
      },
      {
        'nombre': 'Agua',
        'icon': Icons.water_drop,
        'color': const Color(0xFF0EA5E9),
      },
    ];
    return _buildStepContent(
      'Gastos Fijos',
      'Pagos recurrentes que no puedes evadir (Renta, Luz, Internet).',
      'fixed',
      categorias,
      gastosFijos,
      _customFixedNameController,
      _customFixedAmountController,
      _selectedFixedIcon,
      _selectedFixedColor,
    );
  }

  Widget _buildVariableExpensesCard() {
    final categorias = [
      {
        'nombre': 'Comida',
        'icon': Icons.restaurant,
        'color': const Color(0xFFF97316),
      },
      {
        'nombre': 'Transporte',
        'icon': Icons.directions_car,
        'color': const Color(0xFF6366F1),
      },
      {'nombre': 'Ocio', 'icon': Icons.movie, 'color': const Color(0xFFEC4899)},
      {
        'nombre': 'Compras',
        'icon': Icons.shopping_bag,
        'color': const Color(0xFF8B5CF6),
      },
    ];
    return _buildStepContent(
      'Gastos Variables',
      'Gastos que fluctúan mes a mes. Aquí es donde puedes ahorrar.',
      'variable',
      categorias,
      gastosVariables,
      _customVariableNameController,
      _customVariableAmountController,
      _selectedVariableIcon,
      _selectedVariableColor,
    );
  }

  Widget _buildStepContent(
    String title,
    String subtitle,
    String tipo,
    List<Map<String, dynamic>> defaults,
    Map<String, Map<String, dynamic>> dataMap,
    TextEditingController nameCtrl,
    TextEditingController amountCtrl,
    IconData customIcon,
    Color customColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          subtitle,
          style: TextStyle(fontSize: 11.sp, color: Colors.grey),
        ),
        SizedBox(height: 3.h),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: defaults.length,
          itemBuilder: (ctx, i) {
            final cat = defaults[i];
            final nombre = cat['nombre'] as String;
            final isSelected = dataMap.containsKey(nombre);

            return InkWell(
              onTap: () {
                if (isSelected) {
                  setState(() => dataMap.remove(nombre));
                } else {
                  _showAmountDialog(
                    nombre,
                    cat['icon'] as IconData,
                    cat['color'] as Color,
                    tipo,
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? (cat['color'] as Color).withOpacity(0.2)
                      : const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? (cat['color'] as Color)
                        : Colors.grey.withOpacity(0.2),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Icon(cat['icon'] as IconData, color: cat['color'] as Color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: cat['color'] as Color,
                        size: 16,
                      ),
                  ],
                ),
              ),
            );
          },
        ),

        SizedBox(height: 3.h),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Agregar otro diferente:',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2.h),

              InkWell(
                onTap: () => _showUnifiedIconPicker(tipo),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: customColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: customColor.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      Icon(customIcon, color: customColor),
                      const SizedBox(width: 10),
                      const Text(
                        'Toca para cambiar icono',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 2.h),

              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDeco('Nombre (Ej: Netflix)', Icons.label),
              ),
              SizedBox(height: 1.5.h),

              // INPUT MANUAL SIN FORMATEADOR
              TextField(
                controller: amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDeco(
                  'Monto Mensual',
                  Icons.attach_money,
                  prefix: _currencySymbol,
                ),
              ),
              SizedBox(height: 2.h),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final monto = double.tryParse(amountCtrl.text) ?? 0;
                    if (nameCtrl.text.isNotEmpty && monto > 0) {
                      setState(() {
                        dataMap[nameCtrl.text] = {
                          'estimado': monto,
                          'presupuestado': monto,
                          'actual': tipo == 'income' ? monto : 0,
                          'icon': customIcon,
                          'color': customColor,
                        };
                      });
                      nameCtrl.clear();
                      amountCtrl.clear();
                      if (tipo == 'income') {
                        _selectedIncomeIcon = Icons.attach_money;
                        _selectedIncomeColor = const Color(0xFF10B981);
                      }
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar a la lista'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 3.h),

        // Lista de Agregados
        if (dataMap.isNotEmpty) ...[
          const Text(
            'Resumen:',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          SizedBox(height: 1.h),
          ...dataMap.entries.map((e) {
            final val = e.value;
            final esIngreso = tipo == 'income';
            final montoMostrar = esIngreso
                ? val['actual']
                : val['presupuestado'];

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: (val['color'] as Color).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    val['icon'] as IconData,
                    color: val['color'] as Color,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      e.key,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  // MONTO SIMPLE SIN FORMATO ESPECIAL AQUÍ
                  Text(
                    '$_currencySymbol ${montoMostrar.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: val['color'],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () => setState(() => dataMap.remove(e.key)),
                    child: const Icon(
                      Icons.close,
                      color: Colors.grey,
                      size: 18,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ],
    );
  }

  InputDecoration _inputDeco(String label, IconData icon, {String? prefix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      prefixIcon: Icon(icon, color: Colors.grey),
      prefixText: prefix != null ? '$prefix ' : null,
      prefixStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      filled: true,
      fillColor: const Color(0xFF0F172A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  void _showAmountDialog(
    String nombre,
    IconData icon,
    Color color,
    String tipo,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(nombre, style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white),
          decoration: _inputDeco(
            'Monto Mensual',
            Icons.attach_money,
            prefix: _currencySymbol,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final monto = double.tryParse(controller.text) ?? 0;
              if (monto > 0) {
                setState(() {
                  final map = tipo == 'income'
                      ? ingresos
                      : (tipo == 'fixed' ? gastosFijos : gastosVariables);
                  map[nombre] = {
                    'estimado': monto,
                    'presupuestado': monto,
                    'actual': tipo == 'income' ? monto : 0,
                    'icon': icon,
                    'color': color,
                  };
                });
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: color),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        border: Border(top: BorderSide(color: Color(0xFF334155))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            TextButton(
              onPressed: _previousStep,
              child: const Text('Atrás', style: TextStyle(color: Colors.grey)),
            )
          else
            const SizedBox(),

          ElevatedButton(
            onPressed: _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _currentStep == 3 ? 'Finalizar' : 'Continuar',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
