import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';

/// Splash Screen - Initial app launch screen with branding and initialization
/// Handles authentication status check and navigation to appropriate screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  /// Setup logo animations for smooth entrance
  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
  }

  /// Initialize app services and check authentication status
  Future<void> _initializeApp() async {
    try {
      // Simulate initialization tasks
      await Future.wait([
        _checkAuthenticationStatus(),
        _initializeFirestore(),
        _loadUserPreferences(),
        _prepareCachedData(),
        Future.delayed(const Duration(seconds: 2)), // Minimum splash duration
      ]);

      if (mounted) {
        setState(() => _isInitialized = true);
        await Future.delayed(const Duration(milliseconds: 500));
        _navigateToNextScreen();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Error al inicializar la aplicación';
        });
      }
    }
  }

  /// Check user authentication status
  Future<void> _checkAuthenticationStatus() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Authentication check logic would go here
  }

  /// Initialize Firestore connection
  Future<void> _initializeFirestore() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Firestore initialization logic would go here
  }

  /// Load user preferences from local storage
  Future<void> _loadUserPreferences() async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Load preferences logic would go here
  }

  /// Prepare cached financial data
  Future<void> _prepareCachedData() async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Cache preparation logic would go here
  }

  /// Navigate to appropriate screen based on authentication status
  void _navigateToNextScreen() {
    HapticFeedback.lightImpact();

    // For demo purposes, navigate to authentication screen
    // In production, check actual auth status and navigate accordingly
    Navigator.pushReplacementNamed(context, '/authentication-screen');
  }

  /// Retry initialization on error
  void _retryInitialization() {
    setState(() {
      _hasError = false;
      _errorMessage = '';
      _isInitialized = false;
    });
    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.primaryBackgroundDark,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.primaryBackgroundDark,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Animated Logo Section
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: _buildLogoSection(theme),
                      ),
                    );
                  },
                ),

                const Spacer(flex: 1),

                // Loading or Error Section
                _buildBottomSection(theme),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build logo section with app branding
  Widget _buildLogoSection(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // App Logo Icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppTheme.incomeGold,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppTheme.incomeGold.withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: 'account_balance_wallet',
              color: AppTheme.primaryBackgroundDark,
              size: 64,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // App Name
        Text(
          'FinanceFlow',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),

        const SizedBox(height: 8),

        // App Tagline
        Text(
          'Tu dinero, bajo control',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  /// Build bottom section with loading indicator or error message
  Widget _buildBottomSection(ThemeData theme) {
    if (_hasError) {
      return _buildErrorSection(theme);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Loading Indicator
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.incomeGold),
          ),
        ),

        const SizedBox(height: 16),

        // Loading Text
        Text(
          'Inicializando...',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Build error section with retry option
  Widget _buildErrorSection(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.expenseRed.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.expenseRed.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'error_outline',
                color: AppTheme.expenseRed,
                size: 32,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Error Message
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),

          const SizedBox(height: 24),

          // Retry Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _retryInitialization,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.incomeGold,
                foregroundColor: AppTheme.primaryBackgroundDark,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Reintentar',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.primaryBackgroundDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
