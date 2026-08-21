import 'package:flutter/material.dart';

/// Paleta y tema del dashboard oscuro tipo "system monitor".
class AppColors {
  AppColors._();

  static const background = Color(0xFF0E1116);
  static const surface = Color(0xFF171B22);
  static const surfaceHigh = Color(0xFF1F2530);
  static const border = Color(0xFF262C38);

  static const textPrimary = Color(0xFFF2F5FA);
  static const textSecondary = Color(0xFF8B94A7);

  // Acentos por métrica.
  static const cpu = Color(0xFF3DDC97); // verde
  static const ram = Color(0xFF7C6CF6); // violeta
  static const storage = Color(0xFF35A7FF); // azul
  static const battery = Color(0xFFFFB454); // ámbar

  static const danger = Color(0xFFFF5C7A);
  static const warning = Color(0xFFFFB454);
  static const ok = Color(0xFF3DDC97);

  /// Color según nivel de uso (verde -> ámbar -> rojo).
  static Color forUsage(double percent) {
    if (percent >= 85) return danger;
    if (percent >= 60) return warning;
    return ok;
  }
}

class AppTheme {
  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: AppColors.cpu,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onPrimary: AppColors.background,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
    );
  }
}
