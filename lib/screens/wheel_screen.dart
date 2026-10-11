import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/wheel.dart';
import '../state/wheel_list_provider.dart';
import '../theme/palette.dart';
import '../theme/spacing.dart';
import '../widgets/app_background.dart';
import '../widgets/confetti.dart';
import '../widgets/spin_wheel.dart';
import '../widgets/winner_sheet.dart';

/// Çark ekranı: çarkı çevir, kazananı gör.
/// Dilim düzenleme ve ayarlar M3'te buraya eklenecek.
class WheelScreen extends ConsumerStatefulWidget {
  const WheelScreen({super.key, required this.wheelId});

  final String wheelId;

  @override
  ConsumerState<WheelScreen> createState() => _WheelScreenState();
}

class _WheelScreenState extends ConsumerState<WheelScreen> {
  final GlobalKey<SpinWheelState> _wheelKey = GlobalKey<SpinWheelState>();
  bool _confettiVisible = false;

  @override
  Widget build(BuildContext context) {
    final Wheel? wheel = ref.watch(
      wheelListProvider.select(
        (List<Wheel> wheels) =>
            wheels.where((Wheel w) => w.id == widget.wheelId).firstOrNull,
      ),
    );

    if (wheel == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Çark')),
        body: const AppBackground(
          child: Center(
            child: Text(
              'Bu çark bulunamadı.',
              style: TextStyle(color: kTextSecondary),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(wheel.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: <Widget>[
          if (wheel.eliminateMode)
            const Padding(
              padding: EdgeInsets.only(right: Spacing.md),
              child: Center(
                child: Text(
                  'eleme modu',
                  style: TextStyle(fontSize: 12, color: kTextSecondary),
                ),
              ),
            ),
        ],
      ),
      body: AppBackground(
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.md),
                      child: SpinWheel(
                        key: _wheelKey,
                        segments: wheel.segments,
                        duration: Duration(
                          milliseconds: wheel.spinDurationMs,
                        ),
                        enabled: wheel.canSpin,
                        soundOn: wheel.soundOn,
                        hapticsOn: wheel.hapticsOn,
                        onResult: (int index) => _handleResult(wheel, index),
                      ),
                    ),
                  ),
                  if (!wheel.canSpin)
                    const Padding(
                      padding: EdgeInsets.fromLTRB(
                        Spacing.lg,
                        0,
                        Spacing.lg,
                        Spacing.sm,
                      ),
                      child: Text(
                        'En az 2 seçenek gerekli.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFF4B942),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Spacing.lg,
                      0,
                      Spacing.lg,
                      Spacing.lg,
                    ),
                    child: Text(
                      '${wheel.segments.length} seçenek',
                      style: const TextStyle(
                        fontSize: 14,
                        color: kTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              if (_confettiVisible)
                ConfettiOverlay(
                  onFinished: () {
                    if (mounted) setState(() => _confettiVisible = false);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Çark durduğunda: konfeti + kazanan kartı + eleme modu gerekiyorsa seçeneği çıkar.
  Future<void> _handleResult(Wheel wheel, int index) async {
    if (!mounted || index < 0 || index >= wheel.segments.length) return;
    final String winner = wheel.segments[index];

    setState(() => _confettiVisible = true);

    final WinnerAction? action = await showModalBottomSheet<WinnerAction>(
      context: context,
      builder: (BuildContext sheetContext) => WinnerSheet(
        segment: winner,
        eliminateMode: wheel.eliminateMode,
        canEliminate: !wheel.eliminateMode && wheel.segments.length > 2,
      ),
    );
    if (!mounted) return;

    final bool shouldEliminate =
        wheel.eliminateMode || action == WinnerAction.eliminate;
    if (shouldEliminate) {
      await ref
          .read(wheelListProvider.notifier)
          .eliminateSegment(wheel.id, winner);
    }

    if (action == WinnerAction.spinAgain && mounted) {
      // Kart kapanış animasyonu bitmeden çark dönmesin.
      await Future<void>.delayed(const Duration(milliseconds: 220));
      if (mounted) _wheelKey.currentState?.spin();
    }
  }
}
