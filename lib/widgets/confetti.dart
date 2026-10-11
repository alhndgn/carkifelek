import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/palette.dart';

/// Kazanan açıklandığında kısa süreli konfeti yağmuru.
/// Harici paket yok: parçacıklar saf `CustomPainter` ile çizilir.
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({
    super.key,
    required this.onFinished,
    this.particleCount = 90,
    this.duration = const Duration(milliseconds: 2400),
    this.seed,
  });

  final VoidCallback onFinished;
  final int particleCount;
  final Duration duration;
  final int? seed;

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final List<_Particle> _particles = _buildParticles();

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed && mounted) {
        widget.onFinished();
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_Particle> _buildParticles() {
    final math.Random random = widget.seed == null
        ? math.Random()
        : math.Random(widget.seed);
    return List<_Particle>.generate(widget.particleCount, (int index) {
      final double angle = -math.pi / 2 + (random.nextDouble() - 0.5) * 2.2;
      final double speed = 0.35 + random.nextDouble() * 0.55;
      return _Particle(
        startX: 0.5 + (random.nextDouble() - 0.5) * 0.12,
        startY: 0.42,
        vx: math.cos(angle) * speed,
        vy: math.sin(angle) * speed,
        size: 5 + random.nextDouble() * 7,
        spin: (random.nextDouble() - 0.5) * 12,
        angle: random.nextDouble() * math.pi,
        color: paletteColorAt(index),
        isRect: random.nextBool(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) => CustomPaint(
          painter: _ConfettiPainter(
            particles: _particles,
            progress: _controller.value,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _Particle {
  const _Particle({
    required this.startX,
    required this.startY,
    required this.vx,
    required this.vy,
    required this.size,
    required this.spin,
    required this.angle,
    required this.color,
    required this.isRect,
  });

  final double startX;
  final double startY;
  final double vx;
  final double vy;
  final double size;
  final double spin;
  final double angle;
  final Color color;
  final bool isRect;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.particles, required this.progress});

  final List<_Particle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const double gravity = 1.15;
    final double t = progress;
    final double fade = t < 0.75 ? 1 : (1 - (t - 0.75) / 0.25).clamp(0, 1);

    for (final _Particle particle in particles) {
      final double x = (particle.startX + particle.vx * t) * size.width;
      final double y =
          (particle.startY + particle.vy * t + 0.5 * gravity * t * t) *
          size.height;
      if (y > size.height + 20) continue;

      final Paint paint = Paint()
        ..color = particle.color.withValues(alpha: fade)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.angle + particle.spin * t);
      if (particle.isRect) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size,
              height: particle.size * 0.55,
            ),
            const Radius.circular(1.5),
          ),
          paint,
        );
      } else {
        canvas.drawCircle(Offset.zero, particle.size * 0.35, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
