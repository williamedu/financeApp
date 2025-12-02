import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  final int mesActual;
  final int anioActual;
  final Function(int) onMesChanged;
  final List<String> nombresMeses;

  const HeaderWidget({
    super.key,
    required this.mesActual,
    required this.anioActual,
    required this.onMesChanged,
    required this.nombresMeses,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Fondo oscuro
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF6366F1).withOpacity(0.5),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // LOGO - Lado izquierdo
            Row(
              children: [
                // Ícono circular con gradiente
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF6366F1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.show_chart_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'FinanceFlow',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF1F5F9), // Texto claro
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),

            // SELECTOR DE MES/AÑO - Centro
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF334155), // Fondo oscuro
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF475569), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ícono de calendario
                  const Icon(
                    Icons.calendar_month_outlined,
                    size: 18,
                    color: Color(0xFF94A3B8), // Gris claro
                  ),
                  const SizedBox(width: 8),

                  // Dropdown de mes
                  DropdownButton<int>(
                    value: mesActual,
                    underline: const SizedBox(),
                    dropdownColor: const Color(
                      0xFF334155,
                    ), // Fondo dropdown oscuro
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: Color(0xFF94A3B8),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF1F5F9), // Texto claro
                    ),
                    items: List.generate(12, (index) {
                      return DropdownMenuItem<int>(
                        value: index + 1,
                        child: Text(nombresMeses[index]),
                      );
                    }),
                    onChanged: (int? nuevoMes) {
                      if (nuevoMes != null) {
                        onMesChanged(nuevoMes);
                      }
                    },
                  ),

                  const SizedBox(width: 4),
                  const Text(
                    '/',
                    style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(width: 4),

                  // Año
                  Text(
                    anioActual.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF1F5F9),
                    ),
                  ),
                ],
              ),
            ),

            // USUARIO - Lado derecho
            Row(
              children: [
                const Text(
                  'Welcome,',
                  style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Alexander K.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF1F5F9),
                  ),
                ),
                const SizedBox(width: 12),
                // Avatar circular
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF6366F1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'AK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
