import 'package:carkifelek/widgets/teq_splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

Widget _splash({
  required VoidCallback onDone,
  Duration duration = const Duration(milliseconds: 400),
}) {
  return TeqSplash(
    appName: 'Çarkıfelek',
    tagline: 'Kararsız kaldığın her an yanında.',
    stats: const <String>['66 hazır çark', '4 görünüm', '6 tema'],
    duration: duration,
    mark: (double rotation, double size) =>
        SizedBox(key: const Key('mark'), width: size, height: size),
    onDone: onDone,
  );
}

void main() {
  testWidgets('açılış ekranı adı, vaadi ve Teq Studio imzasını gösterir', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(_splash(onDone: () {}, duration: const Duration(seconds: 5))),
    );
    await tester.pump();

    expect(find.text('TEQ STUDIO'), findsOneWidget);
    expect(find.text('Çarkıfelek'), findsOneWidget);
    expect(find.text('Kararsız kaldığın her an yanında.'), findsOneWidget);
    expect(find.text('Developed by Teq Studio'), findsOneWidget);
    expect(find.text('66 hazır çark'), findsOneWidget);
    expect(find.byKey(const Key('mark')), findsOneWidget);
  });

  testWidgets('süre dolunca onDone bir kez çağrılır', (
    WidgetTester tester,
  ) async {
    int calls = 0;
    await tester.pumpWidget(_wrap(_splash(onDone: () => calls++)));

    await tester.pumpAndSettle();

    expect(calls, 1);
  });

  testWidgets('dokununca bekletmeden geçer', (WidgetTester tester) async {
    int calls = 0;
    await tester.pumpWidget(
      _wrap(
        _splash(onDone: () => calls++, duration: const Duration(seconds: 10)),
      ),
    );
    await tester.pump();

    await tester.tap(find.byType(TeqSplash));
    await tester.pump();

    expect(calls, 1);

    // Geri kalan animasyon bitse de ikinci kez çağrılmamalı.
    await tester.pumpAndSettle();
    expect(calls, 1);
  });

  testWidgets('hareket azaltma açıkken kısa sürede tamamlanır', (
    WidgetTester tester,
  ) async {
    int calls = 0;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: _wrap(
          _splash(onDone: () => calls++, duration: const Duration(seconds: 10)),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(calls, 1);
  });
}
