import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/add_income_dialog.dart';

class IncomeDetailsPage extends StatefulWidget {
  final Map<String, Map<String, dynamic>> ingresos;

  final int mesActual;
  final int anioActual;

  const IncomeDetailsPage({
    super.key,
    required this.ingresos,
    required this.mesActual,
    required this.anioActual,
  });

  @override
  State<IncomeDetailsPage> createState() => _IncomeDetailsPageState();
}

class _IncomeDetailsPageState extends State<IncomeDetailsPage> {
  late Map<String, Map<String, double>> ingresosLocales;

  @override
  void initState() {
    super.initState();
    // Crear copia local de los ingresos
    ingresosLocales = Map.from(widget.ingresos);
  }

  String formatearMoneda(double valor) {
    final formatoDominicano = NumberFormat.currency(
      locale: 'es_DO',
      symbol: 'RD\$',
      decimalDigits: 2,
    );
    return formatoDominicano.format(valor);
  }

  double calcularTotal(String tipo) {
    double total = 0;
    ingresosLocales.forEach((key, value) {
      total += value[tipo] ?? 0;
    });
    return total;
  }

  void _mostrarDialogoAgregar() {
    showDialog(
      context: context,
      builder: (context) => AddIncomeDialog(
        incomesExistentes: ingresosLocales.keys.toList(),
        onAdd: (nombre, estimado, actual) {
          setState(() {
            // Generar nombre único si ya existe
            String nombreFinal = nombre;
            int contador = 2;
            while (ingresosLocales.containsKey(nombreFinal)) {
              nombreFinal = '$nombre $contador';
              contador++;
            }

            ingresosLocales[nombreFinal] = {
              'estimado': estimado,
              'actual': actual,
            };
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fuente de ingreso agregada exitosamente'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        },
      ),
    );
  }

  void _mostrarDialogoEditar(String nombre, double estimado, double actual) {
    final estimadoController = TextEditingController(
      text: estimado.toInt().toString(),
    );
    final actualController = TextEditingController(
      text: actual.toInt().toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF064E3B),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: Color(0xFF10B981),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Editar $nombre',
                style: const TextStyle(fontSize: 18, color: Color(0xFFF1F5F9)),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Monto Estimado',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: estimadoController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Color(0xFFF1F5F9)),
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: const TextStyle(color: Color(0xFF64748B)),
                  prefixText: 'RD\$ ',
                  prefixStyle: const TextStyle(color: Color(0xFFF1F5F9)),
                  filled: true,
                  fillColor: const Color(0xFF334155),
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
                    borderSide: const BorderSide(
                      color: Color(0xFF10B981),
                      width: 2,
                    ),
                  ),
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
                style: const TextStyle(color: Color(0xFFF1F5F9)),
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: const TextStyle(color: Color(0xFF64748B)),
                  prefixText: 'RD\$ ',
                  prefixStyle: const TextStyle(color: Color(0xFFF1F5F9)),
                  filled: true,
                  fillColor: const Color(0xFF334155),
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
                    borderSide: const BorderSide(
                      color: Color(0xFF10B981),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Botón Eliminar (a la izquierda)
          TextButton.icon(
            onPressed: () {
              // Confirmar eliminación
              showDialog(
                context: context,
                builder: (confirmContext) => AlertDialog(
                  backgroundColor: const Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Row(
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        color: Color(0xFFEF4444),
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Confirmar Eliminación',
                        style: TextStyle(color: Color(0xFFF1F5F9)),
                      ),
                    ],
                  ),
                  content: Text(
                    '¿Estás seguro de que deseas eliminar "$nombre"?',
                    style: const TextStyle(color: Color(0xFF94A3B8)),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(confirmContext),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Color(0xFF94A3B8)),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          ingresosLocales.remove(nombre);
                        });
                        Navigator.pop(confirmContext); // Cerrar confirmación
                        Navigator.pop(context); // Cerrar diálogo de edición
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ingreso eliminado exitosamente'),
                            backgroundColor: Color(0xFFEF4444),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Eliminar'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text('Eliminar'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
            ),
          ),

          const Spacer(),

          // Botones Cancelar y Guardar (a la derecha)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF94A3B8)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                ingresosLocales[nombre] = {
                  'estimado':
                      double.tryParse(estimadoController.text) ?? estimado,
                  'actual': double.tryParse(actualController.text) ?? actual,
                };
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ingreso actualizado exitosamente'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalEstimado = calcularTotal('estimado');
    double totalActual = calcularTotal('actual');
    double diferencia = totalActual - totalEstimado;
    double porcentaje = totalEstimado > 0
        ? (totalActual / totalEstimado) * 100
        : 0;

    final nombresMeses = [
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

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF10B981).withOpacity(0.5),
                  width: 2,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: SafeArea(
              child: Row(
                children: [
                  // Botón de regreso
                  IconButton(
                    onPressed: () => Navigator.pop(context, ingresosLocales),
                    icon: const Icon(Icons.arrow_back_rounded),
                    iconSize: 24,
                    color: const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 16),

                  // Título
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detalles de Ingresos',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF1F5F9),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Desglose detallado de todas tus fuentes de ingresos para este mes',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Mes/Año
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF334155),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF475569)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_outlined,
                          size: 18,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${nombresMeses[widget.mesActual - 1]} / ${widget.anioActual}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFF1F5F9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contenido
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumen de Ingresos
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF10B981),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF064E3B),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.trending_up_rounded,
                                color: Color(0xFF10B981),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Resumen de Ingresos',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF1F5F9),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // 3 Tarjetas
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                'Total Estimado',
                                totalEstimado,
                                const Color(0xFF6366F1),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildSummaryCard(
                                'Total Actual',
                                totalActual,
                                const Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildSummaryCard(
                                'Diferencia',
                                diferencia,
                                diferencia >= 0
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Barra de progreso
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Logro de Ingresos',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFF1F5F9),
                                  ),
                                ),
                                Text(
                                  '${porcentaje.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6366F1),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: porcentaje / 100,
                                minHeight: 10,
                                backgroundColor: const Color(0xFF334155),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF6366F1),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Has alcanzado el ${porcentaje.toStringAsFixed(1)}% de tus ingresos estimados',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Fuentes de Ingresos
                  const Text(
                    'Fuentes de Ingresos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF1F5F9),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Grid de fuentes
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 3,
                        ),
                    itemCount: ingresosLocales.length,
                    itemBuilder: (context, index) {
                      final entry = ingresosLocales.entries.elementAt(index);
                      return _buildIncomeSourceCard(
                        entry.key,
                        entry.value['actual'] ?? 0,
                        entry.value['estimado'] ?? 0,
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Botón agregar nueva categoría
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _mostrarDialogoAgregar,
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text('Agregar Nueva Categoría de Ingreso'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, double valor, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatearMoneda(valor),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeSourceCard(String nombre, double actual, double estimado) {
    double porcentaje = estimado > 0 ? (actual / estimado) * 100 : 0;
    bool exceeded = actual > estimado;

    IconData icono;
    Color colorIcono;

    switch (nombre.toLowerCase()) {
      case 'salario fijo':
        icono = Icons.account_balance_wallet_outlined;
        colorIcono = const Color(0xFF6366F1);
        break;
      case 'independiente':
        icono = Icons.work_outline_rounded;
        colorIcono = const Color(0xFF8B5CF6);
        break;
      case 'inversiones':
        icono = Icons.trending_up_rounded;
        colorIcono = const Color(0xFF10B981);
        break;
      case 'cashbacks':
        icono = Icons.credit_card_rounded;
        colorIcono = const Color(0xFFF59E0B);
        break;
      case 'extra':
        icono = Icons.card_giftcard_rounded;
        colorIcono = const Color(0xFFEC4899);
        break;
      default:
        icono = Icons.attach_money_rounded;
        colorIcono = const Color(0xFF94A3B8);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícono, nombre y botón editar
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorIcono.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icono, size: 24, color: colorIcono),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF1F5F9),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () =>
                    _mostrarDialogoEditar(nombre, estimado, actual),
                icon: const Icon(Icons.edit_outlined),
                iconSize: 18,
                color: const Color(0xFF94A3B8),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const Spacer(),

          // Montos
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Estimado:',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  Text(
                    formatearMoneda(estimado),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Real:',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  Text(
                    formatearMoneda(actual),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Barra de progreso
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: porcentaje > 100 ? 1.0 : porcentaje / 100,
                  minHeight: 6,
                  backgroundColor: const Color(0xFF334155),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    exceeded
                        ? const Color(0xFF10B981)
                        : const Color(0xFF6366F1),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Progreso',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                  Text(
                    '${porcentaje.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: exceeded
                          ? const Color(0xFF10B981)
                          : const Color(0xFF6366F1),
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (exceeded)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF064E3B),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '¡Superado por ${formatearMoneda(actual - estimado)}!',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
