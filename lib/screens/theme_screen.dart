import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/theme_provider.dart';
import '../theme/app_palette.dart';
import '../theme/palette.dart';
import '../theme/spacing.dart';
import '../widgets/app_background.dart';

/// Tema seçici. Her kart kendi rengini gösterir (aktif temanın değil),
/// böylece seçim yapmadan önce sonucu görürsün.
class ThemeScreen extends ConsumerWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppPalette active = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Geri',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Tema'),
      ),
      body: AppBackground(
        child: SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              Spacing.md,
              Spacing.sm,
              Spacing.md,
              Spacing.lg,
            ),
            itemCount: kAppPalettes.length,
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: Spacing.sm),
            itemBuilder: (BuildContext context, int index) {
              final AppPalette palette = kAppPalettes[index];
              return _ThemeCard(
                palette: palette,
                selected: palette.id == active.id,
                onTap: () =>
                    ref.read(themeProvider.notifier).select(palette.id),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.palette,
    required this.selected,
    required this.onTap,
  });

  final AppPalette palette;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '${palette.name} teması${selected ? ', seçili' : ''}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(Radii.md),
            border: Border.all(
              color: selected ? kAccent : kBorder,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: <Widget>[
              _Preview(palette: palette),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      palette.name,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      palette.isDark ? 'Koyu tema' : 'Açık tema',
                      style: TextStyle(fontSize: 13, color: kTextSecondary),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle, color: kAccent, size: 24)
              else
                Icon(Icons.circle_outlined, color: kBorder, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Küçük önizleme: tema gradyanı + dilim renkleri + vurgu rengi.
class _Preview extends StatelessWidget {
  const _Preview({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Radii.sm),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: palette.background,
        ),
        border: Border.all(color: palette.border),
      ),
      child: CustomPaint(painter: _MiniWheelPainter(palette)),
    );
  }
}

/// Tema önizlemesindeki küçük çark: 8 dilim + göbek + ibre.
class _MiniWheelPainter extends CustomPainter {
  const _MiniWheelPainter(this.palette);

  final AppPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.shortestSide / 2;
    const int slices = 8;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    for (int i = 0; i < slices; i++) {
      final double start = -math.pi / 2 + i * 2 * math.pi / slices;
      final Path path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(rect, start, 2 * math.pi / slices, false)
        ..close();
      canvas.drawPath(
        path,
        Paint()..color = palette.wheels[i % palette.wheels.length],
      );
    }

    canvas.drawCircle(center, radius * 0.24, Paint()..color = palette.surface);

    final Path pointer = Path()
      ..moveTo(center.dx, 1)
      ..lineTo(center.dx - radius * 0.15, radius * 0.3)
      ..lineTo(center.dx + radius * 0.15, radius * 0.3)
      ..close();
    canvas.drawPath(pointer, Paint()..color = palette.textPrimary);
  }

  @override
  bool shouldRepaint(_MiniWheelPainter oldDelegate) =>
      oldDelegate.palette.id != palette.id;
}
