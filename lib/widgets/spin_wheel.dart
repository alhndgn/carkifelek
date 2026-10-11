import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/feedback.dart';
import '../core/friction_curve.dart';
import '../core/spin_math.dart';
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
  });

  final List<String> segments;
  final Duration duration;
  final ValueChanged<int>? onResult;
  final bool enabled;
  final bool soundOn;
  final bool hapticsOn;

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

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleFrame);
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
        '${radius.toStringAsFixed(1)}|${segments.length}|${segments.join('¦')}';
    if (key == _labelKey) return;
    _labelKey = key;

    final int count = segments.length;
    final double fontSize = count <= 6
        ? 15
        : count <= 12
        ? 13
        : count <= 18
        ? 11.5
        : 10;
    final double maxWidth = math.max(36, radius * 0.58);

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
                  builder: (BuildContext context, Widget? child) => Transform.rotate(
                    angle: _displayRotation,
                    child: CustomPaint(
                      size: Size.square(size),
                      painter: WheelPainter(
                        labels: _labels,
                        segmentCount: widget.segments.length,
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
                gradient: const LinearGradient(
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

/// Çark dilimlerini ve halkasını çizen ressam. Dönüş uygulanmaz (bkz. `Transform.rotate`).
class WheelPainter extends CustomPainter {
  WheelPainter({required this.labels, required this.segmentCount});

  final List<TextPainter> labels;
  final int segmentCount;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = size.shortestSide / 2 * 0.92;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    if (segmentCount < 1) {
      canvas.drawCircle(rect.center, radius, Paint()..color = kSurface);
      return;
    }

    final double sweep = SpinMath.sweep(segmentCount);
    for (int i = 0; i < segmentCount; i++) {
      // 0 radyan = üst (ibre yönü); saat yönünde artar → canvas açısı -π/2 + açı
      final double start = -math.pi / 2 + i * sweep;
      final Paint paint = Paint()
        ..style = PaintingStyle.fill
        ..isAntiAlias = true
        ..color = paletteColorAt(i);
      canvas.drawArc(rect, start, sweep, true, paint);

      // dilim arası ince ayırıcı
      final Paint divider = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0x33FFFFFF);
      canvas.drawArc(rect, start, sweep, true, divider);

      final TextPainter? label = i < labels.length ? labels[i] : null;
      if (label != null) {
        final double angle = start + sweep / 2;
        final Offset position = Offset(
          center.dx + math.cos(angle) * radius * 0.62,
          center.dy + math.sin(angle) * radius * 0.62,
        );
        canvas.save();
        canvas.translate(position.dx, position.dy);
        canvas.rotate(angle + math.pi / 2);
        label.paint(
          canvas,
          Offset(-label.width / 2, -label.height / 2),
        );
        canvas.restore();
      }
    }

    // dış halka
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

  @override
  bool shouldRepaint(WheelPainter oldDelegate) =>
      oldDelegate.segmentCount != segmentCount ||
      oldDelegate.labels != labels;
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
