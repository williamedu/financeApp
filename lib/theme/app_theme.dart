import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A class that contains all theme configurations for the personal finance application.
class AppTheme {
  AppTheme._();

  // Color Specifications - Professional Dark Spectrum
  static const Color primaryBackgroundDark = Color(0xFF0F172A);
  static const Color surfaceContainerDark = Color(0xFF1E293B);
  static const Color expenseRed = Color(0xFFEF4444);
  static const Color incomeGold = Color(0xFFF59E0B);
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF97316);
  static const Color borderSubtle = Color(0xFF334155);
  static const Color interactiveBlue = Color(0xFF3B82F6);

  // Light theme colors
  static const Color primaryBackgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceContainerLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);

  // Shadow colors
  static const Color shadowDark = Color(0x26000000);
  static const Color shadowLight = Color(0x1A000000);

  // Divider colors
  static const Color dividerDark = Color(0xFF334155);
  static const Color dividerLight = Color(0xFFE2E8F0);

  /// Dark theme - Primary theme for the application
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: incomeGold,
      onPrimary: primaryBackgroundDark,
      primaryContainer: incomeGold,
      onPrimaryContainer: primaryBackgroundDark,
      secondary: interactiveBlue,
      onSecondary: textPrimary,
      secondaryContainer: interactiveBlue,
      onSecondaryContainer: textPrimary,
      tertiary: successGreen,
      onTertiary: textPrimary,
      tertiaryContainer: successGreen,
      onTertiaryContainer: textPrimary,
      error: expenseRed,
      onError: textPrimary,
      surface: surfaceContainerDark,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      outline: borderSubtle,
      outlineVariant: dividerDark,
      shadow: shadowDark,
      scrim: Color(0xFF000000),
      inverseSurface: surfaceContainerLight,
      onInverseSurface: textPrimaryLight,
      inversePrimary: incomeGold,
    ),
    scaffoldBackgroundColor: primaryBackgroundDark,
    cardColor: surfaceContainerDark,
    dividerColor: borderSubtle,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryBackgroundDark,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.15,
      ),
    ),
    // CORREGIDO: CardTheme (sin Data)
    cardTheme: CardThemeData(
      color: surfaceContainerDark,
      elevation: 2.0,
      shadowColor: shadowDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    // Este sí lleva Data
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceContainerDark,
      selectedItemColor: incomeGold,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: incomeGold,
      foregroundColor: primaryBackgroundDark,
      elevation: 6.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: primaryBackgroundDark,
        backgroundColor: incomeGold,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: incomeGold,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        side: BorderSide(color: incomeGold, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: interactiveBlue,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.25,
        ),
      ),
    ),
    textTheme: _buildTextTheme(isLight: false),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: surfaceContainerDark,
      filled: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: borderSubtle, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: borderSubtle, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: incomeGold, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: expenseRed, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: expenseRed, width: 2),
      ),
      labelStyle: GoogleFonts.inter(
        color: textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      hintStyle: GoogleFonts.inter(
        color: textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      errorStyle: GoogleFonts.inter(
        color: expenseRed,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      prefixIconColor: textSecondary,
      suffixIconColor: textSecondary,
    ),
    // WidgetStateProperty requiere Flutter 3.22+. Si da error, usa MaterialStateProperty
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return incomeGold;
        }
        return textSecondary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return incomeGold.withValues(alpha: 0.5);
        }
        return borderSubtle;
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return incomeGold;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(primaryBackgroundDark),
      side: BorderSide(color: borderSubtle, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return incomeGold;
        }
        return borderSubtle;
      }),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: incomeGold,
      circularTrackColor: borderSubtle,
      linearTrackColor: borderSubtle,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: incomeGold,
      thumbColor: incomeGold,
      overlayColor: incomeGold.withValues(alpha: 0.2),
      inactiveTrackColor: borderSubtle,
      valueIndicatorColor: incomeGold,
      valueIndicatorTextStyle: GoogleFonts.inter(
        color: primaryBackgroundDark,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
    // CORREGIDO: TabBarTheme (sin Data)
    tabBarTheme: TabBarThemeData(
      labelColor: incomeGold,
      unselectedLabelColor: textSecondary,
      indicatorColor: incomeGold,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: surfaceContainerDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderSubtle, width: 1),
      ),
      textStyle: GoogleFonts.inter(
        color: textPrimary,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surfaceContainerDark,
      contentTextStyle: GoogleFonts.inter(
        color: textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      actionTextColor: incomeGold,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: borderSubtle, width: 1),
      ),
      elevation: 6,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceContainerDark,
      selectedColor: incomeGold.withValues(alpha: 0.2),
      disabledColor: borderSubtle,
      labelStyle: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      secondaryLabelStyle: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: borderSubtle, width: 1),
      ),
    ),
    dividerTheme: DividerThemeData(color: borderSubtle, thickness: 1, space: 1),
    // CORREGIDO: DialogTheme (sin Data)
    dialogTheme: DialogThemeData(backgroundColor: surfaceContainerDark),
  );

  /// Light theme
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: incomeGold,
      onPrimary: primaryBackgroundLight,
      primaryContainer: incomeGold,
      onPrimaryContainer: primaryBackgroundLight,
      secondary: interactiveBlue,
      onSecondary: textPrimaryLight,
      secondaryContainer: interactiveBlue,
      onSecondaryContainer: textPrimaryLight,
      tertiary: successGreen,
      onTertiary: textPrimaryLight,
      tertiaryContainer: successGreen,
      onTertiaryContainer: textPrimaryLight,
      error: expenseRed,
      onError: primaryBackgroundLight,
      surface: surfaceContainerLight,
      onSurface: textPrimaryLight,
      onSurfaceVariant: textSecondaryLight,
      outline: dividerLight,
      outlineVariant: dividerLight,
      shadow: shadowLight,
      scrim: Color(0xFF000000),
      inverseSurface: surfaceContainerDark,
      onInverseSurface: textPrimary,
      inversePrimary: incomeGold,
    ),
    scaffoldBackgroundColor: primaryBackgroundLight,
    cardColor: surfaceContainerLight,
    dividerColor: dividerLight,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryBackgroundLight,
      foregroundColor: textPrimaryLight,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryLight,
        letterSpacing: 0.15,
      ),
    ),
    // CORREGIDO: CardTheme
    cardTheme: CardThemeData(
      color: surfaceContainerLight,
      elevation: 2.0,
      shadowColor: shadowLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceContainerLight,
      selectedItemColor: incomeGold,
      unselectedItemColor: textSecondaryLight,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: incomeGold,
      foregroundColor: primaryBackgroundLight,
      elevation: 6.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: primaryBackgroundLight,
        backgroundColor: incomeGold,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: incomeGold,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        side: BorderSide(color: incomeGold, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: interactiveBlue,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.25,
        ),
      ),
    ),
    textTheme: _buildTextTheme(isLight: true),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: surfaceContainerLight,
      filled: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: dividerLight, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: dividerLight, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: incomeGold, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: expenseRed, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: expenseRed, width: 2),
      ),
      labelStyle: GoogleFonts.inter(
        color: textSecondaryLight,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      hintStyle: GoogleFonts.inter(
        color: textSecondaryLight,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      errorStyle: GoogleFonts.inter(
        color: expenseRed,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      prefixIconColor: textSecondaryLight,
      suffixIconColor: textSecondaryLight,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return incomeGold;
        }
        return textSecondaryLight;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return incomeGold.withValues(alpha: 0.5);
        }
        return dividerLight;
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return incomeGold;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(primaryBackgroundLight),
      side: BorderSide(color: dividerLight, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return incomeGold;
        }
        return dividerLight;
      }),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: incomeGold,
      circularTrackColor: dividerLight,
      linearTrackColor: dividerLight,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: incomeGold,
      thumbColor: incomeGold,
      overlayColor: incomeGold.withValues(alpha: 0.2),
      inactiveTrackColor: dividerLight,
      valueIndicatorColor: incomeGold,
      valueIndicatorTextStyle: GoogleFonts.inter(
        color: primaryBackgroundLight,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
    // CORREGIDO: TabBarTheme
    tabBarTheme: TabBarThemeData(
      labelColor: incomeGold,
      unselectedLabelColor: textSecondaryLight,
      indicatorColor: incomeGold,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: surfaceContainerLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: dividerLight, width: 1),
      ),
      textStyle: GoogleFonts.inter(
        color: textPrimaryLight,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surfaceContainerLight,
      contentTextStyle: GoogleFonts.inter(
        color: textPrimaryLight,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      actionTextColor: incomeGold,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: dividerLight, width: 1),
      ),
      elevation: 6,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceContainerLight,
      selectedColor: incomeGold.withValues(alpha: 0.2),
      disabledColor: dividerLight,
      labelStyle: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: textPrimaryLight,
      ),
      secondaryLabelStyle: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: textSecondaryLight,
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: dividerLight, width: 1),
      ),
    ),
    dividerTheme: DividerThemeData(color: dividerLight, thickness: 1, space: 1),
    // CORREGIDO: DialogTheme
    dialogTheme: DialogThemeData(backgroundColor: surfaceContainerLight),
  );

  static TextTheme _buildTextTheme({required bool isLight}) {
    final Color textHigh = isLight ? textPrimaryLight : textPrimary;
    final Color textMedium = isLight ? textSecondaryLight : textSecondary;

    return TextTheme(
      displayLarge: GoogleFonts.inter(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        color: textHigh,
        letterSpacing: -0.25,
        height: 1.12,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        color: textHigh,
        letterSpacing: 0,
        height: 1.16,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: textHigh,
        letterSpacing: 0,
        height: 1.22,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: textHigh,
        letterSpacing: 0,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textHigh,
        letterSpacing: 0,
        height: 1.29,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textHigh,
        letterSpacing: 0,
        height: 1.33,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textHigh,
        letterSpacing: 0,
        height: 1.27,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textHigh,
        letterSpacing: 0.15,
        height: 1.50,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textHigh,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textHigh,
        letterSpacing: 0.5,
        height: 1.50,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textHigh,
        letterSpacing: 0.25,
        height: 1.43,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textMedium,
        letterSpacing: 0.4,
        height: 1.33,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textHigh,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textMedium,
        letterSpacing: 0.5,
        height: 1.33,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: textMedium,
        letterSpacing: 0.5,
        height: 1.45,
      ),
    );
  }
}
