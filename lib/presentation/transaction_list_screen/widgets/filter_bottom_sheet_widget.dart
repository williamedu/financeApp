import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final List<Map<String, dynamic>> availableCategories;
  final List<Map<String, dynamic>>
  allTransactions; // <--- NUEVO: Lista para contar
  final Function(Map<String, dynamic>) onApplyFilters;

  const FilterBottomSheetWidget({
    super.key,
    required this.currentFilters,
    required this.availableCategories,
    required this.allTransactions, // <--- REQUERIDO
    required this.onApplyFilters,
  });

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  // Filtros
  String _selectedType = 'Todos';
  String _selectedSort = 'Más reciente';
  String _selectedDatePreset = 'Este Mes';
  RangeValues _amountRange = const RangeValues(0, 100000);
  List<String> _selectedCategories = [];

  bool _showAllCategories = false;

  final List<String> _datePresets = [
    'Hoy',
    'Ayer',
    'Últimos 7 días',
    'Últimos 15 días',
    'Últimos 30 días',
    'Este Mes',
    'Mes Pasado',
    'Este Año',
    'Personalizado',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.currentFilters['type'] != null)
      _selectedType = widget.currentFilters['type'];
    if (widget.currentFilters['sort'] != null)
      _selectedSort = widget.currentFilters['sort'];
    if (widget.currentFilters['datePreset'] != null)
      _selectedDatePreset = widget.currentFilters['datePreset'];
    if (widget.currentFilters['categories'] != null)
      _selectedCategories = List<String>.from(
        widget.currentFilters['categories'],
      );
    if (widget.currentFilters['minAmount'] != null &&
        widget.currentFilters['maxAmount'] != null) {
      _amountRange = RangeValues(
        widget.currentFilters['minAmount'],
        widget.currentFilters['maxAmount'],
      );
    }
  }

  // --- LÓGICA DE CONTEO EN TIEMPO REAL ---
  int get _filteredCount {
    return widget.allTransactions.where((t) {
      // 1. Tipo
      if (_selectedType != 'Todos') {
        final type = t['type'] == 'income' ? 'Ingreso' : 'Gasto';
        if (type != _selectedType) return false;
      }

      // 2. Categorías
      if (_selectedCategories.isNotEmpty) {
        if (!_selectedCategories.contains(t['category'])) return false;
      }

      // 3. Monto
      final amount = t['amount'] as double;
      if (amount < _amountRange.start || amount > _amountRange.end)
        return false;

      // 4. Fechas (Misma lógica que en la lista)
      if (_selectedDatePreset != 'Personalizado') {
        // Ignoramos personalizado por ahora para el conteo rápido
        final date = t['date'] as DateTime;
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final itemDate = DateTime(date.year, date.month, date.day);

        switch (_selectedDatePreset) {
          case 'Hoy':
            if (itemDate != today) return false;
            break;
          case 'Ayer':
            if (itemDate != today.subtract(const Duration(days: 1)))
              return false;
            break;
          case 'Últimos 7 días':
            if (date.isBefore(now.subtract(const Duration(days: 7))))
              return false;
            break;
          case 'Últimos 15 días':
            if (date.isBefore(now.subtract(const Duration(days: 15))))
              return false;
            break;
          case 'Últimos 30 días':
            if (date.isBefore(now.subtract(const Duration(days: 30))))
              return false;
            break;
          case 'Este Mes':
            if (date.month != now.month || date.year != now.year) return false;
            break;
          case 'Mes Pasado':
            final lastMonth = DateTime(now.year, now.month - 1, 1);
            if (date.month != lastMonth.month || date.year != lastMonth.year)
              return false;
            break;
          case 'Este Año':
            if (date.year != now.year) return false;
            break;
        }
      }

      return true;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final initialCategoryCount = 8;
    final categoriesToShow = _showAllCategories
        ? widget.availableCategories
        : widget.availableCategories.take(initialCategoryCount).toList();

    // Calculamos el número mágico
    final count = _filteredCount;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filtrar por',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text(
                    'Limpiar todo',
                    style: TextStyle(color: Color(0xFF6366F1)),
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Color(0xFF334155), height: 1),

          Expanded(
            child: ListView(
              padding: EdgeInsets.all(5.w),
              children: [
                _buildSectionTitle('Tipo'),
                Row(
                  children: [
                    _buildTypeChip('Todos'),
                    SizedBox(width: 3.w),
                    _buildTypeChip('Ingreso'),
                    SizedBox(width: 3.w),
                    _buildTypeChip('Gasto'),
                  ],
                ),
                SizedBox(height: 3.h),

                _buildSectionTitle('Ordenar por'),
                Wrap(
                  spacing: 3.w,
                  runSpacing: 1.5.h,
                  children: [
                    _buildSortChip('Más reciente'),
                    _buildSortChip('Más antiguo'),
                    _buildSortChip('Mayor monto'),
                    _buildSortChip('Menor monto'),
                  ],
                ),
                SizedBox(height: 3.h),

                _buildSectionTitle('Fecha'),
                Wrap(
                  spacing: 2.w,
                  runSpacing: 1.5.h,
                  children: _datePresets
                      .map((preset) => _buildDateChip(preset))
                      .toList(),
                ),
                SizedBox(height: 3.h),

                _buildSectionTitle('Categorías'),
                if (widget.availableCategories.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "No hay categorías.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: categoriesToShow.length,
                    itemBuilder: (context, index) {
                      final cat = categoriesToShow[index];
                      final isSelected = _selectedCategories.contains(
                        cat['name'],
                      );
                      final Color catColor = cat['color'] != null
                          ? Color(cat['color'])
                          : Colors.blue;
                      final IconData catIcon = cat['icon'] != null
                          ? IconData(cat['icon'], fontFamily: 'MaterialIcons')
                          : Icons.category;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected)
                              _selectedCategories.remove(cat['name']);
                            else
                              _selectedCategories.add(cat['name']);
                          });
                        },
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? catColor.withOpacity(0.2)
                                    : const Color(0xFF0F172A),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? catColor
                                      : catColor.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                catIcon,
                                color: isSelected
                                    ? catColor
                                    : catColor.withOpacity(0.5),
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              cat['name'],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey,
                                fontSize: 10,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                if (widget.availableCategories.length > initialCategoryCount)
                  TextButton(
                    onPressed: () => setState(
                      () => _showAllCategories = !_showAllCategories,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _showAllCategories
                              ? 'Ver menos'
                              : 'Ver todas (${widget.availableCategories.length})',
                          style: const TextStyle(color: Color(0xFF6366F1)),
                        ),
                        Icon(
                          _showAllCategories
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: const Color(0xFF6366F1),
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: 3.h),

                _buildSectionTitle('Rango de Monto'),
                RangeSlider(
                  values: _amountRange,
                  min: 0,
                  max: 100000,
                  divisions: 100,
                  activeColor: const Color(0xFF6366F1),
                  inactiveColor: const Color(0xFF334155),
                  labels: RangeLabels(
                    '\$${_amountRange.start.toStringAsFixed(0)}',
                    '\$${_amountRange.end.toStringAsFixed(0)}',
                  ),
                  onChanged: (values) => setState(() => _amountRange = values),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${_amountRange.start.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    Text(
                      '\$${_amountRange.end.toStringAsFixed(0)}+',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),

                SizedBox(height: 5.h),
              ],
            ),
          ),

          // BOTÓN MÁGICO CON CONTADOR
          Container(
            padding: EdgeInsets.all(5.w),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF334155))),
              color: Color(0xFF1E293B),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: count > 0
                    ? _applyFilters
                    : null, // Desactivar si es 0 (opcional)
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  disabledBackgroundColor: const Color(0xFF334155),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  count > 0 ? 'Ver ($count) Resultados' : 'Sin resultados',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: count > 0 ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ... (Widgets auxiliares _buildSectionTitle, _buildTypeChip, etc. se mantienen igual) ...
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label) {
    final isSelected = _selectedType == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF6366F1)
                : const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF6366F1)
                  : const Color(0xFF334155),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip(String label) {
    final isSelected = _selectedSort == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedSort = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6366F1).withOpacity(0.2)
              : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6366F1)
                : const Color(0xFF334155),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF6366F1) : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildDateChip(String label) {
    final isSelected = _selectedDatePreset == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedDatePreset = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF10B981).withOpacity(0.2)
              : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF10B981)
                : const Color(0xFF334155),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF10B981) : Colors.grey,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedType = 'Todos';
      _selectedSort = 'Más reciente';
      _selectedDatePreset = 'Este Mes';
      _selectedCategories.clear();
      _amountRange = const RangeValues(0, 100000);
    });
  }

  void _applyFilters() {
    final filters = {
      'type': _selectedType,
      'sort': _selectedSort,
      'datePreset': _selectedDatePreset,
      'categories': _selectedCategories,
      'minAmount': _amountRange.start,
      'maxAmount': _amountRange.end,
    };
    widget.onApplyFilters(filters);
    Navigator.pop(context);
  }
}
