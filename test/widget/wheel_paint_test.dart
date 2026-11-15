import 'dart:math' as math;

import 'package:carkifelek/models/wheel_style.dart';
import 'package:carkifelek/theme/app_theme.dart';
import 'package:carkifelek/widgets/spin_wheel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Her görünüm gerçekten çizilebiliyor mu? Yeni çizim yollarında yol
/// matematiği bozulursa (Path hatası, sonsuz döngü, taşma) burada yakalanır.
void main() {
  for (final WheelStyle style in WheelStyle.values) {
    testWidgets('${style.id} görünümü hatasız çizilir', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 320,
                height: 320,
                child: SpinWheel(
                  segments: const <String>[
                    'Ali',
                    'Veli',
                    'Ayşe',
                    'Fatma',
                    'Can',
                    'Ece',
                    'Ege',
                    'Selin',
                  ],
                  duration: const Duration(milliseconds: 200),
                  random: math.Random(7),
                  style: style,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byType(SpinWheel), findsOneWidget);
    });
  }

  testWidgets('tek seçenekli çarkta da yeni görünümler çökmez', (
    WidgetTester tester,
  ) async {
    for (final WheelStyle style in WheelStyle.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 240,
                height: 240,
                child: SpinWheel(
                  segments: const <String>['Tek'],
                  duration: const Duration(milliseconds: 200),
                  style: style,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull, reason: style.id);
    }
  });
}
