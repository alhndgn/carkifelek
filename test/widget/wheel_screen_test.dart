import 'dart:convert';

import 'package:carkifelek/data/key_value_store.dart';
import 'package:carkifelek/data/wheel_repository.dart';
import 'package:carkifelek/models/wheel.dart';
import 'package:carkifelek/screens/wheel_screen.dart';
import 'package:carkifelek/state/app_providers.dart';
import 'package:carkifelek/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Wheel _wheel({
  required String id,
  required List<String> segments,
  bool eliminateMode = false,
  int spinDurationMs = Wheel.minSpinDurationMs,
}) => Wheel(
  id: id,
  title: 'Test Çarkı',
  segments: segments,
  eliminateMode: eliminateMode,
  spinDurationMs: spinDurationMs,
  updatedAt: DateTime.parse('2026-10-11T12:00:00.000'),
);

void main() {
  late InMemoryStore store;

  Widget appWith(Wheel wheel) {
    store = InMemoryStore(<String, String>{
      WheelRepository.storageKey: jsonEncode(<Object?>[wheel.toJson()]),
    });
    return ProviderScope(
      overrides: [
        wheelRepositoryProvider.overrideWithValue(WheelRepository(store)),
      ],
      child: MaterialApp(
        theme: AppTheme.dark(),
        home: WheelScreen(wheelId: wheel.id),
      ),
    );
  }

  String storedJson() => store.read(WheelRepository.storageKey) ?? '';

  testWidgets('çark ekranı başlığı, çevir düğmesi ve seçenek sayısı görünür', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(appWith(_wheel(id: 'w1', segments: ['Ali', 'Doğan'])));

    expect(find.text('Test Çarkı'), findsOneWidget);
    expect(find.text('ÇEVİR'), findsOneWidget);
    expect(find.text('2 seçenek'), findsOneWidget);
    expect(find.text('En az 2 seçenek gerekli.'), findsNothing);
  });

  testWidgets('tek seçenek kalırsa çevirme kapalı ve uyarı görünür', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(appWith(_wheel(id: 'w1', segments: ['Ali'])));

    expect(find.text('En az 2 seçenek gerekli.'), findsOneWidget);

    await tester.tap(find.text('ÇEVİR'));
    await tester.pumpAndSettle();

    // Hiçbir sonuç kartı açılmamalı.
    expect(find.text('KAZANAN'), findsNothing);
  });

  testWidgets('çevirince çark döner, kazanan kartı açılır', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      appWith(_wheel(id: 'w1', segments: <String>['Ali', 'Doğan'])),
    );

    await tester.tap(find.text('ÇEVİR'));
    await tester.pump();

    // Dönüş başladı: göbekte ilerleme göstergesi var, düğme metni yok.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('KAZANAN'), findsOneWidget);
    final bool aliShown = find.text('Ali').evaluate().isNotEmpty;
    final bool doganShown = find.text('Doğan').evaluate().isNotEmpty;
    expect(aliShown || doganShown, isTrue);
    expect(find.text('Tekrar çevir'), findsOneWidget);

    await tester.tap(find.text('Tamam'));
    await tester.pumpAndSettle();
    expect(find.text('KAZANAN'), findsNothing);
  });

  testWidgets('eleme modunda kazanan listeden çıkar ve çark kilitlenir', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      appWith(
        _wheel(
          id: 'w1',
          segments: <String>['Ali', 'Doğan'],
          eliminateMode: true,
        ),
      ),
    );

    expect(find.text('eleme modu'), findsOneWidget);

    await tester.tap(find.text('ÇEVİR'));
    await tester.pumpAndSettle();

    expect(find.text('Bu seçenek listeden çıkarıldı (eleme modu)'), findsOneWidget);
    expect(find.text('Kazananı listeden çıkar'), findsNothing);

    await tester.tap(find.text('Tamam'));
    await tester.pumpAndSettle();

    // İki isimden biri silindi: kayıtta artık tek seçenek kaldı.
    final String json = storedJson();
    final bool hasAli = json.contains('Ali');
    final bool hasDogan = json.contains('Doğan');
    expect(hasAli && hasDogan, isFalse, reason: 'kazanan silinmedi: $json');
    expect(find.text('1 seçenek'), findsOneWidget);
    expect(find.text('En az 2 seçenek gerekli.'), findsOneWidget);
  });

  testWidgets('eleme modu kapalıyken tek seferlik çıkarma düğmesi çalışır', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      appWith(
        _wheel(id: 'w1', segments: <String>['Ali', 'Doğan', 'Mehmet']),
      ),
    );

    await tester.tap(find.text('ÇEVİR'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kazananı listeden çıkar'));
    await tester.pumpAndSettle();

    expect(find.text('3 seçenek'), findsNothing);
  });

  testWidgets('ayarlar: eleme modu açılınca kaydedilir ve çark ekranına yansır', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      appWith(_wheel(id: 'w1', segments: <String>['Ali', 'Doğan'])),
    );

    expect(find.text('eleme modu'), findsNothing);

    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();

    expect(find.text('Ayarlar'), findsOneWidget);
    expect(find.text('Tik sesi'), findsOneWidget);
    expect(find.text('Titreşim'), findsOneWidget);
    expect(find.text('Dönüş süresi'), findsOneWidget);

    await tester.tap(find.text('Eleme modu'));
    await tester.pumpAndSettle();

    expect(storedJson(), contains('"eliminateMode":true'));
    expect(find.text('eleme modu'), findsOneWidget);

    await tester.tap(find.text('Tik sesi'));
    await tester.pumpAndSettle();
    expect(storedJson(), contains('"soundOn":false'));
  });

  testWidgets('ayarlar: dönüş süresi kaydırıcısı süreyi değiştirir', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      appWith(
        _wheel(
          id: 'w1',
          segments: <String>['Ali', 'Doğan'],
          spinDurationMs: Wheel.minSpinDurationMs,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();

    expect(find.byType(Slider), findsOneWidget);
    await tester.drag(find.byType(Slider), const Offset(260, 0));
    await tester.pumpAndSettle();

    expect(storedJson(), isNot(contains('"spinDurationMs":3000')));
  });

  testWidgets('olmayan çark için bilgi mesajı gösterilir', (
    WidgetTester tester,
  ) async {
    store = InMemoryStore();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          wheelRepositoryProvider.overrideWithValue(WheelRepository(store)),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const WheelScreen(wheelId: 'yok'),
        ),
      ),
    );

    expect(find.text('Bu çark bulunamadı.'), findsOneWidget);
  });
}
