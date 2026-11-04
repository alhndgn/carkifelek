import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/feedback.dart';
import '../core/friction_curve.dart';
import '../core/spin_math.dart';
import '../models/wheel_style.dart';
import '../theme/palette.dart';

/// Döndürülebilir çark.
///
/// İbre üstte sabittir; çark elle çevrilmiş gibi davranır: kısa bir hızlanma,
/// dönüşün tamamına yayılan sürtünmeli yavaşlama ve hedefin az ötesine geçip
/// yerine oturan bir duruş (`FrictionCurve`). Kazanan `SpinMath` ile hesaplanır,
/// animasyon sadece o açıya gider — sonuç önceden belirlenmiş olsa da gözle
/// kestirilemez.
///
/// Performans: çark ve dilim yazıları bir kez çizilir, dönüş `Transform.rotate`
/// ile uygulanır; animasyon sırasında yeniden çizim (repaint) yapılmaz.
class SpinWheel extends StatefulWidget {
  const SpinWheel({
    super.key,
    required this.segments,
    required this.duration,
    this.onResult,
    this.enabled = true,
    this.soundOn = true,
    this.hapticsOn = true,
    this.random,
    this.hubLabel = 'ÇEVİR',
    this.style = WheelStyle.classic,
  });

  final List<String> segments;
  final Duration duration;
  final ValueChanged<int>? onResult;
  final bool enabled;
  final bool soundOn;
  final bool hapticsOn;

  /// Çarkın görünümü (klasik / halka / hedef / ibre).
  final WheelStyle style;

  /// Testlerde sabit seed verilir; uygulamada `Random.secure()` kullanılır.
  final math.Random? random;
  final String hubLabel;

  @override
  State<SpinWheel> createState() => SpinWheelState();
}

