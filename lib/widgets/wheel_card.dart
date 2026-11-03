import 'package:flutter/material.dart';

import '../models/wheel.dart';
import '../theme/palette.dart';
import '../theme/spacing.dart';
import 'mini_wheel.dart';

/// Çarklarım listesindeki tek kart: mini önizleme, başlık, özet ve seçenek tadımlığı.
class WheelCard extends StatelessWidget {
  const WheelCard({
    super.key,
    required this.wheel,
    required this.onTap,
    required this.onLongPress,
  });

  final Wheel wheel;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  String get _summary {
    final String mode = wheel.eliminateMode ? 'eleme modu' : 'normal mod';
    return '${wheel.segments.length} seçenek · $mode';
  }

  String get _preview {
    final List<String> preview = wheel.segments.take(3).toList();
    final String joined = preview.join(' · ');
    final bool more = wheel.segments.length > preview.length;
    return more ? '$joined …' : joined;
  }

  @override
  Widget build(BuildContext context) {
    final Color start = wheel.segments.isEmpty
        ? kAccent
        : paletteColorAt(wheel.segments.length - 1);

    return Material(
      color: kSurface,
      borderRadius: BorderRadius.circular(Radii.md),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(Radii.md),
        child: Container(
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Radii.md),
            border: Border.all(color: kBorder),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const <double>[0, 0.5],
              colors: <Color>[
                Color.alphaBlend(start.withValues(alpha: 0.12), kSurface),
                kSurface,
              ],
            ),
          ),
          child: Row(
            children: <Widget>[
              MiniWheel(segmentCount: wheel.segments.length),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      wheel.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: kTextPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      _summary,
                      style: TextStyle(
                        fontSize: 13,
                        color: kTextSecondary,
                      ),
                    ),
                    if (wheel.segments.isNotEmpty) ...<Widget>[
                      const SizedBox(height: Spacing.xs),
                      Text(
                        _preview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: kTextSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: kTextSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
