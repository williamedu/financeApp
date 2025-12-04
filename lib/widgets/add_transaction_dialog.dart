import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AddTransactionDialog extends StatefulWidget {
  // Ahora recibimos todas las categorías para el buscador
  final List<String> categoriasExistentes;

  // Actualizamos el callback para devolver más datos si se crea un presupuesto nuevo
  final Function(
    String categoria,
    double monto,
    String concepto,
    String fecha, {
    bool? crearPresupuesto,
    String? tipoPresupuesto, // 'fijo' o 'variable'
    double? montoPresupuesto,
    IconData? icon,
    Color? color,
  })
  onAdd;

  const AddTransactionDialog({
    super.key,
    required this.categoriasExistentes,
    required this.onAdd,
  });

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  int _opcionSeleccionada = 0; // 0 = Existente, 1 = Manual

  // Controladores básicos
  final _montoController = TextEditingController();
  final _conceptoController = TextEditingController();
  DateTime _fechaSeleccionada = DateTime.now();

  // Para modo Existente
  String? _categoriaExistenteSeleccionada;

  // Para modo Manual
  final _nombreManualController = TextEditingController();

  // Nuevos campos para Icono y Color (Valores por defecto)
  IconData _selectedIcon = Icons.category_rounded;
  Color _selectedColor = const Color(0xFF6366F1);

  // Lógica de "Agregar a Presupuesto"
  bool _agregarAPresupuesto = false;
  String _tipoPresupuesto = 'variable'; // 'fijo' o 'variable'
  final _estimadoController = TextEditingController();

  @override
  void dispose() {
    _montoController.dispose();
    _conceptoController.dispose();
    _nombreManualController.dispose();
    _estimadoController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6366F1),
              onPrimary: Colors.white,
              surface: Color(0xFF1E293B),
              onSurface: Color(0xFFF1F5F9),
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _fechaSeleccionada) {
      setState(() {
        _fechaSeleccionada = picked;
      });
    }
  }

  // SELECTOR DE ICONOS MEJORADO (Categorizado como en el Wizard)
  void _showIconPicker() {
    // Mapa de categorías idéntico al del Wizard
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
                                  // Al seleccionar, actualizamos tanto el icono como el color
                                  _selectedIcon = icon;
                                  _selectedColor = color;
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 800),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF334155), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context),
            const SizedBox(height: 24),

            // Selector de Modo (Tabs)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF334155),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildOptionButton(
                      'Usar Existente',
                      Icons.list_alt_rounded,
                      0,
                    ),
                  ),
                  Expanded(
                    child: _buildOptionButton(
                      'Crear Manual',
                      Icons.edit_rounded,
                      1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Contenido Scrollable
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Sección Categoría (Varía según tab)
                    if (_opcionSeleccionada == 0)
                      _buildExistenteSection()
                    else
                      _buildManualSection(),

                    const SizedBox(height: 20),

                    // CAMPOS COMUNES (Monto, Concepto, Fecha)
                    _buildCommonFields(),

                    // SECCIÓN EXTRA PARA MODO MANUAL (Presupuesto)
                    if (_opcionSeleccionada == 1) ...[
                      const SizedBox(height: 24),
                      const Divider(color: Color(0xFF475569)),
                      const SizedBox(height: 16),
                      _buildAddToBudgetSection(),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Botones Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _guardarTransaccion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Guardar Transacción',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF581C87),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.receipt_long_rounded,
            color: Color(0xFF8B5CF6),
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nueva Transacción',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF1F5F9),
                ),
              ),
              Text(
                'Registra un movimiento',
                style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
          color: const Color(0xFF94A3B8),
        ),
      ],
    );
  }

  Widget _buildOptionButton(String label, IconData icon, int valor) {
    bool isSelected = _opcionSeleccionada == valor;
    return GestureDetector(
      onTap: () => setState(() => _opcionSeleccionada = valor),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF475569) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sección 1: AUTOCOMPLETE para categorías existentes
  Widget _buildExistenteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Buscar Categoría',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 8),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text == '') {
              return const Iterable<String>.empty();
            }
            return widget.categoriasExistentes.where((String option) {
              return option.toLowerCase().contains(
                textEditingValue.text.toLowerCase(),
              );
            });
          },
          onSelected: (String selection) {
            setState(() {
              _categoriaExistenteSeleccionada = selection;
            });
          },
          fieldViewBuilder:
              (context, textEditingController, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Escribe para buscar...',
                    hintStyle: const TextStyle(color: Color(0xFF64748B)),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF94A3B8),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF334155),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                );
              },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                color: const Color(0xFF334155),
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 300,
                  height: 200,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final String option = options.elementAt(index);
                      return ListTile(
                        title: Text(
                          option,
                          style: const TextStyle(color: Colors.white),
                        ),
                        onTap: () => onSelected(option),
                        hoverColor: const Color(0xFF475569),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Sección 2: CREACIÓN MANUAL con Icono y Color
  Widget _buildManualSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detalles de la Nueva Categoría',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Picker Icono
            InkWell(
              onTap: _showIconPicker,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _selectedColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _selectedColor),
                ),
                child: Icon(_selectedIcon, color: _selectedColor, size: 28),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _nombreManualController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nombre Categoría',
                  labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  filled: true,
                  fillColor: const Color(0xFF334155),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // CAMPOS COMUNES (Monto, Concepto, Fecha)
  Widget _buildCommonFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _montoController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Monto',
                  labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  prefixText: 'RD\$ ',
                  prefixStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: const Color(0xFF334155),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            InkWell(
              onTap: () => _seleccionarFecha(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF334155),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 20,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd/MM/yyyy').format(_fechaSeleccionada),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _conceptoController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Concepto (Opcional)',
            labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
            filled: true,
            fillColor: const Color(0xFF334155),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  // SECCIÓN "AGREGAR A PRESUPUESTO"
  Widget _buildAddToBudgetSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _agregarAPresupuesto
              ? const Color(0xFF6366F1)
              : const Color(0xFF334155),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                color: _agregarAPresupuesto
                    ? const Color(0xFF6366F1)
                    : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '¿Incluir en Presupuesto?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Switch(
                value: _agregarAPresupuesto,
                activeColor: const Color(0xFF6366F1),
                onChanged: (val) {
                  setState(() {
                    _agregarAPresupuesto = val;
                    // Si activa el presupuesto, sugerimos el monto de la transacción como estimado inicial
                    if (val && _montoController.text.isNotEmpty) {
                      _estimadoController.text = _montoController.text;
                    }
                  });
                },
              ),
            ],
          ),

          if (_agregarAPresupuesto) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                _buildRadioOption('Variable', 'variable'),
                const SizedBox(width: 16),
                _buildRadioOption('Fijo', 'fijo'),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _estimadoController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Presupuesto Mensual Estimado',
                labelStyle: const TextStyle(color: Color(0xFF6366F1)),
                prefixText: 'RD\$ ',
                prefixStyle: const TextStyle(color: Color(0xFF6366F1)),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF6366F1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF6366F1)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRadioOption(String label, String value) {
    bool selected = _tipoPresupuesto == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _tipoPresupuesto = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF6366F1).withOpacity(0.2)
                : const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? const Color(0xFF6366F1)
                  : const Color(0xFF475569),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                size: 18,
                color: selected
                    ? const Color(0xFF6366F1)
                    : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _guardarTransaccion() {
    String categoriaFinal = '';

    // Validar nombre categoría
    if (_opcionSeleccionada == 0) {
      if (_categoriaExistenteSeleccionada == null ||
          _categoriaExistenteSeleccionada!.isEmpty) {
        _mostrarError('Selecciona una categoría existente');
        return;
      }
      categoriaFinal = _categoriaExistenteSeleccionada!;
    } else {
      if (_nombreManualController.text.trim().isEmpty) {
        _mostrarError('Escribe un nombre para la categoría');
        return;
      }
      categoriaFinal = _nombreManualController.text.trim();
    }

    // Validar Monto
    final monto = double.tryParse(_montoController.text);
    if (monto == null || monto <= 0) {
      _mostrarError('Ingresa un monto válido');
      return;
    }

    // Validar Presupuesto si está activo
    double? montoPresupuesto;
    if (_opcionSeleccionada == 1 && _agregarAPresupuesto) {
      montoPresupuesto = double.tryParse(_estimadoController.text);
      if (montoPresupuesto == null || montoPresupuesto <= 0) {
        _mostrarError('Ingresa un presupuesto estimado válido');
        return;
      }
    }

    // Enviar datos
    widget.onAdd(
      categoriaFinal,
      monto,
      _conceptoController.text.isEmpty
          ? 'Sin concepto'
          : _conceptoController.text,
      DateFormat('dd/MM/yyyy').format(_fechaSeleccionada),
      // Parámetros opcionales nuevos
      crearPresupuesto: (_opcionSeleccionada == 1 && _agregarAPresupuesto),
      tipoPresupuesto: _tipoPresupuesto,
      montoPresupuesto: montoPresupuesto,
      icon: _opcionSeleccionada == 1 ? _selectedIcon : null,
      color: _opcionSeleccionada == 1 ? _selectedColor : null,
    );

    Navigator.pop(context);
  }

  void _mostrarError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: const Color(0xFFEF4444)),
    );
  }
}
