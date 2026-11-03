import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Aktif tema. `themeProvider` değiştirir; uygulama kökü yeniden çizildiği için
/// tüm getter'lar yeni değerleri döner.
///
/// Renkler sabit (const) değil, getter'dır: tema değişince arayüzün tamamı
/// (arka plan, yüzeyler, yazı, vurgu, çark paleti) birlikte güncellenir.
AppPalette _activePalette = kAppPalettes.first;

AppPalette get activePalette => _activePalette;

/// Tema kimliğine göre aktif paleti değiştirir (bilinmeyen kimlik → ilk tema).
void setActivePalette(String? id) {
  _activePalette = paletteById(id);
}

/// Aktif temanın çark renkleri.
List<Color> get kWheelPalette => _activePalette.wheels;

/// Aktif temanın arka plan gradyanı.
List<Color> get kBackgroundGradient => _activePalette.background;

Color get kSurface => _activePalette.surface;
Color get kSurfaceHigh => _activePalette.surfaceHigh;
Color get kBorder => _activePalette.border;
Color get kTextPrimary => _activePalette.textPrimary;
Color get kTextSecondary => _activePalette.textSecondary;
Color get kAccent => _activePalette.accent;
Color get kAccentAlt => _activePalette.accentAlt;

/// Sıraya göre dilim rengi; palet bitince başa döner.
Color paletteColorAt(int index) => kWheelPalette[index % kWheelPalette.length];

/// Dilim metninin okunabilmesi için zemin koyu mu?
bool isDarkColor(Color color) {
  final double luminance =
      (0.299 * color.r + 0.587 * color.g + 0.114 * color.b);
  return luminance < 0.6;
}