class SpinWheelState extends State<SpinWheel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final math.Random _random = widget.random ?? math.Random.secure();

  Tween<double>? _tween;
  Curve _curve = Curves.linear;
  double _rotation = 0;
  bool _spinning = false;
  int? _lastTickIndex;

  List<TextPainter> _labels = const <TextPainter>[];
  String _labelKey = '';

  bool get isSpinning => _spinning;

  /// Dururken ibre dilim sınırına değil, dilimin ortasına denk gelsin.
  /// Çark 0 radyanda dilim sınırındadır (matematik bunu böyle varsayar);
  /// yarım dilim kadar döndürünce ilk dilim tam ortalanır.
  double get _restRotation =>
      widget.segments.isEmpty ? 0 : math.pi / widget.segments.length;

  @override
  void initState() {
    super.initState();
    _rotation = _restRotation;
    _controller.addListener(_handleFrame);
  }

  @override
  void didUpdateWidget(covariant SpinWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_spinning && widget.segments.length != oldWidget.segments.length) {
      _rotation = _restRotation;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleFrame);
    _controller.dispose();
    super.dispose();
  }

  /// Yerine oturma için hedefin ötesine geçilen açı (radyan). Çark diliminin
  /// kenarına taşmayacak kadar küçük: sonuç her zaman doğru dilimde kalır.
  static const double _settleRadians = 0.02;

  /// Dönüş boyunca hız profili: hızlanma → sürtünmeli yavaşlama → yerine oturma.
  /// Yerine oturma miktarı toplam yola göre normalize edilir.
  Curve _curveFor(double distance) {
    if (distance <= 0) return Curves.linear;
    return FrictionCurve(
      settleOvershoot: (_settleRadians / distance).clamp(0.0, 0.004),
    );
  }

  /// Verilen animasyon değerinde çarkın açısı (eğri uygulanmış).
  double _rotationAt(double controllerValue) {
    final Tween<double>? tween = _tween;
    if (tween == null) return _rotation;
    return tween.transform(_curve.transform(controllerValue));
  }

  double get _displayRotation => _rotationAt(_controller.value);

  /// Çarkı döndürür ve bitince `onResult` ile kazananın indeksini bildirir.
  void spin() {
    final int count = widget.segments.length;
    if (!widget.enabled || _spinning || count < 2) return;

    final int winner = SpinMath.randomWinner(count, _random);
    final int turns = SpinMath.randomFullTurns(_random);
    final double from = _rotation;
    final double target = SpinMath.targetRotation(
      from: from,
      winnerIndex: winner,
      segmentCount: count,
      fullTurns: turns,
    );

    _tween = Tween<double>(begin: from, end: target);
    _curve = _curveFor(target - from);
    _lastTickIndex = SpinMath.indexAtRotation(from, count);
    _spinning = true;
    _controller.duration = widget.duration;
    setState(() {});

    _controller.forward(from: 0).whenComplete(() {
      if (!mounted) return;
      setState(() {
        _rotation = SpinMath.normalize(target);
        _tween = null;
        _spinning = false;
      });
      WheelFeedback.result(haptics: widget.hapticsOn, sound: widget.soundOn);
      widget.onResult?.call(winner);
    });
  }

  /// Animasyon sırasında ibre yeni bir dilime geçtiğinde tik sesi/titreşim verir.
  void _handleFrame() {
    final Tween<double>? tween = _tween;
    if (tween == null || !_spinning) return;

    final int index = SpinMath.indexAtRotation(
      _rotationAt(_controller.value),
      widget.segments.length,
    );
    if (index == _lastTickIndex) return;
    _lastTickIndex = index;
    WheelFeedback.tick(sound: widget.soundOn, haptics: widget.hapticsOn);
  }

  /// Dilim yazılarını yarıçapa göre bir kez hazırlar (yeniden çizimde tekrar hesaplanmaz).
  void _ensureLabels(double radius) {
    final List<String> segments = widget.segments;
    final String key =
        '${radius.toStringAsFixed(1)}|${segments.length}|'
        '${segments.join('¦')}|${widget.style.id}';
    if (key == _labelKey) return;
    _labelKey = key;

    final int count = segments.length;
    final double baseSize = count <= 6
        ? 15
        : count <= 12
        ? 13
        : count <= 18
        ? 11.5
        : 10;

    // Dar halkalarda yazı hem küçülür hem kısalır.
    final (double widthFactor, double sizeFactor) = switch (widget.style) {
      WheelStyle.classic => (0.58, 1.0),
      WheelStyle.donut => (0.42, 0.92),
      WheelStyle.target => (0.30, 0.82),
      WheelStyle.needle => (0.32, 0.86),
    };
    final double fontSize = baseSize * sizeFactor;
    final double maxWidth = math.max(24, radius * widthFactor);

    _labels = segments
        .map(
          (String segment) => TextPainter(
            text: TextSpan(
              text: segment,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                shadows: const <Shadow>[
                  Shadow(blurRadius: 3, color: Color(0x8C000000)),
                ],
              ),
            ),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            maxLines: 1,
            ellipsis: '…',
          )..layout(maxWidth: maxWidth),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double size = math.min(
          constraints.maxWidth,
          constraints.maxHeight,
        );
        if (size <= 0 || !size.isFinite) return const SizedBox.shrink();

        final double radius = size / 2;
        _ensureLabels(radius);
        final bool canSpin =
            widget.enabled && !_spinning && widget.segments.length >= 2;

        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                // dış gölge
                Container(
                  width: size * 0.96,
                  height: size * 0.96,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Color(0x66000000),
                        blurRadius: 28,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                ),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (BuildContext context, Widget? child) =>
                      Transform.rotate(
                        angle: _displayRotation,
                        child: CustomPaint(
                          size: Size.square(size),
                          painter: WheelPainter(
                            labels: _labels,
                            segmentCount: widget.segments.length,
                            style: widget.style,
                          ),
                        ),
                      ),
                ),
                // Erişilebilirlik: çark tuvale çizildiği için seçenekleri
                // ekran okuyucuya metin olarak bildir.
                Semantics(
                  readOnly: true,
                  label: widget.segments.isEmpty
                      ? 'Boş çark'
                      : 'Çark: ${widget.segments.join(', ')}',
                  child: const SizedBox(width: 1, height: 1),
                ),
                // ibre (sabit)
                Align(
                  alignment: Alignment.topCenter,
                  child: CustomPaint(
                    size: Size(size * 0.15, size * 0.20),
                    painter: const PointerPainter(),
                  ),
                ),
                _HubButton(
                  radius: radius,
                  label: widget.hubLabel,
                  enabled: canSpin,
                  spinning: _spinning,
                  onTap: spin,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Merkezdeki yuvarlak "ÇEVİR" düğmesi.
class _HubButton extends StatelessWidget {
  const _HubButton({
    required this.radius,
    required this.label,
    required this.enabled,
    required this.spinning,
    required this.onTap,
  });

  final double radius;
  final String label;
  final bool enabled;
  final bool spinning;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double diameter = radius * 0.52;
    return Semantics(
      button: true,
      enabled: enabled,
      label: 'Çarkı çevir',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          customBorder: const CircleBorder(),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: enabled ? 1 : 0.55,
            child: Container(
              width: diameter,
              height: diameter,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[kAccent, kAccentAlt],
                ),
                border: Border.all(color: const Color(0x33FFFFFF), width: 2),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: spinning
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      label,
                      style: TextStyle(
                        fontSize: (diameter * 0.22).clamp(11, 18),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Çark dilimlerini çizen ressam. Dönüş uygulanmaz (bkz. `Transform.rotate`).
///
/// Dört görünüm de aynı geometriyi kullanır: 0 radyan üsttür ve saat yönünde
/// artar, böylece sabit ibre her stilde aynı dilimi gösterir.
class WheelPainter extends CustomPainter {
  WheelPainter({
    required this.labels,
    required this.segmentCount,
    this.style = WheelStyle.classic,
  });

  final List<TextPainter> labels;
  final int segmentCount;
  final WheelStyle style;

  static const Color _divider = Color(0x33FFFFFF);

  /// Etiketlerin yarıçapa göre yerleştiği oran (görünüme göre).
  double get _labelFraction => switch (style) {
    WheelStyle.classic => 0.62,
    WheelStyle.donut => 0.81,
    WheelStyle.target => 0.89,
    WheelStyle.needle => 0.845,
  };

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = size.shortestSide / 2 * 0.92;

    if (segmentCount < 1) {
      canvas.drawCircle(center, radius, Paint()..color = kSurface);
      return;
    }

    switch (style) {
      case WheelStyle.classic:
        _paintClassic(canvas, center, radius);
      case WheelStyle.donut:
        _paintDonut(canvas, center, radius);
      case WheelStyle.target:
        _paintTarget(canvas, center, radius);
      case WheelStyle.needle:
        _paintNeedle(canvas, center, radius);
    }

    _paintRim(canvas, center, radius);
    _paintLabels(canvas, center, radius);
  }

  double get _sweep => SpinMath.sweep(segmentCount);

  double _startOf(int i) => -math.pi / 2 + i * _sweep;

  /// Halka dilimi (donut / hedef / ibre için).
  Path _annulus(
    Offset center,
    double outer,
    double inner,
    double start,
    double sweep,
  ) {
    return Path()
      ..arcTo(Rect.fromCircle(center: center, radius: outer), start, sweep, true)
      ..arcTo(
        Rect.fromCircle(center: center, radius: inner),
        start + sweep,
        -sweep,
        false,
      )
      ..close();
  }

  void _paintClassic(Canvas canvas, Offset center, double radius) {
    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    for (int i = 0; i < segmentCount; i++) {
      final double start = _startOf(i);
      canvas.drawArc(
        rect,
        start,
        _sweep,
        true,
        Paint()
          ..style = PaintingStyle.fill
          ..isAntiAlias = true
          ..color = paletteColorAt(i),
      );
      canvas.drawArc(
        rect,
        start,
        _sweep,
        true,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = _divider,
      );
    }
  }

  void _paintDonut(Canvas canvas, Offset center, double radius) {
    final double inner = radius * 0.62;
    for (int i = 0; i < segmentCount; i++) {
      final Path path = _annulus(center, radius, inner, _startOf(i), _sweep);
      canvas.drawPath(
        path,
        Paint()
          ..isAntiAlias = true
          ..color = paletteColorAt(i),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = _divider,
      );
    }
    canvas.drawCircle(
      center,
      inner,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = kSurfaceHigh,
    );
  }

  void _paintTarget(Canvas canvas, Offset center, double radius) {
    // Dıştan içe bantlar; her bant biraz daha koyulaşır (dart tahtası hissi).
    const List<double> edges = <double>[1.0, 0.79, 0.58, 0.37];
    for (int band = 0; band < edges.length - 1; band++) {
      final double outer = radius * edges[band];
      final double inner = radius * edges[band + 1];
      for (int i = 0; i < segmentCount; i++) {
        final Color base = paletteColorAt(i);
        final Path path = _annulus(center, outer, inner, _startOf(i), _sweep);
        canvas.drawPath(
          path,
          Paint()
            ..isAntiAlias = true
            ..color = Color.lerp(base, Colors.black, 0.10 * band) ?? base,
        );
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = _divider,
        );
      }
      canvas.drawCircle(
        center,
        inner,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = _divider,
      );
    }

    // Göbek (bullseye)
    canvas.drawCircle(center, radius * 0.34, Paint()..color = kSurfaceHigh);
    canvas.drawCircle(
      center,
      radius * 0.30,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = kAccent.withValues(alpha: 0.6),
    );
  }

  void _paintNeedle(Canvas canvas, Offset center, double radius) {
    final double inner = radius * 0.72;

    // iç kadran
    canvas.drawCircle(
      center,
      inner,
      Paint()..color = kSurface.withValues(alpha: 0.55),
    );

    // ince çentikler (60 adet) — dönüş sırasında hareketi belli eder
    final Paint tick = Paint()
      ..strokeWidth = 1
      ..color = kTextSecondary.withValues(alpha: 0.35);
    for (int i = 0; i < 60; i++) {
      final double a = -math.pi / 2 + i * math.pi * 2 / 60;
      final bool major = i % 5 == 0;
      canvas.drawLine(
        Offset(
          center.dx + math.cos(a) * (inner * 0.86),
          center.dy + math.sin(a) * (inner * 0.86),
        ),
        Offset(
          center.dx + math.cos(a) * (inner * (major ? 0.99 : 0.94)),
          center.dy + math.sin(a) * (inner * (major ? 0.99 : 0.94)),
        ),
        tick..strokeWidth = major ? 1.6 : 1,
      );
    }

    // dış halka dilimleri
    for (int i = 0; i < segmentCount; i++) {
      final Path path = _annulus(center, radius * 0.97, inner, _startOf(i), _sweep);
      canvas.drawPath(
        path,
        Paint()
          ..isAntiAlias = true
          ..color = paletteColorAt(i),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = _divider,
      );
      // dilim sınırı çentiği
      final double a = _startOf(i);
      canvas.drawLine(
        Offset(
          center.dx + math.cos(a) * inner,
          center.dy + math.sin(a) * inner,
        ),
        Offset(
          center.dx + math.cos(a) * radius * 0.97,
          center.dy + math.sin(a) * radius * 0.97,
        ),
        Paint()
          ..strokeWidth = 1.6
          ..color = kSurfaceHigh,
      );
    }
  }

  void _paintRim(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = kSurfaceHigh,
    );
    canvas.drawCircle(
      center,
      radius + 3,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = kBorder,
    );
  }

  void _paintLabels(Canvas canvas, Offset center, double radius) {
    final double at = radius * _labelFraction;
    for (int i = 0; i < segmentCount; i++) {
      final TextPainter? label = i < labels.length ? labels[i] : null;
      if (label == null) continue;
      final double angle = _startOf(i) + _sweep / 2;
      final Offset position = Offset(
        center.dx + math.cos(angle) * at,
        center.dy + math.sin(angle) * at,
      );
      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(angle + math.pi / 2);
      label.paint(canvas, Offset(-label.width / 2, -label.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(WheelPainter oldDelegate) =>
      oldDelegate.segmentCount != segmentCount ||
      oldDelegate.labels != labels ||
      oldDelegate.style != style;
}

/// Üstteki sabit ibre (aşağı bakan üçgen + halka).
class PointerPainter extends CustomPainter {
  const PointerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double tipY = size.height;
    final double headY = size.height * 0.32;

    final Path path = Path()
      ..moveTo(cx, tipY)
      ..lineTo(cx - size.width * 0.42, headY)
      ..quadraticBezierTo(cx, headY * 0.55, cx + size.width * 0.42, headY)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0x66000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawPath(path, Paint()..color = Colors.white);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = kBorder,
    );
    canvas.drawCircle(
      Offset(cx, headY * 0.62),
      size.width * 0.16,
      Paint()..color = kAccent,
    );
  }

  @override
  bool shouldRepaint(PointerPainter oldDelegate) => false;
}
