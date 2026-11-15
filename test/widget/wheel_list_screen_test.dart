import 'dart:convert';

import 'package:carkifelek/app.dart';
import 'package:carkifelek/models/wheel.dart';
import 'package:carkifelek/state/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpApp(WidgetTester tester) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        // Açılış ekranını atla; testler doğrudan çark listesini görsün.
        splashEnabledProvider.overrideWithValue(false),
      ],
      child: const CarkifelekApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('çark yokken karşılama ekranı ve şablonlar görünür', (
    WidgetTester tester,
  ) async {
    await _pumpApp(tester);

    expect(find.text('Henüz çarkın yok'), findsOneWidget);
    expect(find.text('Kim ısmarlayacak?'), findsOneWidget);
    expect(find.text('Sıfırdan çark oluştur'), findsOneWidget);
  });

  testWidgets('şablona dokununca çark oluşur ve listede görünür', (
    WidgetTester tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Kim ısmarlayacak?'));
    await tester.pumpAndSettle();

    expect(find.text('Henüz çarkın yok'), findsNothing);
    expect(find.text('Kim ısmarlayacak?'), findsOneWidget);
    expect(find.textContaining('5 seçenek'), findsOneWidget);
  });

  testWidgets('yeni çark dialogu ile başlık verilerek çark oluşturulur', (
    WidgetTester tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Yeni Çark'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Test Çarkı');
    await tester.tap(find.text('Oluştur'));
    await tester.pumpAndSettle();

    expect(find.text('Test Çarkı'), findsOneWidget);
  });

  testWidgets('kayıtlı çark açılışta listede gelir ve detay ekranı açılır', (
    WidgetTester tester,
  ) async {
    final Wheel seeded = Wheel(
      id: 'seed-1',
      title: 'Ne yesek?',
      segments: const <String>['Pizza', 'Kebap'],
      updatedAt: DateTime.parse('2026-10-11T09:00:00.000'),
    );
    SharedPreferences.setMockInitialValues(<String, Object>{
      'wheels_v1': jsonEncode(<Object?>[seeded.toJson()]),
    });

    await _pumpApp(tester);

    expect(find.text('Ne yesek?'), findsOneWidget);
    expect(find.text('Henüz çarkın yok'), findsNothing);

    await tester.tap(find.text('Ne yesek?'));
    await tester.pumpAndSettle();

    // Çark ekranı açıldı: seçenekler artık çarkın üzerine çizildiği için
    // metin olarak değil, çevir düğmesi + seçenek sayısı ile doğruluyoruz.
    expect(find.text('ÇEVİR'), findsOneWidget);
    expect(find.text('2 seçenek'), findsOneWidget);
  });

  testWidgets('uzun basınca çıkan menüden çark silinebilir', (
    WidgetTester tester,
  ) async {
    final Wheel seeded = Wheel(
      id: 'seed-2',
      title: 'Silinecek Çark',
      segments: const <String>['A', 'B'],
      updatedAt: DateTime.parse('2026-10-11T09:00:00.000'),
    );
    SharedPreferences.setMockInitialValues(<String, Object>{
      'wheels_v1': jsonEncode(<Object?>[seeded.toJson()]),
    });

    await _pumpApp(tester);

    await tester.longPress(find.text('Silinecek Çark'));
    await tester.pumpAndSettle();
    expect(find.text('Çoğalt'), findsOneWidget);

    await tester.tap(find.text('Sil'));
    await tester.pumpAndSettle();

    expect(find.text('Çarkı sil'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Sil'));
    await tester.pumpAndSettle();

    expect(find.text('Silinecek Çark'), findsNothing);
    expect(find.text('Henüz çarkın yok'), findsOneWidget);
  });
}
