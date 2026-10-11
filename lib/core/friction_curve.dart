import 'dart:math' as math;

import 'package:flutter/animation.dart';

/// Gerçekçi çark dönüşü eğrisi.
///
/// Hız profili üç parçalıdır ve konum fonksiyonu tam olarak `0 → 1` gider
/// (`transform(0) == 0`, `transform(1) == 1`), böylece çark her zaman
/// hesaplanan kazanan dilimin tam ortasında durur.
///
/// 1. **Hızlanma** (`rampFraction`): duruştan tepe hıza yumuşak çıkış. Çark
///    "bir anda fırlamış" gibi görünmez; elle çevrilmiş hissi verir.
/// 2. **Sürtünmeyle yavaşlama**: hız `(1-u)^decayPower` ile azalır — yani
///    yavaşlama dönüşün tamamına yayılır. `easeOutQuart` gibi ilk saniyede
///    bitip sonra ölü gibi sürünmez; her an gözle görülür şekilde yavaşlar ve
///    son anda hız sıfıra iner (sert duruş yok).
/// 3. **Yerine oturma** (`settleStart` sonrası): hedefin çok az ötesine geçip
///    geri dönen küçük bir salınım; gerçek çarklardaki "tık, yerine oturdu"
///    hissini verir.
class FrictionCurve extends Curve {
  const FrictionCurve({
    this.rampFraction = 0.08,
    this.decayPower = 1.4,
    this.settleOvershoot = 0.0008,
    this.settleStart = 0.82,
  }) : assert(rampFraction >= 0 && rampFraction < 0.5),
       assert(decayPower > 0),
       assert(settleOvershoot >= 0),
       assert(settleStart > 0 && settleStart < 1);

  /// Toplam sürenin ne kadarında tepe hıza çıkılır (0.08 = %8).
  final double rampFraction;

  /// Sürtünme şiddeti: büyük değer = daha çabuk yavaşlama (1.0 = doğrusal).
  final double decayPower;

  /// Hedefin ne kadar ötesine geçilir (toplam dönüşün oranı olarak).
  final double settleOvershoot;

  /// Yerine oturma salınımının başladığı an (0-1).
  final double settleStart;

  /// Hızlanma evresinde alınan yol.
  double get _gainRamp => rampFraction <= 0 ? 0 : rampFraction / 2;

  /// Yavaşlama evresinde alınan yol.
  double get _gainDecay =>
      rampFraction <= 0
      ? 1 / (decayPower + 1)
      : (1 - rampFraction) / (decayPower + 1);

  double get _totalGain => _gainRamp + _gainDecay;

  /// Yerine oturma salınımı hariç konum (normalize edilmiş).
  double _basePosition(double u) {
    if (rampFraction <= 0) {
      return (1 - math.pow(1 - u, decayPower + 1).toDouble()) /
          (decayPower + 1);
    }
    if (u <= rampFraction) {
      return (u * u) / (2 * rampFraction);
    }
    final double remaining = (1 - u) / (1 - rampFraction);
    return _gainRamp +
        (1 - rampFraction) *
            (1 - math.pow(remaining, decayPower + 1).toDouble()) /
            (decayPower + 1);
  }

  @override
  double transformInternal(double t) {
    final double u = t.clamp(0.0, 1.0);
    double position = _basePosition(u) / _totalGain;

    if (settleOvershoot > 0 && u > settleStart) {
      // s=0 ve s=1'de değeri ve türevi sıfır olan yumuşak bir tümsek:
      // hızda kırılma yaratmadan hedefin az ötesine geçip geri döner.
      final double s = (u - settleStart) / (1 - settleStart);
      final double bump = 16 * s * s * (1 - s) * (1 - s);
      position += settleOvershoot * bump;
    }

    return position;
  }

  @override
  String toString() =>
      'FrictionCurve(ramp: $rampFraction, decay: $decayPower, '
      'settle: $settleOvershoot)';
}
