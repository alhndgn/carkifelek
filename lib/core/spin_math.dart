import 'dart:math' as math;

/// Çark dönüşü matematiği — Flutter'dan ve animasyondan bağımsız saf fonksiyonlar.
///
/// Açı modeli: **0 radyan = ibrenin durduğu yön (saat 12)**. Açılar saat yönünde artar.
/// Çark saat yönünde `rotation` kadar döndürülürse, ibrenin altındaki yerel açı
/// `(-rotation) mod 2π` olur ve dilim `i` yerel olarak `[i*sweep, (i+1)*sweep)` aralığını kaplar.
///
/// Bu sınıf %100 unit test edilir; animasyon ve çizim bu fonksiyonlara güvenir.
class SpinMath {
  const SpinMath._();

  /// Bir dilimin açı genişliği.
  static double sweep(int segmentCount) {
    if (segmentCount < 1) return 2 * math.pi;
    return (2 * math.pi) / segmentCount;
  }

  /// `rotation` açısındayken ibrenin altında duran dilimin indeksi.
  /// Her zaman `[0, segmentCount)` aralığında geçerli bir indeks döner.
  static int indexAtRotation(double rotation, int segmentCount) {
    if (segmentCount < 1) return 0;
    final double local = normalize(-rotation);
    final int index = (local / sweep(segmentCount)).floor() % segmentCount;
    return index < 0 ? index + segmentCount : index;
  }

  /// Dilimin tam ortasının ibre altında durması için gereken göreli açı.
  static double rotationForWinner(int winnerIndex, int segmentCount) {
    if (segmentCount < 1) return 0;
    final int safeIndex = winnerIndex % segmentCount;
    final double s = sweep(segmentCount);
    final double center = safeIndex * s + s / 2;
    return normalize(-center);
  }

  /// `from` açısından başlayıp `fullTurns` tam tur atarak `winnerIndex` diliminde
  /// duran hedef açı. Sonuç her zaman `from`'dan büyüktür: çark hep ileri döner.
  static double targetRotation({
    required double from,
    required int winnerIndex,
    required int segmentCount,
    required int fullTurns,
  }) {
    final double target = rotationForWinner(winnerIndex, segmentCount);
    final double delta = normalize(target - from);
    return from + 2 * math.pi * fullTurns + delta;
  }

  /// Adil kazanan: `Random.secure()` ile çağrıldığında sonuç önceden kestirilemez.
  static int randomWinner(int segmentCount, math.Random random) {
    if (segmentCount < 1) return 0;
    return random.nextInt(segmentCount);
  }

  /// Kaç tam tur atacağı. Gerçekçi görünmesi için 3-5 tur: daha az tur + yavaş
  /// yavaş azalan hız, çarkın dilimleri tek tek geçtiğini gözle görmeni sağlar.
  static int randomFullTurns(math.Random random, {int min = 3, int max = 5}) {
    return min + random.nextInt(max - min + 1);
  }

  /// Açıyı `[0, 2π)` aralığına indirger (negatif ve büyük açılara dayanıklı).
  static double normalize(double angle) {
    const double twoPi = 2 * math.pi;
    double result = angle % twoPi;
    if (result < 0) result += twoPi;
    return result;
  }
}
