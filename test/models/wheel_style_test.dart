import 'package:carkifelek/models/wheel.dart';
import 'package:carkifelek/models/wheel_style.dart';
import 'package:flutter_test/flutter_test.dart';

Wheel _wheel({WheelStyle style = WheelStyle.classic}) => Wheel(
  id: 'w1',
  title: 'Test',
  segments: const <String>['A', 'B', 'C'],
  updatedAt: DateTime.parse('2026-10-11T12:00:00.000'),
  style: style,
);

void main() {
  test('varsayılan görünüm klasiktir', () {
    expect(_wheel().style, WheelStyle.classic);
  });

  test('her görünüm JSON gidiş-dönüşünde korunur', () {
    for (final WheelStyle style in WheelStyle.values) {
      final Wheel restored = Wheel.fromJson(_wheel(style: style).toJson());
      expect(restored.style, style, reason: style.id);
    }
  });

  test('bilinmeyen veya bozuk görünüm kimliği klasike düşer', () {
    expect(WheelStyle.fromId('yok-boyle-bir-sey'), WheelStyle.classic);
    expect(WheelStyle.fromId(null), WheelStyle.classic);
    expect(WheelStyle.fromId(42), WheelStyle.classic);
    expect(WheelStyle.fromId(<String>[]), WheelStyle.classic);
  });

  test('copyWith görünümü değiştirir, diğer alanları korur', () {
    final Wheel base = _wheel();
    final Wheel changed = base.copyWith(style: WheelStyle.target);
    expect(changed.style, WheelStyle.target);
    expect(changed.id, base.id);
    expect(changed.segments, base.segments);
    expect(changed.soundOn, base.soundOn);
  });

  test('görünüm kimlikleri benzersiz ve etiketleri dolu', () {
    final Set<String> ids = WheelStyle.values
        .map((WheelStyle s) => s.id)
        .toSet();
    expect(ids.length, WheelStyle.values.length);
    for (final WheelStyle s in WheelStyle.values) {
      expect(s.label.trim().isNotEmpty, isTrue);
      expect(s.description.trim().isNotEmpty, isTrue);
    }
    expect(WheelStyle.values.length, 8);
  });
}
