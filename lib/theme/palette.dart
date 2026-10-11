import 'package:flutter/material.dart';

/// Çarkıfelek renk paleti — çark dilimleri için küratörlü 12 renk.
/// Yeni dilim eklendiğinde renkler bu sırayla döner.
const List<Color> kWheelPalette = <Color>[
  Color(0xFFE94F6B), // ahududu
  Color(0xFFF2833F), // turuncu
  Color(0xFFF4B942), // amber
  Color(0xFF9BCB3B), // açık yeşil
  Color(0xFF3FBF7F), // yeşil
  Color(0xFF2FB7B0), // turkuaz
  Color(0xFF3E9BEF), // mavi
  Color(0xFF5B6BEF), // indigo
  Color(0xFF8B5CF6), // mor
  Color(0xFFC24FD1), // magenta
  Color(0xFFE0568F), // pembe
  Color(0xFF7A8699), // gri
];

/// Koyu tema arka plan gradyanı (üstten alta).
const List<Color> kBackgroundGradient = <Color>[
  Color(0xFF191531),
  Color(0xFF141126),
  Color(0xFF0D0B18),
];

const Color kSurface = Color(0xFF211D33);
const Color kSurfaceHigh = Color(0xFF2C2740);
const Color kBorder = Color(0xFF383253);
const Color kTextPrimary = Color(0xFFF5F3FF);
const Color kTextSecondary = Color(0xFFA9A3C4);
const Color kAccent = Color(0xFF8B5CF6);
const Color kAccentAlt = Color(0xFF3E9BEF);

/// Sıraya göre dilim rengi; palet bitince başa döner.
Color paletteColorAt(int index) => kWheelPalette[index % kWheelPalette.length];

/// Dilim metninin okunabilmesi için zemin koyu mu?
bool isDarkColor(Color color) {
  final double luminance = (0.299 * color.r + 0.587 * color.g + 0.114 * color.b);
  return luminance < 0.6;
}
