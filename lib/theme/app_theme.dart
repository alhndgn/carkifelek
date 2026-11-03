import 'package:flutter/material.dart';

import 'app_palette.dart';
import 'palette.dart';
import 'spacing.dart';

/// Aktif palete göre Material teması üretir.
///
/// Renkler artık sabit değil: `AppPalette` alanlarından gelir. Böylece tema
/// değişince AppBar, kart, sheet, input, düğme ve snackbar birlikte değişir.
class AppTheme {
  const AppTheme._();

  static ThemeData of(AppPalette p) {
    final ThemeData base = ThemeData(
      brightness: p.brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: p.accent,
        brightness: p.brightness,
      ),
    );

    return base.copyWith(
      // AppBar şeffaf; arkasında bu renk görünür. Gradyanın üst durağıyla aynı
      // olduğu için gövdeyle dikişsiz birleşir (önceden beyaz sızıyordu).
      scaffoldBackgroundColor: p.background.first,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: p.textPrimary,
        titleTextStyle: TextStyle(
          color: p.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: p.textPrimary,
        displayColor: p.textPrimary,
      ),
      cardTheme: base.cardTheme.copyWith(
        color: p.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.md),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surfaceHigh,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.lg)),
        ),
      ),
      dialogTheme: base.dialogTheme.copyWith(
        backgroundColor: p.surfaceHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.md),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        hintStyle: TextStyle(color: p.textSecondary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.sm),
          borderSide: BorderSide(color: p.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.sm),
          borderSide: BorderSide(color: p.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.sm),
          borderSide: BorderSide(color: p.accent, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.accent,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, Spacing.minTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.sm),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.textPrimary,
          minimumSize: const Size(0, Spacing.minTouchTarget),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.surfaceHigh,
        contentTextStyle: TextStyle(color: p.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.sm),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: p.textSecondary,
        textColor: p.textPrimary,
      ),
      dividerTheme: DividerThemeData(color: p.border, thickness: 1),
      popupMenuTheme: PopupMenuThemeData(
        color: p.surfaceHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.sm),
        ),
      ),
      sliderTheme: base.sliderTheme.copyWith(
        activeTrackColor: p.accent,
        thumbColor: p.accent,
        inactiveTrackColor: p.border,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((Set<WidgetState> s) {
          return s.contains(WidgetState.selected) ? Colors.white : p.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((Set<WidgetState> s) {
          return s.contains(WidgetState.selected) ? p.accent : p.border;
        }),
      ),
    );
  }

  /// Geriye dönük kullanım: aktif paletle tema üretir.
  static ThemeData dark() => of(activePalette);
}
