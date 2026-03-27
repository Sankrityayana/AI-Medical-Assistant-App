import 'package:flutter/material.dart';

class AppTheme {
  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF0F52BA),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFD5E4FF),
    onPrimaryContainer: Color(0xFF001A43),
    secondary: Color(0xFF2F7DFF),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFDCE8FF),
    onSecondaryContainer: Color(0xFF071B4B),
    tertiary: Color(0xFF26A0FC),
    onTertiary: Color(0xFF003258),
    tertiaryContainer: Color(0xFFD3EEFF),
    onTertiaryContainer: Color(0xFF001D33),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: Color(0xFFF4F8FF),
    onSurface: Color(0xFF0F1A2B),
    surfaceContainerHighest: Color(0xFFDDE6F5),
    onSurfaceVariant: Color(0xFF404A5D),
    outline: Color(0xFF707A8D),
    shadow: Color(0xFF000000),
    inverseSurface: Color(0xFF2C3445),
    onInverseSurface: Color(0xFFEBF0FF),
    inversePrimary: Color(0xFFAAC7FF),
    scrim: Color(0xFF000000),
  );

  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFAAC7FF),
    onPrimary: Color(0xFF002D73),
    primaryContainer: Color(0xFF0B3E9A),
    onPrimaryContainer: Color(0xFFD8E5FF),
    secondary: Color(0xFFB7C8FF),
    onSecondary: Color(0xFF1C2E60),
    secondaryContainer: Color(0xFF33457A),
    onSecondaryContainer: Color(0xFFDEE3FF),
    tertiary: Color(0xFF80D0FF),
    onTertiary: Color(0xFF00344F),
    tertiaryContainer: Color(0xFF004B71),
    onTertiaryContainer: Color(0xFFC7E8FF),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF0D1423),
    onSurface: Color(0xFFDDE6FA),
    surfaceContainerHighest: Color(0xFF2A3448),
    onSurfaceVariant: Color(0xFFBEC8DD),
    outline: Color(0xFF8893A8),
    shadow: Color(0xFF000000),
    inverseSurface: Color(0xFFDDE6FA),
    onInverseSurface: Color(0xFF1B2333),
    inversePrimary: Color(0xFF0F52BA),
    scrim: Color(0xFF000000),
  );

  static ThemeData lightTheme = _buildTheme(_lightScheme);
  static ThemeData darkTheme = _buildTheme(_darkScheme);

  static ThemeData _buildTheme(ColorScheme scheme) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: scheme.brightness,
      scaffoldBackgroundColor: scheme.surface,
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: scheme.primaryContainer,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: scheme.primaryContainer,
        elevation: 1,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        behavior: SnackBarBehavior.floating,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.35)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          foregroundColor: scheme.onPrimary,
          backgroundColor: scheme.primary,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: scheme.onPrimary,
          backgroundColor: scheme.primary,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size.fromHeight(48),
          side: BorderSide(color: scheme.primary.withValues(alpha: 0.6)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? scheme.primary : scheme.surface,
        ),
        checkColor: WidgetStatePropertyAll(scheme.onPrimary),
      ),
      chipTheme: base.chipTheme.copyWith(
        selectedColor: scheme.primaryContainer,
        backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        labelStyle: TextStyle(color: scheme.onSurface),
        side: BorderSide(color: scheme.outline.withValues(alpha: 0.25)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.secondary,
        foregroundColor: scheme.onSecondary,
      ),
      dividerTheme: DividerThemeData(color: scheme.outline.withValues(alpha: 0.2), thickness: 1),
      textTheme: base.textTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
    );
  }
}
