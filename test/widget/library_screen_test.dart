import 'package:carkifelek/core/wheel_library.dart';
import 'package:carkifelek/screens/library_screen.dart';
import 'package:carkifelek/state/app_providers.dart';
import 'package:carkifelek/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pump(WidgetTester tester) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: MaterialApp(theme: AppTheme.dark(), home: const LibraryScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  testWidgets('kütüphane hazır çarkları listeler', (WidgetTester tester) async {
    await _pump(tester);

    expect(find.text('Hazır çarklar'), findsOneWidget);
    expect(find.text(kWheelLibrary.first.title), findsOneWidget);
    expect(find.textContaining('seçenek'), findsWidgets);
  });

  testWidgets('kategori seçince liste filtrelenir', (
    WidgetTester tester,
  ) async {
    await _pump(tester);

    final LibraryWheel yemek = kWheelLibrary.firstWhere(
      (LibraryWheel w) => w.category == 'Yemek',
    );
    final LibraryWheel sosyal = kWheelLibrary.firstWhere(
      (LibraryWheel w) => w.category == 'Sosyal',
    );

    await tester.tap(find.text('Yemek').first);
    await tester.pumpAndSettle();

    expect(find.text(yemek.title), findsOneWidget);
    expect(find.text(sosyal.title), findsNothing);
  });

  testWidgets('çarka dokununca çark eklenir ve geri bildirim verilir', (
    WidgetTester tester,
  ) async {
    await _pump(tester);

    final LibraryWheel first = kWheelLibrary.first;
    await tester.tap(find.text(first.title));
    await tester.pumpAndSettle();

    expect(find.text('${first.title} eklendi'), findsOneWidget);
  });
}
