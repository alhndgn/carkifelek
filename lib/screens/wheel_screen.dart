import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/wheel.dart';
import '../state/wheel_list_provider.dart';
import '../theme/palette.dart';
import '../theme/spacing.dart';
import '../widgets/app_background.dart';
import '../widgets/mini_wheel.dart';

/// Çark ekranının ilk sürümü (M1): çarkın seçeneklerini önizler.
/// Dönüş animasyonu, ibre ve sonuç kartı M2'de bu ekrana eklenir.
class WheelScreen extends ConsumerWidget {
  const WheelScreen({super.key, required this.wheelId});

  final String wheelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Wheel? wheel = ref.watch(
      wheelListProvider.select(
        (List<Wheel> wheels) =>
            wheels.where((Wheel w) => w.id == wheelId).firstOrNull,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(wheel?.title ?? 'Çark'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: AppBackground(
        child: SafeArea(
          child: wheel == null
              ? const Center(
                  child: Text(
                    'Bu çark bulunamadı.',
                    style: TextStyle(color: kTextSecondary),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(Spacing.lg),
                  child: Column(
                    children: <Widget>[
                      MiniWheel(
                        segmentCount: wheel.segments.length,
                        size: 180,
                      ),
                      const SizedBox(height: Spacing.lg),
                      Text(
                        '${wheel.segments.length} seçenek',
                        style: const TextStyle(
                          fontSize: 16,
                          color: kTextSecondary,
                        ),
                      ),
                      const SizedBox(height: Spacing.md),
                      Expanded(
                        child: ListView(
                          children: wheel.segments
                              .map(
                                (String segment) => Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: Spacing.xs,
                                  ),
                                  child: Text(
                                    '•  $segment',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: kTextPrimary,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: Spacing.md),
                      const Text(
                        'Dönüş animasyonu ve sonuç ekranı bir sonraki adımda (M2) geliyor.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: kTextSecondary),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
