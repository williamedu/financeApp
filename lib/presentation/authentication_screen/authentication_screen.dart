import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './widgets/app_logo_widget.dart';
import './widgets/custom_text_field_widget.dart';
import './widgets/social_login_button_widget.dart';

/// Authentication screen for user login
class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({Key? key}) : super(key: key);

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isFormValid = false;

  // Mock credentials for testing
  final String _mockEmail = "usuario@financeflow.com";
  final String _mockPassword = "Finance2024!";

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final email = _emailController.text;
    final password = _passwordController.text;

    setState(() {
      _isFormValid =
          _validateEmail(email) == null && _validatePassword(password) == null;
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su correo electrónico';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Por favor ingrese un correo electrónico válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su contraseña';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    if (!_isFormValid) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate authentication delay
    await Future.delayed(Duration(seconds: 2));

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email == _mockEmail && password == _mockPassword) {
      // Success - provide haptic feedback
      HapticFeedback.lightImpact();

      setState(() {
        _isLoading = false;
      });

      // Navigate to home dashboard
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home-dashboard-screen');
      }
    } else {
      // Failed authentication
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Credenciales inválidas. Use: $_mockEmail / $_mockPassword',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _handleSocialLogin(String provider) async {
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Inicio de sesión con $provider próximamente'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleForgotPassword() async {
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Recuperación de contraseña próximamente'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleRegister() async {
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Registro de usuario próximamente'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo
                        Center(
                          child: AppLogoWidget(size: 80),
                        ),
                        SizedBox(height: 32),

                        // Welcome text
                        Text(
                          '¡Hola, Bienvenido!',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Inicia sesión para continuar',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 40),

                        // Email field
                        CustomTextFieldWidget(
                          controller: _emailController,
                          label: 'Correo Electrónico',
                          hint: 'ejemplo@correo.com',
                          iconName: 'email',
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),
                        SizedBox(height: 20),

                        // Password field
                        CustomTextFieldWidget(
                          controller: _passwordController,
                          label: 'Contraseña',
                          hint: 'Ingrese su contraseña',
                          iconName: 'lock',
                          isPassword: true,
                          validator: _validatePassword,
                        ),
                        SizedBox(height: 12),

                        // Forgot password link
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _handleForgotPassword,
                            child: Text(
                              '¿Olvidaste tu contraseña?',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24),

                        // Login button
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isFormValid && !_isLoading
                                ? _handleLogin
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              disabledBackgroundColor:
                                  theme.colorScheme.outline,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        theme.colorScheme.onPrimary,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Iniciar Sesión',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: 32),

                        // Divider with text
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: theme.colorScheme.outline,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'O continúa con',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: theme.colorScheme.outline,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24),

                        // Social login buttons
                        Row(
                          children: [
                            Expanded(
                              child: SocialLoginButtonWidget(
                                iconName: 'g_translate',
                                label: 'Google',
                                onTap: () => _handleSocialLogin('Google'),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: SocialLoginButtonWidget(
                                iconName: 'apple',
                                label: 'Apple',
                                onTap: () => _handleSocialLogin('Apple'),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 32),

                        // Register link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '¿Nuevo usuario? ',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            TextButton(
                              onPressed: _handleRegister,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                minimumSize: Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Regístrate',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
