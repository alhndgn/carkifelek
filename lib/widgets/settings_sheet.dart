import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/wheel.dart';
import '../state/wheel_list_provider.dart';
import '../theme/palette.dart';
import '../theme/spacing.dart';

/// Çarka özel ayarlar: eleme modu, dönüş süresi, ses, titreşim.
/// Her değişiklik anında kaydedilir (ayrıca "kaydet" düğmesi yok).
class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key, required this.wheelId});

  final String wheelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Wheel? wheel = ref.watch(
      wheelListProvider.select(
        (List<Wheel> wheels) =>
            wheels.where((Wheel w) => w.id == wheelId).firstOrNull,
      ),
    );

    if (wheel == null) {
      return const SizedBox.shrink();
    }

    final WheelListNotifier notifier = ref.read(wheelListProvider.notifier);
    final double seconds = wheel.spinDurationMs / 1000;

    return SafeArea(
      // Küçük ekran/yatay modda taşmasın diye kaydırılabilir.
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
          const Padding(
            padding: EdgeInsets.fromLTRB(
              Spacing.lg,
              Spacing.lg,
              Spacing.lg,
              Spacing.sm,
            ),
            child: Text(
              'Ayarlar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: kTextPrimary,
              ),
            ),
          ),
          SwitchListTile(
            value: wheel.eliminateMode,
            onChanged: (bool value) =>
                notifier.updateSettings(wheelId, eliminateMode: value),
            activeThumbColor: kAccent,
            title: const Text('Eleme modu'),
            subtitle: const Text(
              'Kazanan her turda listeden çıkar (son kişi kalana kadar)',
              style: TextStyle(fontSize: 12),
            ),
          ),
          SwitchListTile(
            value: wheel.soundOn,
            onChanged: (bool value) =>
                notifier.updateSettings(wheelId, soundOn: value),
            activeThumbColor: kAccent,
            title: const Text('Tik sesi'),
            subtitle: const Text(
              'İbre dilim sınırını geçerken ses',
              style: TextStyle(fontSize: 12),
            ),
          ),
          SwitchListTile(
            value: wheel.hapticsOn,
            onChanged: (bool value) =>
                notifier.updateSettings(wheelId, hapticsOn: value),
            activeThumbColor: kAccent,
            title: const Text('Titreşim'),
            subtitle: const Text(
              'Destekleyen telefonlarda dokunsal geri bildirim',
              style: TextStyle(fontSize: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.lg,
              Spacing.sm,
              Spacing.lg,
              0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  'Dönüş süresi',
                  style: TextStyle(fontSize: 15, color: kTextPrimary),
                ),
                Text(
                  '${seconds.toStringAsFixed(1)} sn',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: kAccent,
                  ),
                ),
              ],
            ),
          ),
          Slider(
            value: seconds,
            min: Wheel.minSpinDurationMs / 1000,
            max: Wheel.maxSpinDurationMs / 1000,
            divisions:
                (Wheel.maxSpinDurationMs - Wheel.minSpinDurationMs) ~/ 500,
            label: '${seconds.toStringAsFixed(1)} sn',
            activeColor: kAccent,
            onChanged: (double value) => notifier.updateSettings(
              wheelId,
              spinDurationMs: (value * 1000).round(),
            ),
          ),
          const SizedBox(height: Spacing.sm),
          ],
        ),
      ),
    );
  }
}
