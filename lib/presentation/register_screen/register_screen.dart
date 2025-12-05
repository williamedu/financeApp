import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../routes/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controladores
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Lógica de Registro con Google (Tu lógica original)
  Future<void> _handleGoogleRegister() async {
    setState(() => _isLoading = true);
    try {
      final authService = AuthService();
      final user = await authService.signInWithGoogle();

      if (user != null) {
        final firestoreService = FirestoreService();
        final isFirstTime = await firestoreService.isFirstTime(user.uid);

        if (!mounted) return;

        if (isFirstTime) {
          // ES NUEVO -> Ir a Onboarding
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes
                .onboarding, // Asegúrate que esta ruta exista en tus routes
            (route) => false,
            arguments: {
              'userId': user.uid,
              'userEmail': user.email ?? '',
              'userName': user.displayName ?? 'Usuario',
            },
          );
        } else {
          // YA EXISTE -> Ir al Dashboard
          Navigator.pushReplacementNamed(context, AppRoutes.homeDashboard);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Placeholder para Apple (Futura implementación)
  Future<void> _handleAppleRegister() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registro con Apple próximamente')),
    );
  }

  // Lógica visual para registro por correo (Mantiene tu aviso actual)
  void _handleEmailRegister() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Por favor usa Google para registrarte por ahora'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Usamos Sizer para medidas responsivas (h, w) y colores consistentes con el Login
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. TÍTULO
              Text(
                'Crear Cuenta',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.sp, // Sizer sp
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Comienza a controlar tus finanzas hoy',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: const Color(0xFF94A3B8),
                ),
              ),

              SizedBox(height: 4.h),

              // 2. FORMULARIO (Diseño limpio, hints adentro)

              // Nombre
              _buildCleanTextField(
                controller: _nameController,
                hint: 'Nombre completo',
                icon: Icons.person_outline,
              ),
              SizedBox(height: 2.h),

              // Email
              _buildCleanTextField(
                controller: _emailController,
                hint: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 2.h),

              // Contraseña
              _buildCleanTextField(
                controller: _passwordController,
                hint: 'Contraseña',
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              SizedBox(height: 2.h),

              // Confirmar Contraseña
              _buildCleanTextField(
                controller: _confirmPasswordController,
                hint: 'Confirmar Contraseña',
                icon: Icons.lock_outline,
                isPassword: true,
              ),

              SizedBox(height: 4.h),

              // 3. BOTÓN PRINCIPAL (Crear Cuenta)
              SizedBox(
                height: 50, // Altura fija cómoda
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleEmailRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Crear Cuenta',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              SizedBox(height: 3.h),

              // 4. DIVISOR
              const Row(
                children: [
                  Expanded(child: Divider(color: Color(0xFF334155))),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'O regístrate con',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                    ),
                  ),
                  Expanded(child: Divider(color: Color(0xFF334155))),
                ],
              ),

              SizedBox(height: 3.h),

              // 5. BOTONES SOCIALES (VERTICALES AHORA)
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch, // Estirar botones
                  children: [
                    // Google
                    _SocialButton(
                      // Asegúrate de que la ruta sea correcta (png/jpg)
                      assetPath: 'assets/google_logo.png',
                      text: 'Registrarse con Google',
                      onTap: _handleGoogleRegister,
                    ),

                    SizedBox(height: 2.h), // Espacio vertical entre botones
                    // Apple
                    _SocialButton(
                      // Asegúrate de que la ruta sea correcta (png/jpg)
                      assetPath: 'assets/apple_logo.png',
                      text: 'Registrarse con Apple',
                      onTap: _handleAppleRegister,
                    ),
                  ],
                ),

              SizedBox(height: 4.h),

              // 6. VOLVER AL LOGIN
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '¿Ya tienes cuenta? ',
                    style: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Inicia Sesión',
                      style: TextStyle(
                        color: Color(0xFF6366F1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para los campos de texto limpios
  Widget _buildCleanTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
        prefixIcon: Icon(icon, color: const Color(0xFF94A3B8)),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}

// Reemplaza la clase _SocialButton al final del archivo por esta:
class _SocialButton extends StatelessWidget {
  final String assetPath;
  final String text;
  final VoidCallback onTap;

  const _SocialButton({
    required this.assetPath,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // <--- CENTRADO
          children: [
            Image.asset(assetPath, height: 24, width: 24),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
