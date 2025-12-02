import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../widgets/onboarding_wizard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = false;
  bool _wizardCompleted = false;

  // Datos recolectados del wizard (CAMBIAR ESTOS 3 MAPAS)
  Map<String, Map<String, dynamic>> _ingresos = {};
  Map<String, Map<String, dynamic>> _gastosFijos = {};
  Map<String, Map<String, dynamic>> _gastosVariables = {};

  @override
  void initState() {
    super.initState();

    // Mostrar wizard automáticamente al cargar la página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_wizardCompleted) {
        _mostrarWizard();
      }
    });
  }

  void _mostrarWizard() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => OnboardingWizard(
        userId: '', // No hay usuario aún
        userEmail: '',
        userName: '',
        onComplete: (ingresos, gastosFijos, gastosVariables) {
          // Guardar datos en memoria
          setState(() {
            _ingresos = ingresos;
            _gastosFijos = gastosFijos;
            _gastosVariables = gastosVariables;
            _wizardCompleted = true;
          });

          debugPrint('✅ Wizard completado. Datos guardados en memoria.');
          debugPrint('Ingresos: $_ingresos');
          debugPrint('Gastos Fijos: $_gastosFijos');
          debugPrint('Gastos Variables: $_gastosVariables');

          // AGREGAR ESTA LÍNEA:
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    debugPrint('🔵 Iniciando login después del wizard...');
    setState(() => _isLoading = true);

    try {
      final userCredential = await _authService.signInWithGoogle();

      if (userCredential != null) {
        final user = userCredential.user!;
        debugPrint('✅ Login exitoso: ${user.email}');

        // Guardar TODOS los datos en Firestore
        await _firestoreService.saveInitialData(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? 'Usuario',
          ingresos: _ingresos,
          gastosFijos: _gastosFijos,
          gastosVariables: _gastosVariables,
        );

        debugPrint('✅ Datos guardados en Firestore correctamente');

        await Future.delayed(const Duration(milliseconds: 1500));

        // El StreamBuilder en main.dart navegará automáticamente al HomePage
      } else {
        debugPrint('❌ UserCredential es null');
      }
    } catch (e) {
      debugPrint('❌ ERROR en login: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al iniciar sesión: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Icono
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF6366F1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.show_chart_rounded,
                  color: Colors.white,
                  size: 60,
                ),
              ),

              const SizedBox(height: 48),

              // Título
              const Text(
                'FinanceFlow',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF1F5F9),
                  letterSpacing: -1,
                ),
              ),

              const SizedBox(height: 12),

              // Subtítulo
              const Text(
                'Controla tus finanzas personales\nde manera simple y efectiva',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF94A3B8),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 64),

              // Botón de Google Sign In - SOLO se muestra si el wizard está completado
              if (_wizardCompleted)
                _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF6366F1),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: _handleGoogleSignIn,
                        icon: Image.asset(
                          'assets/google_logo.png',
                          height: 24,
                          width: 24,
                        ),
                        label: const Text(
                          'Continuar con Google',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1F2937),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                      ),

              // Mensaje mientras completa el wizard
              if (!_wizardCompleted)
                const Column(
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF6366F1),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Completando configuración inicial...',
                      style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),

              const SizedBox(height: 24),

              // Términos y condiciones
              if (_wizardCompleted)
                const Text(
                  'Al continuar, aceptas nuestros\nTérminos de Servicio y Política de Privacidad',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
