import 'dart:convert';

import 'package:carkifelek/data/key_value_store.dart';
import 'package:carkifelek/data/wheel_repository.dart';
import 'package:carkifelek/models/wheel.dart';
import 'package:carkifelek/models/wheel_style.dart';
import 'package:carkifelek/screens/wheel_screen.dart';
import 'package:carkifelek/state/app_providers.dart';
import 'package:carkifelek/theme/app_theme.dart';
import 'package:carkifelek/widgets/spin_wheel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

  testWidgets('ayarlarda dört çark görünümü listelenir', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      appWith(
        Wheel(
          id: 'w1',
          title: 'Test Çarkı',
          segments: const <String>['Ali', 'Doğan', 'Can'],
          updatedAt: DateTime.parse('2026-10-11T12:00:00.000'),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();

    expect(find.text('Çark görünümü'), findsOneWidget);
    for (final WheelStyle style in WheelStyle.values) {
      expect(find.text(style.label), findsOneWidget);
    }
  });

  testWidgets('görünüm seçilince kaydedilir ve çarka yansır', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      appWith(
        Wheel(
          id: 'w1',
          title: 'Test Çarkı',
          segments: const <String>['Ali', 'Doğan', 'Can'],
          updatedAt: DateTime.parse('2026-10-11T12:00:00.000'),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Hedef'));
    await tester.pumpAndSettle();

    expect(storedJson(), contains('"style":"target"'));

    // Sayfa kapanınca çark yeni görünümle çizilmeli.
    await tester.tapAt(const Offset(200, 60)); // bariyer: sheet'i kapat
    await tester.pumpAndSettle();
    final SpinWheel wheelWidget = tester.widget<SpinWheel>(
      find.byType(SpinWheel),
    );
    expect(wheelWidget.style, WheelStyle.target);
  });
}
