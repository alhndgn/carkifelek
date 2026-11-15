/// Çarkın görünümü. Hepsi aynı dönen-disk modelini kullanır: ibre üstte
/// sabittir, disk döner ve kazanan açıya göre belirlenir. Sadece çizim değişir.
enum WheelStyle {
  classic('classic', 'Klasik', 'Pasta dilimi; ortada çevir düğmesi'),
  donut('donut', 'Halka', 'İnce halka, ortası boş'),
  target('target', 'Hedef', 'Konsantrik halkalar, dart tahtası gibi'),
  needle('needle', 'İbre', 'Sade kadran ve çentikler, büyük ibre'),
  petal('petal', 'Çiçek', 'Yuvarlak yapraklar, çiçek gibi taç yaprakları'),
  star('star', 'Yıldız', 'Sivri uçlu dilimler, yıldız silueti'),
  pinwheel('pinwheel', 'Rüzgâr Gülü', 'Kavisli kanatlar, dönen pervane'),
  segments('segments', 'Bölmeli', 'Aralıklı halka dilimleri, boşluklu');

  const WheelStyle(this.id, this.label, this.description);

  final String id;
  final String label;
  final String description;

  static WheelStyle fromId(Object? id) {
    for (final WheelStyle style in WheelStyle.values) {
      if (style.id == id) return style;
    }
    return WheelStyle.classic;
  }
}
