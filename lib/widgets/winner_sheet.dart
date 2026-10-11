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
          Spacing.lg,
          Spacing.lg,
          Spacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              '🎉  Kazanan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.1,
                color: kTextSecondary,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              segment,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: kTextPrimary,
              ),
            ),
            if (eliminateMode) ...<Widget>[
              const SizedBox(height: Spacing.sm),
              const Text(
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
