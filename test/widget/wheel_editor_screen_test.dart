import 'dart:convert';

import 'package:carkifelek/data/key_value_store.dart';
import 'package:carkifelek/data/wheel_repository.dart';
import 'package:carkifelek/models/wheel.dart';
import 'package:carkifelek/screens/wheel_editor_screen.dart';
import 'package:carkifelek/state/app_providers.dart';
import 'package:carkifelek/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Wheel _wheel(List<String> segments) => Wheel(
  id: 'e1',
  title: 'Ne yesek?',
  segments: segments,
  updatedAt: DateTime.parse('2026-10-11T12:00:00.000'),
);

void main() {
  late InMemoryStore store;

  Widget editorApp(Wheel wheel) {
    store = InMemoryStore(<String, String>{
      WheelRepository.storageKey: jsonEncode(<Object?>[wheel.toJson()]),
    });
    return ProviderScope(
      overrides: [
        wheelRepositoryProvider.overrideWithValue(WheelRepository(store)),
      ],
      child: MaterialApp(
        theme: AppTheme.dark(),
        home: WheelEditorScreen(wheelId: wheel.id),
      ),
    );
  }

  String storedJson() => store.read(WheelRepository.storageKey) ?? '';

  Finder dialogText(String text) => find.descendant(
    of: find.byType(AlertDialog),
    matching: find.text(text),
  );

  Finder dialogField() => find.descendant(
    of: find.byType(AlertDialog),
    matching: find.byType(TextField),
  );

  testWidgets('seçenekleri listeler ve sayıyı gösterir', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(editorApp(_wheel(<String>['Ali', 'Doğan'])));

    expect(find.text('2 seçenek'), findsOneWidget);
    expect(find.text('Ali'), findsOneWidget);
    expect(find.text('Doğan'), findsOneWidget);
  });

  testWidgets('tek tek ekleme yapar, kırpar ve alanı temizler', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(editorApp(_wheel(<String>['Ali', 'Doğan'])));

    await tester.enterText(find.byType(TextField), '  Mehmet  ');
    await tester.tap(find.text('Ekle'));
    await tester.pumpAndSettle();

    expect(find.text('3 seçenek'), findsOneWidget);
    expect(find.text('Mehmet'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).controller?.text, '');
  });

  testWidgets('kaydet diske yazar', (WidgetTester tester) async {
    await tester.pumpWidget(editorApp(_wheel(<String>['Ali', 'Doğan'])));

    await tester.enterText(find.byType(TextField), 'Mehmet');
    await tester.tap(find.text('Ekle'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    expect(storedJson(), contains('Mehmet'));
    expect(find.text('3 seçenek kaydedildi'), findsOneWidget);
  });

  testWidgets('seçenek silinebilir', (WidgetTester tester) async {
    await tester.pumpWidget(editorApp(_wheel(<String>['Ali', 'Doğan'])));

    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pumpAndSettle();

    expect(find.text('Ali'), findsNothing);
    expect(find.text('1 seçenek'), findsOneWidget);
    expect(
      find.text('Çarkın dönebilmesi için en az 2 seçenek gerekli.'),
      findsOneWidget,
    );
  });

  testWidgets('toplu ekleme: her satır bir seçenek, boş satırlar atılır', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(editorApp(_wheel(<String>['Ali'])));

    await tester.tap(find.text('Toplu ekle'));
    await tester.pumpAndSettle();

    await tester.enterText(
      dialogField(),
      'Alihan\n\n  Doğan  \nMehmet\n   \nAhmet',
    );
    await tester.tap(dialogText('Ekle'));
    await tester.pumpAndSettle();

    // 1 (mevcut) + 4 (yeni) = 5
    expect(find.text('5 seçenek'), findsOneWidget);
    expect(find.text('4 seçenek eklendi'), findsOneWidget);
    expect(find.text('Doğan'), findsOneWidget);
  });

  testWidgets('tek satırlık bozuk yapıştırma listeyi bozmaz', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(editorApp(_wheel(<String>['Ali'])));

    await tester.tap(find.text('Toplu ekle'));
    await tester.pumpAndSettle();
    await tester.enterText(dialogField(), '   \n  \n');
    await tester.tap(dialogText('Ekle'));
    await tester.pumpAndSettle();

    expect(find.text('1 seçenek'), findsOneWidget);
  });

  testWidgets('yinelenen seçenekler uyarı gösterir ama engellenmez', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(editorApp(_wheel(<String>['Ali', 'Ali', 'Doğan'])));

    expect(find.text('3 seçenek'), findsOneWidget);
    expect(find.textContaining('birden fazla kez'), findsOneWidget);
  });

  testWidgets('24 seçeneğin üstünde okunabilirlik uyarısı çıkar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      editorApp(_wheel(List<String>.generate(25, (int i) => 'Seçenek $i'))),
    );

    expect(find.textContaining('okunması zor olabilir'), findsOneWidget);
  });

  testWidgets('sürükleyerek sıralama değişir ve kaydedilir', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(editorApp(_wheel(<String>['Ali', 'Doğan'])));

    final Finder handle = find.byIcon(Icons.drag_handle).first;
    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(handle),
    );
    await tester.pump(const Duration(milliseconds: 80));
    // Kademeli hareket: ReorderableListView kare kare yer değiştirir.
    for (int i = 0; i < 6; i++) {
      await gesture.moveBy(const Offset(0, 25));
      await tester.pump(const Duration(milliseconds: 30));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    final String json = storedJson();
    expect(
      json.indexOf('Doğan') < json.indexOf('Ali'),
      isTrue,
      reason: 'sıralama değişmedi: $json',
    );
  });

  testWidgets('kaydedilmemiş değişiklikle çıkışta onay ister', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(editorApp(_wheel(<String>['Ali', 'Doğan'])));

    await tester.enterText(find.byType(TextField), 'Mehmet');
    await tester.tap(find.text('Ekle'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Kaydedilmeyen değişiklikler'), findsOneWidget);
    expect(dialogText('Kaydetmeden çık'), findsOneWidget);
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
          home: const WheelEditorScreen(wheelId: 'yok'),
        ),
      ),
    );

    expect(find.text('Bu çark bulunamadı.'), findsOneWidget);
  });
}
