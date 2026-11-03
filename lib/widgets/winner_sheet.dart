import 'package:flutter/material.dart';

import '../theme/palette.dart';
import '../theme/spacing.dart';

/// Kazanan kartında kullanıcının seçebileceği eylem.
enum WinnerAction { spinAgain, eliminate, close }

/// Çark durduğunda açılan kazanan kartı.
class WinnerSheet extends StatelessWidget {
  const WinnerSheet({
    super.key,
    required this.segment,
    required this.eliminateMode,
    required this.canEliminate,
  });

  final String segment;

  /// Eleme modu açıksa kazanan, kart kapandığında listeden çıkarılır.
  final bool eliminateMode;

  /// Tek seferlik "Kazananı çıkar" düğmesi gösterilsin mi.
  final bool canEliminate;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.lg,
          Spacing.xl,
          Spacing.lg,
          Spacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[kAccent, kAccentAlt],
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: kAccent.withValues(alpha: 0.4),
                      blurRadius: 28,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emoji_events,
                  size: 44,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: Spacing.md),
            Text(
              'KAZANAN',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.4,
                color: kTextSecondary,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              segment,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                height: 1.15,
                letterSpacing: -0.4,
                color: kTextPrimary,
              ),
            ),
            if (eliminateMode) ...<Widget>[
              const SizedBox(height: Spacing.sm),
              Text(
                'Bu seçenek listeden çıkarıldı (eleme modu)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: kTextSecondary),
              ),
            ],
            const SizedBox(height: Spacing.lg),
            FilledButton.icon(
              onPressed: () =>
                  Navigator.of(context).pop(WinnerAction.spinAgain),
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar çevir'),
            ),
            const SizedBox(height: Spacing.xs),
            if (canEliminate)
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(WinnerAction.eliminate),
                child: const Text('Kazananı listeden çıkar'),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(WinnerAction.close),
              child: const Text('Tamam'),
            ),
          ],
        ),
      ),
    );
  }
}
