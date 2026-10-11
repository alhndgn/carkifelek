import 'dart:convert';

import '../models/wheel.dart';
import 'key_value_store.dart';

/// Çarkların JSON olarak saklanması ve okunması.
/// Bozuk veri uygulamayı çökertmez: okunamayan kayıt atlanır, gerisi korunur.
class WheelRepository {
  WheelRepository(this._store);

  final KeyValueStore _store;

  /// Şema sürümü anahtarın içinde: ileride migrasyon gerekirse `wheels_v2` eklenir.
  static const String storageKey = 'wheels_v1';

  /// Tüm çarkları en son güncellenenden en eskiye sıralı döner.
  /// Depo okuması da dahil her türlü beklenmeyen durum boş listeye düşer.
  List<Wheel> loadAll() {
    try {
      final String? raw = _store.read(storageKey);
      if (raw == null || raw.trim().isEmpty) return <Wheel>[];

      final Object? decoded = jsonDecode(raw);
      if (decoded is! List) return <Wheel>[];

      final List<Wheel> wheels = <Wheel>[];
      for (final Object? item in decoded) {
        if (item is Map<String, dynamic>) {
          try {
            wheels.add(Wheel.fromJson(item));
          } catch (_) {
            // Tek bozuk kayıt diğerlerini düşürmez.
          }
        }
      }
      wheels.sort((Wheel a, Wheel b) => b.updatedAt.compareTo(a.updatedAt));
      return wheels;
    } catch (_) {
      // Bozuk JSON: veri kaybını önlemek için ham veriye dokunmuyoruz, boş liste dönüyoruz.
      return <Wheel>[];
    }
  }

  Future<void> saveAll(List<Wheel> wheels) {
    final String encoded = jsonEncode(
      wheels.map((Wheel w) => w.toJson()).toList(),
    );
    return _store.write(storageKey, encoded);
  }

  /// Tek çark ekler/günceller ve listeyi kaydeder.
  Future<List<Wheel>> upsert(Wheel wheel) {
    final List<Wheel> current = loadAll();
    final int index = current.indexWhere((Wheel w) => w.id == wheel.id);
    if (index == -1) {
      current.insert(0, wheel);
    } else {
      current[index] = wheel;
    }
    return saveAll(current).then((_) => current);
  }

  /// Silinen çarkın yeni listesini döner.
  Future<List<Wheel>> delete(String id) {
    final List<Wheel> next = loadAll()
        .where((Wheel w) => w.id != id)
        .toList(growable: false);
    return saveAll(next).then((_) => next);
  }
}
