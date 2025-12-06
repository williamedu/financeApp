// (Imports igual que el anterior...)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import './widgets/icon_category_picker_widget.dart';

// (Clase AddTransactionScreen y _AddTransactionScreenState IGUAL QUE ANTES)
// Copia todo el archivo anterior de add_transaction_screen que te di,
// pero en la función _buildTextField ELIMINA inputFormatters si existiera.
// Como en el código anterior que te di ya NO tenía inputFormatters,
// simplemente asegúrate de usar esa versión limpia.

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  List<String> _categoriasGastos = [];
  List<String> _categoriasIngresos = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _cargarCategorias();
  }

  Future<void> _cargarCategorias() async {
    final user = _authService.currentUser;
    if (user != null) {
      final data = await _firestoreService.loadUserData(user.uid);
      if (mounted) {
        setState(() {
          _categoriasIngresos = (data['ingresos'] as Map<String, dynamic>).keys
              .toList();
          final fijos = (data['gastosFijos'] as Map<String, dynamic>).keys
              .toList();
          final variables = (data['gastosVariables'] as Map<String, dynamic>)
              .keys
              .toList();
          _categoriasGastos = [...fijos, ...variables];
        });
      }
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
      backgroundColor: const Color(0xFF0F172A),
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
          isScrollable: true,
          indicatorColor: const Color(0xFF6366F1),
          labelColor: const Color(0xFF6366F1),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Gasto', icon: Icon(Icons.receipt_long)),
            Tab(text: 'Ingreso', icon: Icon(Icons.arrow_upward)),
            Tab(text: 'Fijo (Crear)', icon: Icon(Icons.lock_outline)),
            Tab(text: 'Variable (Crear)', icon: Icon(Icons.insights)),
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

  Future<void> _handleSave(Map<String, dynamic> data) async {
    setState(() => _isLoading = true);
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      final String formType = data['formType'];

      if (formType == 'expense') {
        if (data['isNewCategory'] == true) {
          await _firestoreService.addCategoriaPresupuesto(
            uid: user.uid,
            tipo: data['expenseType'],
            nombre: data['category'],
            presupuestado: data['budget'],
            iconCode: data['icon']?.codePoint,
            colorValue: data['color']?.value,
          );
        }
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
        await _firestoreService.updateCategoriaActual(
          uid: user.uid,
          categoria: data['category'],
          monto: data['amount'],
        );
      } else if (formType == 'income') {
        if (data['isNewCategory'] == true) {
          await _firestoreService.addIngreso(
            uid: user.uid,
            nombre: data['category'],
            estimado: data['amount'],
            actual: data['amount'],
            iconCode: data['icon']?.codePoint,
            colorValue: data['color']?.value,
          );
        } else {
          await _firestoreService.updateCategoriaActual(
            uid: user.uid,
            categoria: data['category'],
            monto: data['amount'],
          );
        }
        await _firestoreService.addTransaccion(
          uid: user.uid,
          categoria: data['category'],
          monto: data['amount'],
          concepto: data['description'],
          fecha: data['date'],
          type: 'income',
          iconCode: data['icon']?.codePoint,
          colorValue: data['color']?.value,
        );
      } else if (formType == 'fixed' || formType == 'variable') {
        await _firestoreService.addCategoriaPresupuesto(
          uid: user.uid,
          tipo: formType,
          nombre: data['category'],
          presupuestado: data['budget'],
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

class _TransactionForm extends StatefulWidget {
  final String type;
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
  final _budgetController = TextEditingController();
  final _descController = TextEditingController();
  String _newExpenseType = 'variable';
  IconData _icon = Icons.category;
  Color _color = Colors.blue;

  @override
  Widget build(BuildContext context) {
    final isExpense = widget.type == 'expense';

    return SingleChildScrollView(
      padding: EdgeInsets.all(5.w),
      child: Column(
        children: [
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

          if (!_isNewCategory) ...[
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
                    'Seleccionar Categoría...',
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
            _buildTextField(_nameController, 'Nombre Categoría', Icons.label),
            SizedBox(height: 2.h),
            _buildIconPicker(),

            if (isExpense) ...[
              SizedBox(height: 3.h),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tipo de Gasto (Obligatorio)',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        _buildRadioBtn('Variable', 'variable'),
                        SizedBox(width: 4.w),
                        _buildRadioBtn('Fijo', 'fixed'),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    _buildTextField(
                      _budgetController,
                      'Presupuesto Mensual Estimado',
                      Icons.calculate,
                      isNumber: true,
                    ),
                  ],
                ),
              ),
            ],
          ],

          SizedBox(height: 3.h),

          _buildTextField(
            _amountController,
            'Monto del Gasto (Hoy)',
            Icons.attach_money,
            isNumber: true,
          ),
          SizedBox(height: 2.h),
          _buildTextField(
            _descController,
            'Descripción (Opcional)',
            Icons.description,
          ),
          SizedBox(height: 4.h),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(_amountController.text);
                if (amount == null) {
                  Fluttertoast.showToast(msg: "Monto inválido");
                  return;
                }
                final category = _isNewCategory
                    ? _nameController.text
                    : _selectedCategory;
                if (category == null || category.isEmpty) {
                  Fluttertoast.showToast(msg: "Escribe un nombre de categoría");
                  return;
                }

                double? budget;
                if (_isNewCategory && isExpense) {
                  budget = double.tryParse(_budgetController.text);
                  if (budget == null) {
                    Fluttertoast.showToast(
                      msg: "Define el presupuesto estimado",
                    );
                    return;
                  }
                }

                widget.onSave({
                  'formType': widget.type,
                  'isNewCategory': _isNewCategory,
                  'expenseType': _newExpenseType,
                  'category': category,
                  'amount': amount,
                  'budget': budget ?? 0.0,
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
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

  Widget _buildRadioBtn(String label, String value) {
    final isSelected = _newExpenseType == value;
    return InkWell(
      onTap: () => setState(() => _newExpenseType = value),
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: isSelected ? const Color(0xFF6366F1) : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: isSelected ? Colors.white : Colors.grey),
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
            onSelected: (_, icon, color) => setState(() {
              _icon = icon;
              _color = color;
            }),
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
            const Text('Icono', style: TextStyle(color: Colors.white)),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
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
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
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

// FORMULARIO SIMPLE PARA CREAR CATEGORÍAS SIN GASTO
class _BudgetForm extends StatefulWidget {
  final String type;
  final Function(Map<String, dynamic>) onSave;
  const _BudgetForm({required this.type, required this.onSave});
  @override
  State<_BudgetForm> createState() => _BudgetFormState();
}

class _BudgetFormState extends State<_BudgetForm> {
  final _nameController = TextEditingController();
  final _budgetController = TextEditingController();
  IconData _icon = Icons.folder;
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
          _buildTextField(
            _nameController,
            'Nombre Categoría (Ej: Renta)',
            Icons.label,
          ),
          SizedBox(height: 2.h),
          _buildIconPicker(),
          SizedBox(height: 2.h),
          _buildTextField(
            _budgetController,
            'Presupuesto Estimado',
            Icons.calculate,
            isNumber: true,
          ),
          SizedBox(height: 4.h),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                final budget = double.tryParse(_budgetController.text);
                if (_nameController.text.isEmpty || budget == null) {
                  Fluttertoast.showToast(msg: "Completa los campos");
                  return;
                }
                widget.onSave({
                  'formType': widget.type,
                  'category': _nameController.text,
                  'budget': budget,
                  'amount': 0.0,
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
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
            onSelected: (_, icon, color) => setState(() {
              _icon = icon;
              _color = color;
            }),
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
            const Text('Icono', style: TextStyle(color: Colors.white)),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
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
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
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
