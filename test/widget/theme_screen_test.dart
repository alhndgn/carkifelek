import 'package:carkifelek/screens/theme_screen.dart';
import 'package:carkifelek/state/app_providers.dart';
import 'package:carkifelek/state/theme_provider.dart';
import 'package:carkifelek/theme/app_palette.dart';
import 'package:carkifelek/theme/app_theme.dart';
import 'package:carkifelek/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pump(WidgetTester tester) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: MaterialApp(theme: AppTheme.dark(), home: const ThemeScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    setActivePalette('gece');
  });

  testWidgets('temalar listelenir', (WidgetTester tester) async {
    await _pump(tester);

    expect(find.text('Tema'), findsOneWidget);
    for (final AppPalette p in kAppPalettes.take(2)) {
      expect(find.text(p.name), findsOneWidget);
    }
    expect(kAppPalettes.length, 6);
  });

  testWidgets('tema seçilince aktif palet değişir ve kaydedilir', (
    WidgetTester tester,
  ) async {
    await _pump(tester);

    await tester.tap(find.text('Okyanus'));
    await tester.pumpAndSettle();

    expect(activePalette.id, 'okyanus');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(ThemeNotifier.storageKey), 'okyanus');
  });

  testWidgets('seçili tema kartı işaretlidir', (WidgetTester tester) async {
    await _pump(tester);

    // Varsayılan tema Gece: kartında onay ikonu görünür, diğerlerinde çember.
    expect(find.byIcon(Icons.check_circle), findsOneWidget);

    await tester.tap(find.text('Orman'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(activePalette.id, 'orman');
  });
}
