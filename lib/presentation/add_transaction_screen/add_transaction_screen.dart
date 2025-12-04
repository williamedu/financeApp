import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/advanced_options_widget.dart';
import './widgets/amount_input_widget.dart';
import './widgets/date_picker_widget.dart';
import './widgets/description_input_widget.dart';
import './widgets/entry_type_selector_widget.dart';
import './widgets/estimated_budget_input_widget.dart';
import './widgets/icon_category_picker_widget.dart';

/// Add Transaction Screen - Unified creation hub for all entry types
class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  // Form controllers
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _estimatedBudgetController =
      TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Form state
  String _selectedEntryType =
      'transaction'; // transaction, fixed_expense, variable_expense
  String? _selectedCategoryId;
  IconData? _selectedIcon;
  Color? _selectedColor;
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _estimatedBudgetController.dispose();
    _tagsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    if (_amountController.text.trim().isEmpty) {
      _showError('Por favor ingrese un monto');
      return false;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      _showError('Por favor ingrese un monto válido');
      return false;
    }

    if (_selectedCategoryId == null) {
      _showError('Por favor seleccione una categoría/icono');
      return false;
    }

    if (_descriptionController.text.trim().isEmpty) {
      _showError('Por favor ingrese una descripción');
      return false;
    }

    // Validate estimated budget for Fixed/Variable Expense
    if ((_selectedEntryType == 'fixed_expense' ||
        _selectedEntryType == 'variable_expense')) {
      if (_estimatedBudgetController.text.trim().isEmpty) {
        _showError('Por favor ingrese el presupuesto estimado');
        return false;
      }
      final estimatedBudget =
          double.tryParse(_estimatedBudgetController.text.trim());
      if (estimatedBudget == null || estimatedBudget <= 0) {
        _showError('Por favor ingrese un presupuesto válido');
        return false;
      }
    }

    return true;
  }

  void _showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.expenseRed,
      textColor: Colors.white,
      fontSize: 14.sp,
    );
  }

  void _showSuccess(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.successGreen,
      textColor: Colors.white,
      fontSize: 14.sp,
    );
  }

  Future<void> _saveTransaction() async {
    if (!_validateForm()) return;

    setState(() => _isSaving = true);

    try {
      await Future.delayed(Duration(milliseconds: 500));

      final transaction = {
        'amount': double.parse(_amountController.text.trim()),
        'entryType': _selectedEntryType,
        'categoryId': _selectedCategoryId,
        'categoryIcon': _selectedIcon.toString(),
        'categoryColor': _selectedColor?.value.toString(),
        'description': _descriptionController.text.trim(),
        'date': _selectedDate.toIso8601String(),
        'estimatedBudget': (_selectedEntryType == 'fixed_expense' ||
                _selectedEntryType == 'variable_expense')
            ? double.parse(_estimatedBudgetController.text.trim())
            : null,
        'tags': _tagsController.text.trim(),
        'notes': _notesController.text.trim(),
        'isRecurring': _isRecurring,
        'createdAt': DateTime.now().toIso8601String(),
      };

      HapticFeedback.mediumImpact();
      _showSuccess('Entrada guardada exitosamente');

      await Future.delayed(Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pop(context, transaction);
      }
    } catch (e) {
      _showError('Error al guardar la entrada');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showIconCategoryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => IconCategoryPickerWidget(
        onSelected: (categoryId, icon, color) {
          setState(() {
            _selectedCategoryId = categoryId;
            _selectedIcon = icon;
            _selectedColor = color;
          });
          HapticFeedback.selectionClick();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool showEstimatedBudget = _selectedEntryType == 'fixed_expense' ||
        _selectedEntryType == 'variable_expense';

    return Scaffold(
      backgroundColor: AppTheme.primaryBackgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBackgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Nueva Entrada',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_isSaving)
            Center(
              child: Padding(
                padding: EdgeInsets.only(right: 4.w),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppTheme.incomeGold),
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveTransaction,
              child: Text(
                'Guardar',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.incomeGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Entry Type Selector
              EntryTypeSelectorWidget(
                selectedType: _selectedEntryType,
                onTypeChanged: (type) {
                  setState(() {
                    _selectedEntryType = type;
                    // Clear estimated budget when switching to transaction
                    if (type == 'transaction') {
                      _estimatedBudgetController.clear();
                    }
                  });
                  HapticFeedback.selectionClick();
                },
              ),
              SizedBox(height: 3.h),

              // Amount input
              AmountInputWidget(
                controller: _amountController,
                isIncome: false,
                onTypeChanged: (value) {},
              ),
              SizedBox(height: 3.h),

              // Description input
              DescriptionInputWidget(
                controller: _descriptionController,
                onVoiceInput: () {},
              ),
              SizedBox(height: 3.h),

              // Date picker
              DatePickerWidget(
                selectedDate: _selectedDate,
                onDateSelected: (date) {
                  setState(() => _selectedDate = date);
                  HapticFeedback.selectionClick();
                },
              ),
              SizedBox(height: 3.h),

              // Icon/Category selector button
              InkWell(
                onTap: _showIconCategoryPicker,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedCategoryId != null
                          ? AppTheme.incomeGold
                          : AppTheme.borderSubtle,
                      width: _selectedCategoryId != null ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      if (_selectedIcon != null && _selectedColor != null)
                        Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: _selectedColor!.withAlpha(51),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(_selectedIcon,
                              color: _selectedColor, size: 24),
                        )
                      else
                        Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: AppTheme.borderSubtle,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.category,
                              color: AppTheme.textSecondary, size: 24),
                        ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          _selectedCategoryId != null
                              ? 'Categoría: $_selectedCategoryId'
                              : 'Seleccionar Categoría/Icono',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: _selectedCategoryId != null
                                ? theme.colorScheme.onSurface
                                : AppTheme.textSecondary,
                            fontWeight: _selectedCategoryId != null
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_right,
                          color: AppTheme.textSecondary),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 3.h),

              // Conditional Estimated Budget field
              if (showEstimatedBudget) ...[
                EstimatedBudgetInputWidget(
                  controller: _estimatedBudgetController,
                ),
                SizedBox(height: 3.h),
              ],

              // Advanced options
              AdvancedOptionsWidget(
                tagsController: _tagsController,
                notesController: _notesController,
                isRecurring: _isRecurring,
                onRecurringChanged: (value) {
                  setState(() => _isRecurring = value);
                  HapticFeedback.selectionClick();
                },
              ),
              SizedBox(height: 4.h),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.expenseRed,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isSaving
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Guardar Entrada',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}
