import 'dart:math' as math;

import 'package:carkifelek/core/friction_curve.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sayısal türev (hız); sınırlarda tek taraflı fark kullanır.
double _velocity(Curve curve, double u, {double h = 1e-4}) {
  final double lower = math.max(0.0, u - h);
  final double upper = math.min(1.0, u + h);
  return (curve.transform(upper) - curve.transform(lower)) /
      (upper - lower);
}

void main() {
  const FrictionCurve curve = FrictionCurve();

  group('uç noktalar (sonucun doğru dilimde durması buna bağlı)', () {
    test('transform(0) = 0 ve transform(1) = 1 (tam)', () {
      expect(curve.transform(0), 0.0);
      expect(curve.transform(1), 1.0);
    });

    test('ara değerler [0, 1+settle] aralığında kalır', () {
      for (int i = 0; i <= 100; i++) {
        final double value = curve.transform(i / 100);
        expect(value, greaterThanOrEqualTo(0));
        expect(value, lessThanOrEqualTo(1 + curve.settleOvershoot + 1e-9));
      }
    });
  });

  group('hız profili', () {
    test('duruştan başlar: başlangıç hızı çok küçük (ani fırlama yok)', () {
      final double v0 = _velocity(curve, 0.0);
      final double peak = _peakVelocity(curve);
      expect(v0 / peak, lessThan(0.05));
    });

    test('tepe hıza hızlanma evresinde ulaşır', () {
      double best = 0;
      double bestAt = 0;
      for (int i = 0; i <= 200; i++) {
        final double u = i / 200;
        final double v = _velocity(curve, u);
        if (v > best) {
          best = v;
          bestAt = u;
        }
      }
      expect(bestAt, lessThanOrEqualTo(curve.rampFraction + 0.02));
      expect(bestAt, greaterThan(0.0));
    });

    test('hızlanma → yavaşlama geçişinde kırılma yok (C1 süreklilik)', () {
      final double a = curve.rampFraction;
      final double before = _velocity(curve, a - 0.001);
      final double after = _velocity(curve, a + 0.001);
      expect((before - after).abs() / before, lessThan(0.05));
    });

    test('son hız sıfıra iner: son kare sert duruş yapmaz', () {
      final double peak = _peakVelocity(curve);
      expect(_velocity(curve, 1.0) / peak, lessThan(0.02));
      expect(_velocity(curve, 0.995) / peak, lessThan(0.06));
    });

    test('yavaşlama dönüşün tamamına yayılır (easeOutQuart gibi ölmüyor)', () {
      // Zamanın son %20'sinde alınan yol: sürtünme eğrisi easeOutQuart'ın
      // ölçülen ~3 katı. "Bir anda durdu" hissinin kaynağı buydu.
      final double frictionTail = curve.transform(1) - curve.transform(0.8);
      final double quartTail =
          Curves.easeOutQuart.transform(1) - Curves.easeOutQuart.transform(0.8);
      // ignore: avoid_print
      print(
        '\n  son %20 zaman diliminde alınan yol: '
        'sürtünme=${(frictionTail * 100).toStringAsFixed(2)}%  '
        'easeOutQuart=${(quartTail * 100).toStringAsFixed(2)}%  '
        '(oran ${(frictionTail / quartTail).toStringAsFixed(1)}x)',
      );

      expect(frictionTail, greaterThan(0.015));
      expect(frictionTail / quartTail, greaterThan(2));
    });

    test('orta noktada hâlâ belirgin hız var', () {
      final double peak = _peakVelocity(curve);
      expect(_velocity(curve, 0.5) / peak, greaterThan(0.25));
      expect(_velocity(curve, 0.8) / peak, greaterThan(0.05));
    });

    test('ileri yönde artar (settle başlangıcına kadar)', () {
      double previous = 0;
      for (int i = 0; i <= 80; i++) {
        final double value = curve.transform(i / 100 * curve.settleStart);
        expect(value, greaterThanOrEqualTo(previous - 1e-12));
        previous = value;
      }
    });

    test('yerine oturma: hedefin az ötesine geçip geri döner', () {
      double maxValue = 0;
      for (int i = 0; i <= 500; i++) {
        maxValue = math.max(maxValue, curve.transform(i / 500));
      }
      expect(maxValue, greaterThan(1.0));
      expect(maxValue, lessThan(1.0 + curve.settleOvershoot + 1e-9));
      expect(curve.transform(1), 1.0);
    });
  });

  group('gerçek dönüş üzerinde ölçüm', () {
    test('4 tur / 5 sn / 8 dilim için hız tablosu', () {
      const double duration = 5.0;
      const double distance = 4 * 2 * math.pi;
      const int segments = 8;
      final double segmentAngle = 2 * math.pi / segments;

      final StringBuffer out = StringBuffer()
        ..writeln('\n  zaman   konum%   hız(°/sn)   dilim/sn')
        ..writeln('  ---------------------------------------');

      for (int i = 0; i <= 10; i++) {
        final double u = i / 10;
        final double position = curve.transform(u);
        final double radPerSec =
            _velocity(curve, u, h: 0.002) * distance / duration;
        out.writeln(
          '  ${(u * duration).toStringAsFixed(1).padLeft(4)}s'
          '  ${(position * 100).toStringAsFixed(1).padLeft(6)}'
          '   ${(radPerSec * 180 / math.pi).toStringAsFixed(0).padLeft(8)}'
          '   ${(radPerSec / segmentAngle).toStringAsFixed(2).padLeft(7)}',
        );
      }
      // ignore: avoid_print
      print(out.toString());

      // Son saniyede hâlâ gözle görülür hareket var, ama yavaşlamış:
      final double lastSecond =
          (curve.transform(1) - curve.transform(0.8)) * distance;
      expect(lastSecond * 180 / math.pi, greaterThan(15)); // >15°
      expect(lastSecond * 180 / math.pi, lessThan(90)); //  <90°
    });
  });
}

double _peakVelocity(Curve curve) {
  double best = 0;
  for (int i = 0; i <= 400; i++) {
    best = math.max(best, _velocity(curve, i / 400));
  }
  return best;
}
