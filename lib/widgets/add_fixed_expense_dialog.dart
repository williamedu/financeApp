import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AddFixedExpenseDialog extends StatefulWidget {
  final List<String> categoriasExistentes;
  final Function(String nombre, double presupuestado, double actual) onAdd;

  const AddFixedExpenseDialog({
    super.key,
    required this.categoriasExistentes,
    required this.onAdd,
  });

  @override
  State<AddFixedExpenseDialog> createState() => _AddFixedExpenseDialogState();
}

class _AddFixedExpenseDialogState extends State<AddFixedExpenseDialog> {
  int opcionSeleccionada = 0; // 0 = Existente, 1 = Manual
  String? categoriaExistenteSeleccionada;

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController presupuestadoController = TextEditingController();
  final TextEditingController actualController = TextEditingController();

  String formatearMoneda(double valor) {
    final formatoDominicano = NumberFormat.currency(
      locale: 'es_DO',
      symbol: '',
      decimalDigits: 2,
    );
    return 'RD\$ ${formatoDominicano.format(valor).trim()}';
  }

  @override
  void dispose() {
    nombreController.dispose();
    presupuestadoController.dispose();
    actualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF78350F),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add_circle_outline_rounded,
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
                        'Agregar Gasto Fijo',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF1F5F9),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Crea una nueva categoría o selecciona una existente',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF94A3B8),
                        ),
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
            ),

            const SizedBox(height: 24),

            // Selector de opción (Existente o Manual)
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

            // Contenido según opción seleccionada
            Expanded(
              child: SingleChildScrollView(
                child: opcionSeleccionada == 0
                    ? _buildExistenteForm()
                    : _buildManualForm(),
              ),
            ),

            const SizedBox(height: 24),

            // Botones de acción
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF94A3B8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _guardarGasto,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
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
                    'Guardar',
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

  Widget _buildOptionButton(String label, IconData icon, int valor) {
    bool isSelected = opcionSeleccionada == valor;
    return GestureDetector(
      onTap: () => setState(() => opcionSeleccionada = valor),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF475569) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? const Color(0xFFF59E0B)
                  : const Color(0xFF64748B),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFFF1F5F9)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExistenteForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecciona una categoría existente',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: categoriaExistenteSeleccionada,
          dropdownColor: const Color(0xFF334155),
          style: const TextStyle(color: Color(0xFFF1F5F9)),
          decoration: InputDecoration(
            hintText: 'Selecciona...',
            hintStyle: const TextStyle(color: Color(0xFF64748B)),
            prefixIcon: const Icon(
              Icons.category_outlined,
              color: Color(0xFF94A3B8),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF475569)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF475569)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 2),
            ),
            filled: true,
            fillColor: const Color(0xFF334155),
          ),
          items: widget.categoriasExistentes.map((categoria) {
            return DropdownMenuItem(value: categoria, child: Text(categoria));
          }).toList(),
          onChanged: (value) {
            setState(() {
              categoriaExistenteSeleccionada = value;
            });
          },
        ),

        const SizedBox(height: 24),

        const Text(
          'Monto Presupuestado',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: presupuestadoController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(color: Color(0xFFF1F5F9)),
          decoration: InputDecoration(
            hintText: '0.00',
            hintStyle: const TextStyle(color: Color(0xFF64748B)),
            prefixText: 'RD\$ ',
            prefixStyle: const TextStyle(color: Color(0xFFF1F5F9)),
            prefixIcon: const Icon(
              Icons.account_balance_wallet_outlined,
              color: Color(0xFF94A3B8),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF475569)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 2),
            ),
            filled: true,
            fillColor: const Color(0xFF334155),
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          'Monto Actual',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: actualController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(color: Color(0xFFF1F5F9)),
          decoration: InputDecoration(
            hintText: '0.00',
            hintStyle: const TextStyle(color: Color(0xFF64748B)),
            prefixText: 'RD\$ ',
            prefixStyle: const TextStyle(color: Color(0xFFF1F5F9)),
            prefixIcon: const Icon(
              Icons.payments_outlined,
              color: Color(0xFF94A3B8),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF475569)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 2),
            ),
            filled: true,
            fillColor: const Color(0xFF334155),
          ),
        ),
      ],
    );
  }

  Widget _buildManualForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nombre de la Categoría',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: nombreController,
          style: const TextStyle(color: Color(0xFFF1F5F9)),
          decoration: InputDecoration(
            hintText: 'Ej: Renta, Internet, Electricidad...',
            hintStyle: const TextStyle(color: Color(0xFF64748B)),
            prefixIcon: const Icon(
              Icons.label_outline_rounded,
              color: Color(0xFF94A3B8),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF475569)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 2),
            ),
            filled: true,
            fillColor: const Color(0xFF334155),
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          'Monto Presupuestado',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: presupuestadoController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(color: Color(0xFFF1F5F9)),
          decoration: InputDecoration(
            hintText: '0.00',
            hintStyle: const TextStyle(color: Color(0xFF64748B)),
            prefixText: 'RD\$ ',
            prefixStyle: const TextStyle(color: Color(0xFFF1F5F9)),
            prefixIcon: const Icon(
              Icons.account_balance_wallet_outlined,
              color: Color(0xFF94A3B8),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF475569)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 2),
            ),
            filled: true,
            fillColor: const Color(0xFF334155),
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          'Monto Actual',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: actualController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(color: Color(0xFFF1F5F9)),
          decoration: InputDecoration(
            hintText: '0.00',
            hintStyle: const TextStyle(color: Color(0xFF64748B)),
            prefixText: 'RD\$ ',
            prefixStyle: const TextStyle(color: Color(0xFFF1F5F9)),
            prefixIcon: const Icon(
              Icons.payments_outlined,
              color: Color(0xFF94A3B8),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF475569)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 2),
            ),
            filled: true,
            fillColor: const Color(0xFF334155),
          ),
        ),
      ],
    );
  }

  void _guardarGasto() {
    String nombre = '';
    double presupuestado = 0.0;
    double actual = 0.0;

    if (opcionSeleccionada == 0) {
      // Usar existente
      if (categoriaExistenteSeleccionada == null ||
          categoriaExistenteSeleccionada!.isEmpty) {
        _mostrarError('Por favor selecciona una categoría existente');
        return;
      }
      nombre = categoriaExistenteSeleccionada!;
    } else {
      // Manual
      if (nombreController.text.trim().isEmpty) {
        _mostrarError('Por favor ingresa un nombre');
        return;
      }
      nombre = nombreController.text.trim();
    }

    // Parsear montos
    try {
      if (presupuestadoController.text.isNotEmpty) {
        presupuestado = double.parse(presupuestadoController.text);
      }
      if (actualController.text.isNotEmpty) {
        actual = double.parse(actualController.text);
      }
    } catch (e) {
      _mostrarError('Por favor ingresa montos válidos');
      return;
    }

    // Llamar callback y cerrar
    widget.onAdd(nombre, presupuestado, actual);
    Navigator.pop(context);
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: const Color(0xFFEF4444),
      ),
    );
  }
}
