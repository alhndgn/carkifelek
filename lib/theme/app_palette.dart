import 'package:flutter/material.dart';

/// Bir temanın tüm renklerini taşıyan değişmez veri.
///
/// Uygulama renkleri asla doğrudan sabit yazmaz; `palette.dart` içindeki
/// getter'lar aktif temayı okur. Böylece tema değişince tüm arayüz
/// (arka plan, yüzeyler, yazı, vurgu ve çark paleti) birlikte değişir.
@immutable
class AppPalette {
  const AppPalette({
    required this.id,
    required this.name,
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    required this.accentAlt,
    required this.wheels,
  });

  final String id;
  final String name;
  final Brightness brightness;

  /// Arka plan gradyanı (üstten alta, en az 2 durak).
  final List<Color> background;

  final Color surface;
  final Color surfaceHigh;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;
  final Color accentAlt;

  /// Çark dilimleri için küratörlü palet; dilim sayısı aşınca başa döner.
  final List<Color> wheels;

  bool get isDark => brightness == Brightness.dark;
}

/// Uygulamadaki tüm temalar. Sıra, seçici ekrandaki sıradır.
const List<AppPalette> kAppPalettes = <AppPalette>[
  AppPalette(
    id: 'gece',
    name: 'Gece',
    brightness: Brightness.dark,
    background: <Color>[
      Color(0xFF191531),
      Color(0xFF141126),
      Color(0xFF0D0B18),
    ],
    surface: Color(0xFF211D33),
    surfaceHigh: Color(0xFF2C2740),
    border: Color(0xFF383253),
    textPrimary: Color(0xFFF5F3FF),
    textSecondary: Color(0xFFA9A3C4),
    accent: Color(0xFF8B5CF6),
    accentAlt: Color(0xFF3E9BEF),
    wheels: <Color>[
      Color(0xFFE94F6B),
      Color(0xFFF2833F),
      Color(0xFFF4B942),
      Color(0xFF9BCB3B),
      Color(0xFF3FBF7F),
      Color(0xFF2FB7B0),
      Color(0xFF3E9BEF),
      Color(0xFF5B6BEF),
      Color(0xFF8B5CF6),
      Color(0xFFC24FD1),
      Color(0xFFE0568F),
      Color(0xFF7A8699),
    ],
  ),
  AppPalette(
    id: 'okyanus',
    name: 'Okyanus',
    brightness: Brightness.dark,
    background: <Color>[
      Color(0xFF07202B),
      Color(0xFF051821),
      Color(0xFF030F16),
    ],
    surface: Color(0xFF0D2A36),
    surfaceHigh: Color(0xFF123A4A),
    border: Color(0xFF1B4A5C),
    textPrimary: Color(0xFFE6FAFF),
    textSecondary: Color(0xFF8FB6C4),
    accent: Color(0xFF22D3EE),
    accentAlt: Color(0xFF3B82F6),
    wheels: <Color>[
      Color(0xFF22D3EE),
      Color(0xFF0EA5E9),
      Color(0xFF6366F1),
      Color(0xFF14B8A6),
      Color(0xFFF59E0B),
      Color(0xFF7DD3FC),
      Color(0xFF818CF8),
      Color(0xFF5EEAD4),
      Color(0xFFEC4899),
      Color(0xFF0284C7),
      Color(0xFF38BDF8),
      Color(0xFF0891B2),
    ],
  ),
  AppPalette(
    id: 'gunbatimi',
    name: 'Gün Batımı',
    brightness: Brightness.dark,
    background: <Color>[
      Color(0xFF2A1220),
      Color(0xFF1E0C17),
      Color(0xFF12060D),
    ],
    surface: Color(0xFF321626),
    surfaceHigh: Color(0xFF422034),
    border: Color(0xFF54293F),
    textPrimary: Color(0xFFFFF1F5),
    textSecondary: Color(0xFFC79AAC),
    accent: Color(0xFFFB7185),
    accentAlt: Color(0xFFF97316),
    wheels: <Color>[
      Color(0xFFFB7185),
      Color(0xFFF97316),
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
      Color(0xFFD946EF),
      Color(0xFFFBBF24),
      Color(0xFFEC4899),
      Color(0xFFF43F5E),
      Color(0xFFA855F7),
      Color(0xFFFDBA74),
      Color(0xFFE11D48),
      Color(0xFFC026D3),
    ],
  ),
  AppPalette(
    id: 'orman',
    name: 'Orman',
    brightness: Brightness.dark,
    background: <Color>[
      Color(0xFF0E2219),
      Color(0xFF0A1A13),
      Color(0xFF06120D),
    ],
    surface: Color(0xFF12291F),
    surfaceHigh: Color(0xFF1A3A2C),
    border: Color(0xFF25513D),
    textPrimary: Color(0xFFEAFBF1),
    textSecondary: Color(0xFF93B8A4),
    accent: Color(0xFF34D399),
    accentAlt: Color(0xFF84CC16),
    wheels: <Color>[
      Color(0xFF34D399),
      Color(0xFF10B981),
      Color(0xFF84CC16),
      Color(0xFF22C55E),
      Color(0xFF059669),
      Color(0xFFA3E635),
      Color(0xFF14B8A6),
      Color(0xFF65A30D),
      Color(0xFF4ADE80),
      Color(0xFF0D9488),
      Color(0xFFBEF264),
      Color(0xFF15803D),
    ],
  ),
  AppPalette(
    id: 'altin',
    name: 'Altın',
    brightness: Brightness.dark,
    background: <Color>[
      Color(0xFF1C1608),
      Color(0xFF140F05),
      Color(0xFF0B0802),
    ],
    surface: Color(0xFF241C0B),
    surfaceHigh: Color(0xFF322714),
    border: Color(0xFF4A3A1D),
    textPrimary: Color(0xFFFDF6E6),
    textSecondary: Color(0xFFC0AC84),
    accent: Color(0xFFE0B64A),
    accentAlt: Color(0xFFF59E0B),
    wheels: <Color>[
      Color(0xFFE0B64A),
      Color(0xFFF5D98B),
      Color(0xFFB45309),
      Color(0xFFD97706),
      Color(0xFFFBBF24),
      Color(0xFF92400E),
      Color(0xFFFCD34D),
      Color(0xFFA16207),
      Color(0xFFEAB308),
      Color(0xFFCA8A04),
      Color(0xFFFDE68A),
      Color(0xFF854D0E),
    ],
  ),
  AppPalette(
    id: 'kagit',
    name: 'Kâğıt',
    brightness: Brightness.light,
    background: <Color>[
      Color(0xFFF8F4EC),
      Color(0xFFF1EADD),
      Color(0xFFEAE1D2),
    ],
    surface: Color(0xFFFFFFFF),
    surfaceHigh: Color(0xFFFBF7F0),
    border: Color(0xFFDCD2C2),
    textPrimary: Color(0xFF2A2420),
    textSecondary: Color(0xFF7A6F63),
    accent: Color(0xFFB45309),
    accentAlt: Color(0xFF0F766E),
    wheels: <Color>[
      Color(0xFFB45309),
      Color(0xFF0F766E),
      Color(0xFF7C3AED),
      Color(0xFFDB2777),
      Color(0xFFCA8A04),
      Color(0xFF2563EB),
      Color(0xFF059669),
      Color(0xFFDC2626),
      Color(0xFF9333EA),
      Color(0xFF0891B2),
      Color(0xFFEA580C),
      Color(0xFF475569),
    ],
  ),
];

AppPalette paletteById(String? id) {
  for (final AppPalette p in kAppPalettes) {
    if (p.id == id) return p;
  }
  return kAppPalettes.first;
}
