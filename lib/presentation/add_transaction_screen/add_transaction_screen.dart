import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import './widgets/icon_category_picker_widget.dart'; // Asegúrate de tener este widget del paso anterior

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // Servicios
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  // Listas de categorías cargadas de Firebase
  List<String> _categoriasGastos = [];
  List<String> _categoriasIngresos = [];

  @override
  void initState() {
    super.initState();
    // 4 Pestañas: Gasto (Transacción), Ingreso, Fijo, Variable
    _tabController = TabController(length: 4, vsync: this);
    _cargarCategorias();
  }

  Future<void> _cargarCategorias() async {
    final user = _authService.currentUser;
    if (user != null) {
      final data = await _firestoreService.loadUserData(user.uid);
      setState(() {
        // Extraemos nombres de las llaves de los mapas
        _categoriasIngresos = (data['ingresos'] as Map<String, dynamic>).keys
            .toList();

        // Unimos fijos y variables para la lista de gastos generales
        final fijos = (data['gastosFijos'] as Map<String, dynamic>).keys
            .toList();
        final variables = (data['gastosVariables'] as Map<String, dynamic>).keys
            .toList();
        _categoriasGastos = [...fijos, ...variables];
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Fondo oscuro principal
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nueva Entrada',
          style: TextStyle(color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true, // Permite scroll si la pantalla es pequeña
          indicatorColor: const Color(0xFF6366F1),
          labelColor: const Color(0xFF6366F1),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Gasto', icon: Icon(Icons.receipt_long)),
            Tab(text: 'Ingreso', icon: Icon(Icons.arrow_upward)),
            Tab(text: 'Fijo', icon: Icon(Icons.lock_outline)),
            Tab(text: 'Variable', icon: Icon(Icons.insights)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _TransactionForm(
                  type: 'expense',
                  existingCategories: _categoriasGastos,
                  onSave: _handleSave,
                ),
                _TransactionForm(
                  type: 'income',
                  existingCategories: _categoriasIngresos,
                  onSave: _handleSave,
                ),
                _BudgetForm(type: 'fixed', onSave: _handleSave),
                _BudgetForm(type: 'variable', onSave: _handleSave),
              ],
            ),
    );
  }

  // Lógica Centralizada de Guardado
  Future<void> _handleSave(Map<String, dynamic> data) async {
    setState(() => _isLoading = true);
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      final String formType =
          data['formType']; // expense, income, fixed, variable

      // 1. GASTO COMÚN (Transacción)
      if (formType == 'expense') {
        await _firestoreService.addTransaccion(
          uid: user.uid,
          categoria: data['category'],
          monto: data['amount'],
          concepto: data['description'],
          fecha: data['date'],
          type: 'expense', // Clave para el Dashboard
          iconCode: data['icon']?.codePoint,
          colorValue: data['color']?.value,
        );
        // Actualizar acumulado si existe
        await _firestoreService.updateCategoriaActual(
          uid: user.uid,
          categoria: data['category'],
          monto: data['amount'],
        );
      }
      // 2. INGRESO
      else if (formType == 'income') {
        // Si es nuevo, creamos la categoría de ingreso
        if (data['isNewCategory'] == true) {
          await _firestoreService.addIngreso(
            uid: user.uid,
            nombre: data['category'],
            estimado: data['amount'], // Asumimos estimado = primer monto
            actual: data['amount'],
          );
        } else {
          // Si ya existe, solo sumamos al actual (debes implementar updateIngresoActual si quieres, por ahora solo log)
        }

        // Guardamos Log en Transacciones
        await _firestoreService.addTransaccion(
          uid: user.uid,
          categoria: data['category'],
          monto: data['amount'],
          concepto: data['description'],
          fecha: data['date'],
          type: 'income', // Clave para el Dashboard
          iconCode: data['icon']?.codePoint,
          colorValue: data['color']?.value,
        );
      }
      // 3. PRESUPUESTO FIJO
      else if (formType == 'fixed') {
        await _firestoreService.addGastoFijo(
          uid: user.uid,
          nombre: data['category'],
          presupuestado: data['budget'],
          actual: data['amount'],
          iconCode: data['icon']?.codePoint,
          colorValue: data['color']?.value,
        );
        // Log en historial
        await _firestoreService.addTransaccion(
          uid: user.uid,
          categoria: data['category'],
          monto: data['amount'],
          concepto: data['description'],
          fecha: data['date'],
          type: 'expense',
          iconCode: data['icon']?.codePoint,
          colorValue: data['color']?.value,
        );
      }
      // 4. PRESUPUESTO VARIABLE
      else if (formType == 'variable') {
        await _firestoreService.addGastoVariable(
          uid: user.uid,
          nombre: data['category'],
          presupuestado: data['budget'],
          actual: data['amount'],
          iconCode: data['icon']?.codePoint,
          colorValue: data['color']?.value,
        );
        // Log en historial
        await _firestoreService.addTransaccion(
          uid: user.uid,
          categoria: data['category'],
          monto: data['amount'],
          concepto: data['description'],
          fecha: data['date'],
          type: 'expense',
          iconCode: data['icon']?.codePoint,
          colorValue: data['color']?.value,
        );
      }

      if (mounted) {
        Fluttertoast.showToast(
          msg: "Guardado exitosamente",
          backgroundColor: Colors.green,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(msg: "Error: $e", backgroundColor: Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

// ---------------------------------------------------------------------------
// FORMULARIO 1: TRANSACCIONES E INGRESOS (Con toggle Existente/Nuevo)
// ---------------------------------------------------------------------------
class _TransactionForm extends StatefulWidget {
  final String type; // 'expense' or 'income'
  final List<String> existingCategories;
  final Function(Map<String, dynamic>) onSave;

  const _TransactionForm({
    required this.type,
    required this.existingCategories,
    required this.onSave,
  });

  @override
  State<_TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<_TransactionForm> {
  bool _isNewCategory = false;
  String? _selectedCategory;
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();

  // Icono/Color por defecto
  IconData _icon = Icons.category;
  Color _color = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Selector Existente vs Nuevo
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildToggleBtn(
                  'Existente',
                  !_isNewCategory,
                  () => setState(() => _isNewCategory = false),
                ),
                _buildToggleBtn(
                  'Nuevo',
                  _isNewCategory,
                  () => setState(() => _isNewCategory = true),
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),

          // 2. Selección de Categoría
          if (!_isNewCategory) ...[
            const Text(
              'Selecciona Categoría',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 1.h),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  hint: const Text(
                    'Seleccionar...',
                    style: TextStyle(color: Colors.white),
                  ),
                  dropdownColor: const Color(0xFF1E293B),
                  isExpanded: true,
                  items: widget.existingCategories.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val),
                ),
              ),
            ),
          ] else ...[
            // Crear Nueva Categoría
            _buildTextField(
              controller: _nameController,
              label: 'Nombre de Categoría',
              icon: Icons.label,
            ),
            SizedBox(height: 2.h),
            _buildIconPicker(),
          ],

          SizedBox(height: 3.h),

          // 3. Monto y Descripción
          _buildTextField(
            controller: _amountController,
            label: 'Monto (RD\$)',
            icon: Icons.attach_money,
            isNumber: true,
          ),
          SizedBox(height: 2.h),
          _buildTextField(
            controller: _descController,
            label: 'Descripción (Opcional)',
            icon: Icons.description,
          ),

          SizedBox(height: 4.h),

          // 4. Botón Guardar
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                // Validaciones
                final amount = double.tryParse(_amountController.text);
                if (amount == null) {
                  Fluttertoast.showToast(msg: "Ingresa un monto válido");
                  return;
                }

                final categoryName = _isNewCategory
                    ? _nameController.text
                    : _selectedCategory;
                if (categoryName == null || categoryName.isEmpty) {
                  Fluttertoast.showToast(
                    msg: "Selecciona o escribe una categoría",
                  );
                  return;
                }

                widget.onSave({
                  'formType': widget.type,
                  'isNewCategory': _isNewCategory,
                  'category': categoryName,
                  'amount': amount,
                  'description': _descController.text.isEmpty
                      ? 'Sin descripción'
                      : _descController.text,
                  'date': DateTime.now().toIso8601String(),
                  'icon': _icon,
                  'color': _color,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.type == 'income'
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Guardar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleBtn(String text, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF6366F1).withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: const Color(0xFF6366F1))
                : null,
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? const Color(0xFF6366F1) : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconPicker() {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => IconCategoryPickerWidget(
            onSelected: (catId, icon, color) {
              setState(() {
                _icon = icon;
                _color = color;
              });
            },
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _color),
        ),
        child: Row(
          children: [
            Icon(_icon, color: _color),
            const SizedBox(width: 10),
            const Text(
              'Seleccionar Icono',
              style: TextStyle(color: Colors.white),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// FORMULARIO 2: PRESUPUESTOS (FIJO / VARIABLE)
// ---------------------------------------------------------------------------
class _BudgetForm extends StatefulWidget {
  final String type; // 'fixed' or 'variable'
  final Function(Map<String, dynamic>) onSave;

  const _BudgetForm({required this.type, required this.onSave});

  @override
  State<_BudgetForm> createState() => _BudgetFormState();
}

class _BudgetFormState extends State<_BudgetForm> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _budgetController = TextEditingController();

  IconData _icon = Icons.home;
  Color _color = Colors.orange;

  @override
  Widget build(BuildContext context) {
    final colorTema = widget.type == 'fixed'
        ? const Color(0xFFF59E0B)
        : const Color(0xFF3B82F6);

    return SingleChildScrollView(
      padding: EdgeInsets.all(5.w),
      child: Column(
        children: [
          _buildTextField(_nameController, 'Nombre del Gasto', Icons.label),
          SizedBox(height: 2.h),
          _buildIconPicker(),
          SizedBox(height: 2.h),
          _buildTextField(
            _budgetController,
            'Presupuesto Estimado',
            Icons.calculate,
            isNumber: true,
          ),
          SizedBox(height: 2.h),
          _buildTextField(
            _amountController,
            'Gasto Real (Actual)',
            Icons.attach_money,
            isNumber: true,
          ),

          SizedBox(height: 4.h),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                final budget = double.tryParse(_budgetController.text);
                final amount = double.tryParse(_amountController.text);

                if (_nameController.text.isEmpty ||
                    budget == null ||
                    amount == null) {
                  Fluttertoast.showToast(msg: "Completa todos los campos");
                  return;
                }

                widget.onSave({
                  'formType': widget.type,
                  'category': _nameController.text,
                  'budget': budget,
                  'amount': amount,
                  'description': 'Pago mensual de ${_nameController.text}',
                  'date': DateTime.now().toIso8601String(),
                  'icon': _icon,
                  'color': _color,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorTema,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Crear Categoría',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconPicker() {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => IconCategoryPickerWidget(
            onSelected: (catId, icon, color) {
              setState(() {
                _icon = icon;
                _color = color;
              });
            },
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _color),
        ),
        child: Row(
          children: [
            Icon(_icon, color: _color),
            const SizedBox(width: 10),
            const Text(
              'Seleccionar Icono',
              style: TextStyle(color: Colors.white),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
