import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/palette.dart';

/// Teq Studio ortak çark markası: 12 dilimli mini çark + üstte sabit ibre.
///
/// Açılış ekranında ve "hakkında" bölümlerinde kullanılır. Renkler aktif
/// paletten gelir; tema değişince marka da değişir.
class WheelMark extends StatelessWidget {
  const WheelMark({super.key, this.size = 132, this.rotation = 0});

  final double size;

  /// Radyan cinsinden dönüş (açılış animasyonu için).
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _WheelMarkPainter(rotation: rotation)),
    );
  }
}

class _WheelMarkPainter extends CustomPainter {
  const _WheelMarkPainter({required this.rotation});

  final double rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.shortestSide / 2 - 3;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    // Dış haleye yumuşak parıltı
    canvas.drawCircle(
      center,
      radius + 2,
      Paint()
        ..color = kAccent.withValues(alpha: 0.20)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    final List<Color> colors = kWheelPalette;
    final int count = 12;
    final double sweep = 2 * math.pi / count;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);

    for (int i = 0; i < count; i++) {
      final double start = -math.pi / 2 + i * sweep;
      canvas.drawArc(
        rect,
        start,
        sweep,
        true,
        Paint()..color = colors[i % colors.length],
      );
    }

    // Dilim aralarına ince koyu çizgi → okunaklı çark hissi
    final Paint divider = Paint()
      ..color = kSurface.withValues(alpha: 0.55)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < count; i++) {
      final double a = -math.pi / 2 + i * sweep;
      canvas.drawLine(
        center,
        center + Offset(math.cos(a), math.sin(a)) * radius,
        divider,
      );
    }
    canvas.restore();

    // Göbek: koyu halka + iç daire
    canvas.drawCircle(center, radius * 0.30, Paint()..color = kSurface);
    canvas.drawCircle(
      center,
      radius * 0.30,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = kBorder,
    );
    canvas.drawCircle(
      center,
      radius * 0.185,
      Paint()
        ..shader = LinearGradient(
          colors: <Color>[kAccent, kAccentAlt],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 0.2)),
    );

    // Üstte sabit ibre (aşağı bakan üçgen)
    final double tipY = center.dy - radius * 0.10;
    final Path pointer = Path()
      ..moveTo(center.dx, tipY + radius * 0.135)
      ..lineTo(center.dx - radius * 0.085, tipY - radius * 0.055)
      ..lineTo(center.dx + radius * 0.085, tipY - radius * 0.055)
      ..close();
    canvas.drawPath(pointer, Paint()..color = kTextPrimary);
  }

  @override
  bool shouldRepaint(_WheelMarkPainter oldDelegate) =>
      oldDelegate.rotation != rotation;
}

/// Teq Studio imzası: yuvarlak "T" rozeti + "Developed by Teq Studio".
class TeqCredit extends StatelessWidget {
  const TeqCredit({super.key, this.dense = false});

  /// Açılış ekranı dışında (hakkında vb.) daha küçük gösterim.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final double badge = dense ? 18 : 22;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: badge,
          height: badge,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[kAccent, kAccentAlt],
            ),
          ),
          child: Text(
            'T',
            style: TextStyle(
              fontSize: dense ? 11 : 13,
              fontWeight: FontWeight.w900,
              height: 1,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(width: dense ? 7 : 9),
        Text(
          'Developed by Teq Studio',
          style: TextStyle(
            fontSize: dense ? 11 : 12.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
            color: kTextSecondary,
          ),
        ),
      ],
    );
  }
}

/// Teq Studio ortak açılış ekranı.
///
/// Her uygulama kendi adı, vaadi ve markasıyla kullanır; imza sabittir.
/// Dokununca veya süre dolunca [onDone] çağrılır.
class TeqSplash extends StatefulWidget {
  const TeqSplash({
    super.key,
    required this.appName,
    required this.tagline,
    required this.mark,
    required this.onDone,
    this.stats = const <String>[],
    this.duration = const Duration(milliseconds: 2100),
    this.hold = false,
  });

  final String appName;
  final String tagline;

  /// Uygulamanın kendi markası; dönüş açısı ve önerilen boyut verilir.
  final Widget Function(double rotation, double size) mark;
  final VoidCallback onDone;

  /// Alt satırdaki kısa rozetler: "66 çark", "4 görünüm" gibi.
  final List<String> stats;

  final Duration duration;

  /// Tasarım incelemesi için ekranda tut: animasyon son hâline atlar, kapanmaz.
  final bool hold;

  @override
  State<TeqSplash> createState() => _TeqSplashState();
}

class _TeqSplashState extends State<TeqSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _enter;
  late final Animation<double> _exit;
  late final Animation<double> _lift;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) _finish();
      });

    _enter = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.32, curve: Curves.easeOut),
    );
    _exit = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.86, 1, curve: Curves.easeIn),
      ),
    );
    _lift = Tween<double>(begin: 14, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.45, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller.isAnimating || _finished) return;

    if (widget.hold) {
      // İnceleme modu: giriş animasyonu tamamlanmış kareyi donuk göster.
      _controller.value = 0.5;
      return;
    }

    // Hareket azaltma açıksa kısa tut, animasyonsuz geç.
    final bool reduceMotion =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduceMotion) {
      _controller.duration = const Duration(milliseconds: 450);
    }
    _controller.forward();
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    widget.onDone();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.sizeOf(context);
    final double markSize = math.min(148, screen.width * 0.40);

    return Semantics(
      label: '${widget.appName} açılıyor. ${widget.tagline}',
      // MaterialApp.builder içinde Material atası yok; onsuz metinler
      // WidgetsApp'in _errorTextStyle'ını (sarı çift alt çizgi) miras alır.
      child: Material(
        type: MaterialType.transparency,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _finish,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget? child) {
              final double visible = math.min(_enter.value, _exit.value);
              final double lift = _lift.value;

              return Opacity(
                opacity: visible.clamp(0.0, 1.0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: kBackgroundGradient,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        children: <Widget>[
                          const Spacer(flex: 3),
                          Transform.translate(
                            offset: Offset(0, lift),
                            child: Transform.scale(
                              scale: 0.94 + 0.06 * _enter.value,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    'TEQ STUDIO',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 4.2,
                                      color: kAccent,
                                    ),
                                  ),
                                  SizedBox(height: screen.height * 0.045),
                                  widget.mark(
                                    _controller.value * math.pi * 1.35,
                                    markSize,
                                  ),
                                  SizedBox(height: screen.height * 0.045),
                                  Text(
                                    widget.appName,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: math.min(
                                        44,
                                        screen.width * 0.115,
                                      ),
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -1.2,
                                      height: 1.05,
                                      color: kTextPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      widget.tagline,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 15,
                                        height: 1.45,
                                        fontWeight: FontWeight.w500,
                                        color: kTextSecondary,
                                      ),
                                    ),
                                  ),
                                  if (widget.stats.isNotEmpty) ...<Widget>[
                                    const SizedBox(height: 22),
                                    Wrap(
                                      alignment: WrapAlignment.center,
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: widget.stats
                                          .map(
                                            (String s) => _StatChip(label: s),
                                          )
                                          .toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const Spacer(flex: 4),
                          // İnce ilerleme çizgisi
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: SizedBox(
                              height: 2,
                              child: LinearProgressIndicator(
                                value: _controller.value,
                                backgroundColor: kBorder,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  kAccent,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const TeqCredit(),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: kAccent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: kAccent.withValues(alpha: 0.30)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: kTextPrimary,
        ),
      ),
    );
  }
}
