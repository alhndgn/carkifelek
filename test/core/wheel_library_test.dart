import 'package:carkifelek/core/wheel_library.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('kütüphane 66 çark içerir', () {
    expect(kWheelLibrary.length, 66);
  });

  test('çark adları benzersizdir', () {
    final Set<String> titles = kWheelLibrary
        .map((LibraryWheel w) => w.title)
        .toSet();
    expect(titles.length, kWheelLibrary.length);
  });

  test('her çarkta 6-16 seçenek vardır, emoji dolu', () {
    for (final LibraryWheel w in kWheelLibrary) {
      expect(w.segments.length, inInclusiveRange(6, 16), reason: w.title);
      expect(w.emoji.trim().isNotEmpty, isTrue, reason: w.title);
      expect(w.title.trim().isNotEmpty, isTrue);
    }
  });

  test('her çarkın içinde yinelenen seçenek yok', () {
    for (final LibraryWheel w in kWheelLibrary) {
      expect(w.segments.toSet().length, w.segments.length, reason: w.title);
    }
  });

  test(
    'tüm kategoriler geçerli listede ve her kategoride en az 3 çark var',
    () {
      expect(kWheelCategories.length, 12);
      for (final LibraryWheel w in kWheelLibrary) {
        expect(kWheelCategories, contains(w.category), reason: w.title);
      }
      for (final String cat in kWheelCategories) {
        final int count = kWheelLibrary
            .where((LibraryWheel w) => w.category == cat)
            .length;
        expect(count, greaterThanOrEqualTo(3), reason: cat);
      }
    },
  );
}
