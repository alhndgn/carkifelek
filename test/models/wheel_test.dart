import 'dart:convert';

import 'package:carkifelek/models/wheel.dart';
import 'package:flutter_test/flutter_test.dart';

Wheel _sample() => Wheel(
  id: 'w1',
  title: 'Ne yesek?',
  segments: const <String>['Pizza', 'Kebap'],
  eliminateMode: true,
  spinDurationMs: 4200,
  soundOn: false,
  hapticsOn: false,
  updatedAt: DateTime.parse('2026-10-11T10:00:00.000'),
);

void main() {
  group('Wheel.normalizeSegments', () {
    test('kırpar, boşları atar, sırayı ve yinelenenleri korur', () {
      final List<String> result = Wheel.normalizeSegments(const <String>[
        '  Pizza ',
        '',
        '   ',
        'Kebap',
        'Pizza',
      ]);
      expect(result, <String>['Pizza', 'Kebap', 'Pizza']);
    });

    test('hiç geçerli metin yoksa boş liste döner', () {
      expect(Wheel.normalizeSegments(const <String>[' ', '\t', '']), isEmpty);
    });
  });

  group('Wheel JSON', () {
    test('toJson/fromJson gidiş-dönüş tüm alanları korur', () {
      final Wheel original = _sample();
      final Map<String, dynamic> json =
          jsonDecode(jsonEncode(original.toJson())) as Map<String, dynamic>;
      final Wheel restored = Wheel.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.segments, original.segments);
      expect(restored.eliminateMode, original.eliminateMode);
      expect(restored.spinDurationMs, original.spinDurationMs);
      expect(restored.soundOn, original.soundOn);
      expect(restored.hapticsOn, original.hapticsOn);
      expect(restored.updatedAt, original.updatedAt);
    });

    test('eksik alanlarda makul varsayılanlar kullanılır, kimlik üretilir', () {
      final Wheel wheel = Wheel.fromJson(const <String, dynamic>{});

      expect(wheel.id, isNotEmpty);
      expect(wheel.title, 'Adsız Çark');
      expect(wheel.segments, isEmpty);
      expect(wheel.eliminateMode, isFalse);
      expect(wheel.spinDurationMs, Wheel.defaultSpinDurationMs);
      expect(wheel.soundOn, isTrue);
      expect(wheel.hapticsOn, isTrue);
    });

    test('bozuk seçenek listesi temizlenir (metin olmayanlar düşer)', () {
      final Wheel wheel = Wheel.fromJson(<String, dynamic>{
        'title': 'Test',
        'segments': <Object?>[' Ali ', 42, null, 'Doğan', ''],
      });

      expect(wheel.segments, <String>['Ali', 'Doğan']);
    });

    test('dönüş süresi sınırların dışındaysa kırpılır', () {
      expect(
        Wheel.fromJson(<String, dynamic>{'spinDurationMs': 100}).spinDurationMs,
        Wheel.minSpinDurationMs,
      );
      expect(
        Wheel.fromJson(<String, dynamic>{'spinDurationMs': 999999})
            .spinDurationMs,
        Wheel.maxSpinDurationMs,
      );
      expect(
        Wheel.fromJson(<String, dynamic>{'spinDurationMs': 'yavaş'})
            .spinDurationMs,
        Wheel.defaultSpinDurationMs,
      );
    });

    test('soundOn:false ve eliminateMode:true doğru okunur', () {
      final Wheel wheel = Wheel.fromJson(<String, dynamic>{
        'soundOn': false,
        'hapticsOn': false,
        'eliminateMode': true,
      });
      expect(wheel.soundOn, isFalse);
      expect(wheel.hapticsOn, isFalse);
      expect(wheel.eliminateMode, isTrue);
    });
  });

  group('Wheel davranışı', () {
    test('2 seçenekten azsa çark dönemez', () {
      final Wheel one = _sample().copyWith(segments: const <String>['tek']);
      expect(one.canSpin, isFalse);
      expect(_sample().canSpin, isTrue);
    });

    test('24 seçeneğin üstü uyarı bayrağını açar', () {
      final Wheel many = _sample().copyWith(
        segments: List<String>.generate(25, (int i) => 'Seçenek $i'),
      );
      expect(many.hasManySegments, isTrue);
      expect(
        _sample()
            .copyWith(
              segments: List<String>.generate(24, (int i) => 'Seçenek $i'),
            )
            .hasManySegments,
        isFalse,
      );
    });

    test('copyWith kimliği korur', () {
      final Wheel original = _sample();
      final Wheel renamed = original.copyWith(title: 'Ne içsek?');
      expect(renamed.id, original.id);
      expect(renamed.title, 'Ne içsek?');
      expect(renamed.segments, original.segments);
    });
  });
}
