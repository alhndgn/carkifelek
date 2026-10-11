/// 8pt ızgara: tüm boşluklar bu sabitlerden türetilir.
class Spacing {
  const Spacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Dokunma hedefi alt sınırı (erişilebilirlik).
  static const double minTouchTarget = 48;
}

/// Yuvarlatılmış köşe yarıçapları.
class Radii {
  const Radii._();

  static const double sm = 12;
  static const double md = 18;
  static const double lg = 24;
  static const double pill = 999;
}
