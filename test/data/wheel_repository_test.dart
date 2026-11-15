import 'dart:convert';

import 'package:carkifelek/data/key_value_store.dart';
import 'package:carkifelek/data/wheel_repository.dart';
import 'package:carkifelek/models/wheel.dart';
import 'package:flutter_test/flutter_test.dart';

Wheel _wheel(String id, String title, DateTime updatedAt) => Wheel(
  id: id,
  title: title,
  segments: const <String>['A', 'B'],
  updatedAt: updatedAt,
);

/// Okuma sırasında hata fırlatan depo (web'deki cast hatasını taklit eder).
class _ThrowingStore implements KeyValueStore {
  @override
  String? read(String key) => throw StateError('bozuk depo');

  @override
  Future<void> write(String key, String value) async {}

  @override
  Future<void> remove(String key) async {}
}

void main() {
  late InMemoryStore store;
  late WheelRepository repository;

  setUp(() {
    store = InMemoryStore();
    repository = WheelRepository(store);
  });

  test('boş depoda liste boş döner', () {
    expect(repository.loadAll(), isEmpty);
  });

  test('kaydedilen çarklar en son güncellenenden eskiye sıralanır', () async {
    final Wheel older = _wheel(
      'a',
      'Eski',
      DateTime.parse('2026-01-01T00:00:00Z'),
    );
    final Wheel newer = _wheel(
      'b',
      'Yeni',
      DateTime.parse('2026-06-01T00:00:00Z'),
    );

    await repository.saveAll(<Wheel>[older, newer]);

    final List<Wheel> loaded = repository.loadAll();
    expect(loaded.map((Wheel w) => w.id).toList(), <String>['b', 'a']);
  });

  test('bozuk JSON çökertmez, boş liste döner', () {
    store = InMemoryStore(<String, String>{
      WheelRepository.storageKey: '{bu bir json değil',
    });
    repository = WheelRepository(store);
    expect(repository.loadAll(), isEmpty);
  });

  test('JSON dizi değilse boş liste döner', () {
    store = InMemoryStore(<String, String>{
      WheelRepository.storageKey: '{"a":1}',
    });
    repository = WheelRepository(store);
    expect(repository.loadAll(), isEmpty);
  });

  test('metin olmayan kayıtlar atlanır, eksik alanlı kayıt varsayılanlarla okunur', () async {
    final Wheel good = _wheel(
      'iyi',
      'Sağlam',
      DateTime.parse('2026-05-05T00:00:00Z'),
    );
    final String raw = jsonEncode(<Object?>[
      'bu_string_olmamali',
      <String, dynamic>{'bozuk': true, 'segments': 'liste değil'},
      good.toJson(),
    ]);
    store = InMemoryStore(<String, String>{WheelRepository.storageKey: raw});
    repository = WheelRepository(store);

    final List<Wheel> loaded = repository.loadAll();
    // 'iyi' + eksik alanlı kayıt (varsayılanlarla) okunur; düz string atlanır.
    expect(loaded.map((Wheel w) => w.id), contains('iyi'));
    expect(loaded.length, 2);
    final Wheel repaired = loaded.firstWhere((Wheel w) => w.id != 'iyi');
    expect(repaired.segments, isEmpty);
    expect(repaired.title, 'Adsız Çark');
  });

  test('depo okuması hata fırlatırsa bile çökmez, boş liste döner', () {
    // Web'de shared_preferences beklenmeyen tipte kayıt okunduğunda
    // cast hatası fırlatabilir; bu uygulamayı beyaz ekranda bırakmamalı.
    expect(WheelRepository(_ThrowingStore()).loadAll(), isEmpty);
  });

  test('upsert yeni kaydı başa ekler', () async {
    await repository.saveAll(<Wheel>[
      _wheel('a', 'A', DateTime.parse('2026-01-01T00:00:00Z')),
    ]);
    final List<Wheel> next = await repository.upsert(
      _wheel('b', 'B', DateTime.parse('2026-02-01T00:00:00Z')),
    );

    expect(next.first.id, 'b');
    expect(repository.loadAll().length, 2);
  });

  test('upsert var olan kaydı günceller, kopya oluşturmaz', () async {
    final Wheel original = _wheel(
      'a',
      'A',
      DateTime.parse('2026-01-01T00:00:00Z'),
    );
    await repository.saveAll(<Wheel>[original]);

    final List<Wheel> next = await repository.upsert(
      original.copyWith(title: 'A güncel'),
    );

    expect(next.length, 1);
    expect(next.single.title, 'A güncel');
  });

  test('delete kaydı siler ve kalan listeyi döner', () async {
    await repository.saveAll(<Wheel>[
      _wheel('a', 'A', DateTime.parse('2026-01-01T00:00:00Z')),
      _wheel('b', 'B', DateTime.parse('2026-02-01T00:00:00Z')),
    ]);

    final List<Wheel> next = await repository.delete('a');

    expect(next.map((Wheel w) => w.id).toList(), <String>['b']);
    expect(repository.loadAll().single.id, 'b');
  });

  test('Türkçe karakterler kaydedilip aynen okunur', () async {
    await repository.saveAll(<Wheel>[
      Wheel(
        id: 'tr',
        title: 'Çarkıfelek Şöleni ĞÜŞİÖÇ',
        segments: const <String>['Iğdır', 'Şişli', 'Çankaya'],
        updatedAt: DateTime.parse('2026-03-03T00:00:00Z'),
      ),
    ]);

    final Wheel loaded = repository.loadAll().single;
    expect(loaded.title, 'Çarkıfelek Şöleni ĞÜŞİÖÇ');
    expect(loaded.segments, <String>['Iğdır', 'Şişli', 'Çankaya']);
  });
}
