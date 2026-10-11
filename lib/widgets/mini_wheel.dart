import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/palette.dart';

/// Çark kartlarında ve küçük önizlemelerde kullanılan basit mini çark.
class MiniWheel extends StatelessWidget {
  const MiniWheel({super.key, required this.segmentCount, this.size = 56});

  final int segmentCount;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _MiniWheelPainter(segmentCount)),
    );
  }
}

class _MiniWheelPainter extends CustomPainter {
  _MiniWheelPainter(this.segmentCount);

  final int segmentCount;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = size.shortestSide / 2;
    final int count = segmentCount < 1 ? 1 : segmentCount;
    final double sweep = (2 * math.pi) / count;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    for (int i = 0; i < count; i++) {
      final Paint paint = Paint()
        ..style = PaintingStyle.fill
        ..color = paletteColorAt(i);
      canvas.drawArc(rect, -math.pi / 2 + i * sweep, sweep, true, paint);
    }

    canvas.drawCircle(center, radius * 0.24, Paint()..color = kSurfaceHigh);
    canvas.drawCircle(
      center,
      radius - 1,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = kBorder,
    );
  }

  @override
  bool shouldRepaint(_MiniWheelPainter oldDelegate) =>
      oldDelegate.segmentCount != segmentCount;
}
