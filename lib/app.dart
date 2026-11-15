import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'router.dart';
import 'state/theme_provider.dart';
import 'theme/app_palette.dart';
import 'theme/app_theme.dart';
import 'widgets/teq_splash.dart';

/// Açılış ekranı açık mı? Testler `overrideWithValue(false)` ile atlar.
final Provider<bool> splashEnabledProvider = Provider<bool>((Ref ref) => true);

class CarkifelekApp extends ConsumerStatefulWidget {
  const CarkifelekApp({super.key});

  @override
  ConsumerState<CarkifelekApp> createState() => _CarkifelekAppState();
}

class _CarkifelekAppState extends ConsumerState<CarkifelekApp> {
  bool? _showSplash;

  @override
  Widget build(BuildContext context) {
    final GoRouter router = ref.watch(routerProvider);
    final AppPalette palette = ref.watch(themeProvider);
    // İlk build'de provider'dan okunur; sonra kullanıcı etkileşimi belirler.
    _showSplash ??= ref.watch(splashEnabledProvider);

    return MaterialApp.router(
      title: 'Çarkıfelek',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.of(palette),
      routerConfig: router,
      builder: (BuildContext context, Widget? child) {
        return Stack(
          children: <Widget>[
            ?child,
            if (_showSplash ?? false)
              Positioned.fill(
                child: TeqSplash(
                  appName: 'Çarkıfelek',
                  tagline: 'Kararsız kaldığın her an yanında.\nÇevir, kararı şansa bırak.',
                  mark: (double rotation, double size) =>
                      WheelMark(size: size, rotation: rotation),
                  // Tasarım incelemesi: web'de ?splash=hold ekranda tutar.
                  hold: Uri.base.queryParameters['splash'] == 'hold',
                  onDone: () => setState(() => _showSplash = false),
                ),
              ),
          ],
        );
      },
    );
  }
}
