import 'package:flutter/material.dart';

import 'palette.dart';
import 'spacing.dart';

/// Uygulamanın koyu teması. Yeni nesil hissi için: transparan scaffold,
/// gradyan arka plan (bkz. `AppBackground`), yumuşak yüzeyler, pill düğmeler.
class AppTheme {
  const AppTheme._();

  static ThemeData dark() {
    final ThemeData base = ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kAccent,
        brightness: Brightness.dark,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: kTextPrimary,
        titleTextStyle: TextStyle(
          color: kTextPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: kTextPrimary,
        displayColor: kTextPrimary,
      ),
      cardTheme: base.cardTheme.copyWith(
        color: kSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.md),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: kSurfaceHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.lg)),
        ),
      ),
      dialogTheme: base.dialogTheme.copyWith(
        backgroundColor: kSurfaceHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.md),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kSurface,
        hintStyle: const TextStyle(color: kTextSecondary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.sm),
          borderSide: const BorderSide(color: kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.sm),
          borderSide: const BorderSide(color: kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.sm),
          borderSide: const BorderSide(color: kAccent, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: kAccent,
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
          foregroundColor: kTextPrimary,
          minimumSize: const Size(0, Spacing.minTouchTarget),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: kSurfaceHigh,
        contentTextStyle: const TextStyle(color: kTextPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.sm),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: kTextSecondary,
        textColor: kTextPrimary,
      ),
      dividerTheme: const DividerThemeData(color: kBorder, thickness: 1),
      popupMenuTheme: PopupMenuThemeData(
        color: kSurfaceHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.sm),
        ),
      ),
    );
  }
}
