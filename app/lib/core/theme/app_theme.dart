import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.red,
      brightness: Brightness.light,
    );

    return _build(
      scheme: scheme,
      background: AppColors.bgLight,
      surface: AppColors.surfaceLight,
      ink: AppColors.inkLight,
      muted: AppColors.mutedLight,
      line: AppColors.lineLight,
      navigationBackground: AppColors.surfaceLight,
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.red,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.red,
      onPrimary: Colors.white,
      surface: AppColors.surfaceDark,
    );

    return _build(
      scheme: scheme,
      background: AppColors.bgDark,
      surface: AppColors.surfaceDark,
      ink: AppColors.inkDark,
      muted: AppColors.mutedDark,
      line: AppColors.lineDark,
      navigationBackground: AppColors.surfaceDark,
    );
  }

  static ThemeData _build({
    required ColorScheme scheme,
    required Color background,
    required Color surface,
    required Color ink,
    required Color muted,
    required Color line,
    required Color navigationBackground,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: 'sans-serif-condensed',
      visualDensity: VisualDensity.standard,
      textTheme: TextTheme(
        displaySmall: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -.4, color: ink),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -.2, color: ink),
        titleLarge: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: ink),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: ink),
        titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: ink),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.25, color: ink),
        bodyMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, height: 1.25, color: ink),
        bodySmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.2, color: muted),
        labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: ink),
        labelMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ink),
        labelSmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: muted),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: BorderSide(color: line),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.red, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.red,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          foregroundColor: ink,
          side: BorderSide(color: line),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 76,
        backgroundColor: navigationBackground,
        surfaceTintColor: navigationBackground,
        indicatorColor: AppColors.red.withValues(alpha: .12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? AppColors.red : muted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.red : muted,
            size: selected ? 25 : 23,
          );
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: AppColors.red.withValues(alpha: .12),
        side: BorderSide(color: line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
        labelStyle: TextStyle(fontWeight: FontWeight.w700, color: ink),
      ),
      dividerTheme: DividerThemeData(color: line, space: 1, thickness: 1),
    );
  }
}
