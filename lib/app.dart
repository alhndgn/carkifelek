import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'router.dart';
import 'state/theme_provider.dart';
import 'theme/app_palette.dart';
import 'theme/app_theme.dart';

class CarkifelekApp extends ConsumerWidget {
  const CarkifelekApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(routerProvider);
    final AppPalette palette = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Çarkıfelek',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.of(palette),
      routerConfig: router,
    );
  }
}
