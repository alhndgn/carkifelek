import 'dart:math' as math;

import 'package:carkifelek/core/spin_math.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('sweep', () {
    test('dilim açısı 2π/n', () {
      expect(SpinMath.sweep(2), closeTo(math.pi, 1e-12));
      expect(SpinMath.sweep(4), closeTo(math.pi / 2, 1e-12));
      expect(SpinMath.sweep(12), closeTo(math.pi / 6, 1e-12));
    });

    test('anlamsız dilim sayısında tam tur döner', () {
      expect(SpinMath.sweep(0), closeTo(2 * math.pi, 1e-12));
      expect(SpinMath.sweep(-3), closeTo(2 * math.pi, 1e-12));
    });
  });

  group('indexAtRotation', () {
    test('dönmemiş çarkta ibre 0. dilimin üstünde', () {
      expect(SpinMath.indexAtRotation(0, 4), 0);
    });

    test('45° ileri dönen çarkta ibre son dilime kayar', () {
      // Çark saat yönünde π/4 dönerse ibre, 270°-360° aralığındaki dilimin üstünde kalır.
      expect(SpinMath.indexAtRotation(math.pi / 4, 4), 3);
    });

    test('tam tur eklemek sonucu değiştirmez', () {
      const double base = 1.1;
      for (int turns = 0; turns < 4; turns++) {
        expect(
          SpinMath.indexAtRotation(base + turns * 2 * math.pi, 7),
          SpinMath.indexAtRotation(base, 7),
        );
      }
    });

    test('negatif ve çok büyük açılarda geçerli indeks döner', () {
      for (final double rotation in <double>[-100, -0.001, 0, 999.9, 123456.7]) {
        for (int count = 1; count <= 24; count++) {
          final int index = SpinMath.indexAtRotation(rotation, count);
          expect(index, greaterThanOrEqualTo(0));
          expect(index, lessThan(count));
        }
      }
    });

    test('dilim sınırındaki açı bir sonraki dilime aittir', () {
      // local açı tam π/2 ise 1. dilimin başlangıcıdır (count=4).
      expect(SpinMath.indexAtRotation(-math.pi / 2, 4), 1);
    });
  });

  group('rotationForWinner / targetRotation', () {
    test('2-24 dilim ve her kazanan için doğru dilimde duruyor', () {
      for (int count = 2; count <= 24; count++) {
        for (int winner = 0; winner < count; winner++) {
          final double rotation = SpinMath.rotationForWinner(winner, count);
          expect(
            SpinMath.indexAtRotation(rotation, count),
            winner,
            reason: 'count=$count winner=$winner',
          );
        }
      }
    });

    test('hedef açı her zaman ileri yönde ve en az fullTurns tam tur', () {
      const int count = 6;
      final math.Random random = math.Random(1234);
      for (int i = 0; i < 200; i++) {
        final double from = random.nextDouble() * 500 - 250;
        final int winner = random.nextInt(count);
        final int turns = SpinMath.randomFullTurns(random);
        final double target = SpinMath.targetRotation(
          from: from,
          winnerIndex: winner,
          segmentCount: count,
          fullTurns: turns,
        );

        expect(target, greaterThan(from));
        expect(
          target - from,
          greaterThanOrEqualTo(turns * 2 * math.pi - 1e-9),
        );
        expect(SpinMath.indexAtRotation(target, count), winner);
      }
    });

    test('kazananın tam ortasına denk gelir (dilim kenarına yapışmaz)', () {
      for (int count = 2; count <= 24; count++) {
        for (int winner = 0; winner < count; winner++) {
          final double rotation = SpinMath.rotationForWinner(winner, count);
          final double sweep = SpinMath.sweep(count);
          final double local = SpinMath.normalize(-rotation);
          final double offsetInSegment = local - winner * sweep;
          expect(offsetInSegment, closeTo(sweep / 2, 1e-9));
        }
      }
    });
  });

  group('rastgelelik', () {
    test('randomWinner her zaman geçerli indeks', () {
      final math.Random random = math.Random(7);
      for (int i = 0; i < 2000; i++) {
        final int winner = SpinMath.randomWinner(9, random);
        expect(winner, greaterThanOrEqualTo(0));
        expect(winner, lessThan(9));
      }
    });

    test('10.000 çevirmede dağılım tekdüze (adil çark)', () {
      final math.Random random = math.Random.secure();
      const int count = 5;
      const int spins = 10000;
      final List<int> histogram = List<int>.filled(count, 0);

      for (int i = 0; i < spins; i++) {
        histogram[SpinMath.randomWinner(count, random)]++;
      }

      for (int index = 0; index < count; index++) {
        final double share = histogram[index] / spins;
        expect(
          share,
          inInclusiveRange(0.15, 0.25),
          reason: 'dilim $index payı $share — çark adil değil',
        );
      }
    });

    test('tam tur sayısı 3-5 arasında kalır', () {
      final math.Random random = math.Random(99);
      final Set<int> seen = <int>{};
      for (int i = 0; i < 500; i++) {
        final int turns = SpinMath.randomFullTurns(random);
        expect(turns, inInclusiveRange(3, 5));
        seen.add(turns);
      }
      expect(seen, <int>{3, 4, 5});
    });
  });

  group('normalize', () {
    test('negatif, büyük ve tam kat açılar', () {
      expect(SpinMath.normalize(0), 0);
      expect(SpinMath.normalize(2 * math.pi), closeTo(0, 1e-9));
      expect(SpinMath.normalize(-math.pi / 2), closeTo(3 * math.pi / 2, 1e-9));
      expect(SpinMath.normalize(9 * math.pi), closeTo(math.pi, 1e-9));
    });
  });
}
