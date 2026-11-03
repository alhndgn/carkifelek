import '../core/ids.dart';

/// Tek bir çark: başlık, seçenekler ve çarka özel ayarlar.
/// Saf Dart — Flutter ve kalıcılık bağımlılığı yok, bu yüzden unit test kolay.
class Wheel {
  const Wheel({
    required this.id,
    required this.title,
    required this.segments,
    required this.updatedAt,
    this.eliminateMode = false,
    this.spinDurationMs = defaultSpinDurationMs,
    this.soundOn = true,
    this.hapticsOn = true,
  });

  final String id;
  final String title;
  final List<String> segments;
  final bool eliminateMode;
  final int spinDurationMs;
  final bool soundOn;
  final bool hapticsOn;
  final DateTime updatedAt;

  /// Çarkın dönebilmesi için gereken en az seçenek sayısı.
  static const int minSegments = 2;

  /// Bu sayının üstünde okunabilirlik düşer; ekleme engellenmez, uyarı gösterilir.
  static const int recommendedMaxSegments = 24;

  static const int defaultSpinDurationMs = 5000;
  static const int minSpinDurationMs = 3000;
  static const int maxSpinDurationMs = 8000;

  bool get canSpin => segments.length >= minSegments;

  bool get hasManySegments => segments.length > recommendedMaxSegments;

  /// Metinleri kırpar, boşları atar; sıralamayı korur.
  /// Boş metinler sessizce düşürülür (yinelenenlere izin verilir).
  static List<String> normalizeSegments(Iterable<String> raw) {
    final List<String> out = <String>[];
    for (final String item in raw) {
      final String trimmed = item.trim();
      if (trimmed.isNotEmpty) out.add(trimmed);
    }
    return out;
  }

  static int _clampDuration(Object? value) {
    if (value is num) {
      return value.toInt().clamp(minSpinDurationMs, maxSpinDurationMs).toInt();
    }
    return defaultSpinDurationMs;
  }

  Wheel copyWith({
    String? title,
    List<String>? segments,
    bool? eliminateMode,
    int? spinDurationMs,
    bool? soundOn,
    bool? hapticsOn,
    DateTime? updatedAt,
  }) {
    return Wheel(
      id: id,
      title: title ?? this.title,
      segments: segments ?? this.segments,
      eliminateMode: eliminateMode ?? this.eliminateMode,
      spinDurationMs: spinDurationMs ?? this.spinDurationMs,
      soundOn: soundOn ?? this.soundOn,
      hapticsOn: hapticsOn ?? this.hapticsOn,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'segments': segments,
    'eliminateMode': eliminateMode,
    'spinDurationMs': spinDurationMs,
    'soundOn': soundOn,
    'hapticsOn': hapticsOn,
    'updatedAt': updatedAt.toIso8601String(),
  };

  /// Bozuk/eksik alanlara dayanıklı okuma: eksikse makul varsayılan kullanılır.
  factory Wheel.fromJson(Map<String, dynamic> json) {
    final Object? rawId = json['id'];
    final String id = (rawId is String && rawId.trim().isNotEmpty)
        ? rawId.trim()
        : newId();

    final Object? rawTitle = json['title'];
    final String title = (rawTitle is String && rawTitle.trim().isNotEmpty)
        ? rawTitle.trim()
        : 'Adsız Çark';

    final Object? rawSegments = json['segments'];
    final List<String> segments = rawSegments is List
        ? normalizeSegments(rawSegments.whereType<String>())
        : <String>[];

    final Object? rawUpdated = json['updatedAt'];
    final DateTime updatedAt =
        (rawUpdated is String ? DateTime.tryParse(rawUpdated) : null) ??
        DateTime.now();

    return Wheel(
      id: id,
      title: title,
      segments: segments,
      eliminateMode: json['eliminateMode'] == true,
      spinDurationMs: _clampDuration(json['spinDurationMs']),
      soundOn: json['soundOn'] != false,
      hapticsOn: json['hapticsOn'] != false,
      updatedAt: updatedAt,
    );
  }
}
